package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("merchant_seckill_participation")
public class MerchantSeckillParticipation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long templateId;
    private Long merchantId;
    private Long productId;
    private Long skuId;
    private BigDecimal seckillPrice;
    private BigDecimal originalPrice;
    private Integer totalStock;
    private Integer availableStock;
    private Integer limitPerUser;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}