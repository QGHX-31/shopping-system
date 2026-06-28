package com.shopping.common.mq;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.shopping.common.entity.MqMessageLog;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * MQ 消息发送/消费工具
 *
 * 设计要点：
 * 1. 抽象 MessageSender 接口，对外屏蔽具体实现（RocketMQ / RabbitMQ / 本地事件）
 * 2. 通过 mq_message_log 实现可靠投递追踪
 * 3. 异步消费失败时支持重试
 * 4. 同一 topic 支持多消费者（标签 tags 区分）
 *
 * 实际生产环境可替换 MqMessageSenderImpl 为 RocketMQTemplate 实现
 */
@Slf4j
@Component
public class MqMessageSender {

    @Resource
    private com.shopping.common.utils.RedisUtil redisUtil;

    @Autowired
    private ApplicationContext applicationContext;

    /** 消费者注册表：topic -> 监听器列表 */
    private static final Map<String, java.util.List<MessageListener>> LISTENERS = new ConcurrentHashMap<>();

    private static final ExecutorService CONSUMER_POOL = Executors.newFixedThreadPool(8, r -> {
        Thread t = new Thread(r, "mq-consumer");
        t.setDaemon(true);
        return t;
    });

    /**
     * 发送消息
     * @param topic 主题
     * @param body 消息体
     * @return messageId
     */
    public String send(String topic, Object body) {
        return send(topic, null, null, body);
    }

    public String send(String topic, String tags, String businessKey, Object body) {
        Message message = Message.of(topic, tags, businessKey, body);
        // 1. 落库
        saveMessageLog(message);
        // 2. 异步分发
        CONSUMER_POOL.submit(() -> dispatch(message));
        log.info("MQ发送消息: topic={}, messageId={}", topic, message.getMessageId());
        return message.getMessageId();
    }

    /**
     * 订阅（注册消费者）
     */
    public static void subscribe(String topic, MessageListener listener) {
        LISTENERS.computeIfAbsent(topic, k -> new java.util.ArrayList<>()).add(listener);
        log.info("注册MQ消费者: topic={}", topic);
    }

    /**
     * 取消订阅
     */
    public static void unsubscribe(String topic, MessageListener listener) {
        List<MessageListener> list = LISTENERS.get(topic);
        if (list != null) {
            list.remove(listener);
        }
    }

    private void dispatch(Message message) {
        // 标记已发送
        markSent(message.getMessageId());
        // 广播给所有订阅者
        List<MessageListener> listeners = LISTENERS.get(message.getTopic());
        if (listeners == null || listeners.isEmpty()) {
            log.warn("MQ消息无消费者: topic={}, messageId={}", message.getTopic(), message.getMessageId());
            markConsumed(message.getMessageId(), 2, "无消费者");
            return;
        }
        for (MessageListener listener : listeners) {
            try {
                boolean ok = listener.onMessage(message);
                if (ok) {
                    markConsumed(message.getMessageId(), 2, null);
                } else {
                    retryOrFail(message, listener, "业务返回false");
                }
            } catch (Exception e) {
                log.error("MQ消费异常", e);
                retryOrFail(message, listener, e.getMessage());
            }
        }
    }

    private void retryOrFail(Message message, MessageListener listener, String err) {
        message.setRetryCount(message.getRetryCount() + 1);
        if (message.getRetryCount() < 3) {
            log.info("MQ消费失败，第{}次重试: topic={}, messageId={}", message.getRetryCount(), message.getTopic(), message.getMessageId());
            CONSUMER_POOL.submit(() -> {
                try {
                    Thread.sleep(1000L * message.getRetryCount());
                    if (listener.onMessage(message)) {
                        markConsumed(message.getMessageId(), 2, null);
                    } else {
                        markConsumed(message.getMessageId(), 3, err);
                    }
                } catch (Exception e) {
                    markConsumed(message.getMessageId(), 3, e.getMessage());
                }
            });
        } else {
            markConsumed(message.getMessageId(), 3, err);
        }
    }

    private void saveMessageLog(Message message) {
        try {
            MqMessageLog log = new MqMessageLog();
            log.setMessageId(message.getMessageId());
            log.setTopic(message.getTopic());
            log.setTags(message.getTags());
            log.setBusinessKey(message.getBusinessKey());
            log.setContent(JSON.toJSONString(message.getBody()));
            log.setStatus(0);
            log.setRetryCount(0);
            // 通过 applicationContext 获取 mapper
            MqMessageLogMapper mapper = applicationContext.getBean(MqMessageLogMapper.class);
            mapper.insert(log);
        } catch (Exception e) {
            MqMessageSender.log.error("MQ消息落库失败", e);
        }
    }

    private void markSent(String messageId) {
        try {
            MqMessageLogMapper mapper = applicationContext.getBean(MqMessageLogMapper.class);
            MqMessageLog update = new MqMessageLog();
            update.setStatus(1);
            update.setSendTime(LocalDateTime.now());
            mapper.update(update, new LambdaUpdateWrapper<MqMessageLog>()
                    .eq(MqMessageLog::getMessageId, messageId));
        } catch (Exception e) {
            MqMessageSender.log.error("MQ标记发送失败", e);
        }
    }

    private void markConsumed(String messageId, int status, String errMsg) {
        try {
            MqMessageLogMapper mapper = applicationContext.getBean(MqMessageLogMapper.class);
            MqMessageLog update = new MqMessageLog();
            update.setStatus(status);
            update.setConsumeTime(LocalDateTime.now());
            update.setErrorMsg(errMsg);
            mapper.update(update, new LambdaUpdateWrapper<MqMessageLog>()
                    .eq(MqMessageLog::getMessageId, messageId));
        } catch (Exception e) {
            MqMessageSender.log.error("MQ标记消费失败", e);
        }
    }

    /**
     * 启动后扫描并重发状态=0的待发消息（用于宕机恢复）
     */
    @PostConstruct
    public void recoverPending() {
        try {
            MqMessageLogMapper mapper = applicationContext.getBean(MqMessageLogMapper.class);
            List<MqMessageLog> pending = mapper.selectList(new LambdaQueryWrapper<MqMessageLog>()
                    .eq(MqMessageLog::getStatus, 0)
                    .last("LIMIT 100"));
            for (MqMessageLog log : pending) {
                Message message = new Message();
                message.setMessageId(log.getMessageId());
                message.setTopic(log.getTopic());
                message.setTags(log.getTags());
                message.setBusinessKey(log.getBusinessKey());
                try {
                    message.setBody(JSON.parse(log.getContent()));
                } catch (Exception ignore) {}
                CONSUMER_POOL.submit(() -> dispatch(message));
            }
            if (!pending.isEmpty()) {
                MqMessageSender.log.info("MQ恢复待发消息: count={}", pending.size());
            }
        } catch (Exception ignore) {
            // 启动时 mapper 还未注入，可忽略
        }
    }
}
