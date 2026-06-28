package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("merchant_group_participation")
public class MerchantGroupParticipation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long templateId;
    private Long merchantId;
    private Long productId;
    private Long skuId;
    private BigDecimal groupPrice;
    private BigDecimal originalPrice;
    private Integer totalStock;
    private Integer availableStock;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}