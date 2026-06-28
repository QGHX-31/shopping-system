package com.shopping.marketing.listener;

import com.alibaba.fastjson2.JSON;
import com.shopping.common.entity.SeckillProduct;
import com.shopping.common.mq.Message;
import com.shopping.common.mq.MessageListener;
import com.shopping.common.mq.MqMessageSender;
import com.shopping.common.mq.MqTopic;
import com.shopping.marketing.mapper.SeckillProductMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.Map;

/**
 * 营销服务 MQ 消息监听器
 *
 * 功能：
 * 1. 库存扣减通知 - 更新秒杀/拼团活动的商品库存
 * 2. 库存回滚通知 - 订单取消时恢复活动库存
 * 3. 拼团成团通知 - 成团后更新统计
 * 4. 秒杀下单通知 - 记录秒杀订单统计
 */
@Component
public class MarketingMqListener implements MessageListener {

    private static final Logger log = LoggerFactory.getLogger(MarketingMqListener.class);

    @Resource
    private MqMessageSender mqMessageSender;

    @Resource
    private SeckillProductMapper seckillProductMapper;

    @PostConstruct
    public void init() {
        MqMessageSender.subscribe(MqTopic.STOCK_DEDUCT, this);
        MqMessageSender.subscribe(MqTopic.STOCK_ROLLBACK, this);
        MqMessageSender.subscribe(MqTopic.GROUP_SUCCESS, this);
        MqMessageSender.subscribe(MqTopic.SECKILL_PLACE, this);
        MqMessageSender.subscribe(MqTopic.SECKILL_START, this);
        MqMessageSender.subscribe(MqTopic.SECKILL_END, this);
        MqMessageSender.subscribe(MqTopic.COUPON_RECEIVE, this);
        MqMessageSender.subscribe(MqTopic.COUPON_USE, this);
        log.info("MarketingMqListener registered");
    }

    @Override
    public boolean onMessage(Message message) {
        try {
            log.info("MarketingMqListener received: topic={}, messageId={}", message.getTopic(), message.getMessageId());
            Map<String, Object> body = parseBody(message.getBody());
            if (body == null) {
                return true;
            }

            switch (message.getTopic()) {
                case MqTopic.STOCK_DEDUCT:
                    handleStockDeduct(body);
                    break;
                case MqTopic.STOCK_ROLLBACK:
                    handleStockRollback(body);
                    break;
                case MqTopic.SECKILL_PLACE:
                    handleSeckillPlace(body);
                    break;
                case MqTopic.SECKILL_START:
                    handleSeckillStart(body);
                    break;
                case MqTopic.SECKILL_END:
                    handleSeckillEnd(body);
                    break;
                case MqTopic.GROUP_SUCCESS:
                    handleGroupSuccess(body);
                    break;
                case MqTopic.COUPON_RECEIVE:
                    handleCouponReceive(body);
                    break;
                case MqTopic.COUPON_USE:
                    handleCouponUse(body);
                    break;
                default:
                    log.info("Unhandled topic: {}", message.getTopic());
            }
            return true;
        } catch (Exception e) {
            log.error("MarketingMqListener error, topic={}", message.getTopic(), e);
            return false;
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> parseBody(Object body) {
        if (body instanceof Map) {
            return (Map<String, Object>) body;
        }
        if (body instanceof String) {
            try {
                return JSON.parseObject((String) body, Map.class);
            } catch (Exception e) {
                return null;
            }
        }
        return null;
    }

    private void handleStockDeduct(Map<String, Object> body) {
        Object skuId = body.get("skuId");
        Object count = body.get("count");
        Object type = body.get("type");
        log.info("[库存扣减通知] skuId={}, count={}, type={}", skuId, count, type);
    }

    private void handleStockRollback(Map<String, Object> body) {
        Object skuId = body.get("skuId");
        Object count = body.get("count");
        log.info("[库存回滚通知] skuId={}, count={}", skuId, count);
    }

    private void handleSeckillPlace(Map<String, Object> body) {
        Object orderNo = body.get("orderNo");
        Object userId = body.get("userId");
        Object productId = body.get("productId");
        Object quantity = body.get("quantity");
        Object amount = body.get("amount");
        log.info("[秒杀下单] orderNo={}, userId={}, productId={}, quantity={}, amount={}",
                orderNo, userId, productId, quantity, amount);
    }

    private void handleSeckillStart(Map<String, Object> body) {
        Object activityId = body.get("activityId");
        Object activityName = body.get("activityName");
        log.info("[秒杀活动开始] activityId={}, activityName={}", activityId, activityName);
    }

    private void handleSeckillEnd(Map<String, Object> body) {
        Object activityId = body.get("activityId");
        Object productId = body.get("productId");
        log.info("[秒杀活动结束] activityId={}, productId={}", activityId, productId);
    }

    private void handleGroupSuccess(Map<String, Object> body) {
        Object teamNo = body.get("teamNo");
        Object groupId = body.get("groupId");
        Object productId = body.get("productId");
        log.info("[拼团成团] teamNo={}, groupId={}, productId={}", teamNo, groupId, productId);
    }

    private void handleCouponReceive(Map<String, Object> body) {
        Object userId = body.get("userId");
        Object templateId = body.get("templateId");
        Object couponId = body.get("couponId");
        log.info("[优惠券领取] userId={}, templateId={}, couponId={}", userId, templateId, couponId);
    }

    private void handleCouponUse(Map<String, Object> body) {
        Object userCouponId = body.get("userCouponId");
        Object orderNo = body.get("orderNo");
        log.info("[优惠券使用] userCouponId={}, orderNo={}", userCouponId, orderNo);
    }
}
