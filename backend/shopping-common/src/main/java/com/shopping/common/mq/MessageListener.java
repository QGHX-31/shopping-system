package com.shopping.common.mq;

public interface MessageListener {
    /**
     * 消费消息
     * @param message 消息对象
     * @return true=消费成功，false=消费失败（将重试）
     */
    boolean onMessage(Message message);
}
