package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("coupon_status_apply")
public class CouponStatusApply {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long templateId;
    private Long merchantId;
    private Integer targetStatus;
    private String reason;
    private Integer applyStatus;
    private String adminRemark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}