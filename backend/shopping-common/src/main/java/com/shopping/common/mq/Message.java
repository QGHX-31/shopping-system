package com.shopping.common.mq;

import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class Message implements Serializable {
    private String messageId;
    private String topic;
    private String tags;
    private String businessKey;
    private Object body;
    private LocalDateTime createTime;
    private Integer retryCount;

    public Message() {
        this.messageId = UUID.randomUUID().toString().replace("-", "");
        this.createTime = LocalDateTime.now();
        this.retryCount = 0;
    }

    public static Message of(String topic, Object body) {
        Message m = new Message();
        m.setTopic(topic);
        m.setBody(body);
        return m;
    }

    public static Message of(String topic, String tags, String businessKey, Object body) {
        Message m = new Message();
        m.setTopic(topic);
        m.setTags(tags);
        m.setBusinessKey(businessKey);
        m.setBody(body);
        return m;
    }
}
