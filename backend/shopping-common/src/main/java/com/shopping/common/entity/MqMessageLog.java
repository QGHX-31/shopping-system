package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("mq_message_log")
public class MqMessageLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String messageId;
    private String topic;
    private String tags;
    private String businessKey;
    private String content;
    private Integer status;
    private Integer retryCount;
    private String errorMsg;
    private LocalDateTime sendTime;
    private LocalDateTime consumeTime;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
