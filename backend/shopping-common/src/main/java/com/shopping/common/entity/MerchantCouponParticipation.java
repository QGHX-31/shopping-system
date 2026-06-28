package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("merchant_coupon_participation")
public class MerchantCouponParticipation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long templateId;
    private Long merchantId;
    private Long productId;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}