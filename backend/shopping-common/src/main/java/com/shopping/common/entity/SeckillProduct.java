package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("seckill_product")
public class SeckillProduct {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long activityId;
    private Long productId;
    private Long skuId;
    private BigDecimal seckillPrice;
    private BigDecimal originalPrice;
    private Integer totalStock;
    private Integer availableStock;
    private Integer limitPerUser;
    private Integer salesCount;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
