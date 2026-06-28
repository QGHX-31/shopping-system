package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("member")
public class Member {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Integer memberLevel;
    private Integer totalPoints;
    private Integer availablePoints;
    private LocalDateTime memberSince;
    private LocalDateTime expireTime;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}