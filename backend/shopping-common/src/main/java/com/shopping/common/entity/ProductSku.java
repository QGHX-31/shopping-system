package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product_sku")
public class ProductSku {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long productId;
    private Long merchantId;
    private String skuCode;
    private String specValues;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stock;
    private Integer lockedStock;
    private Integer salesCount;
    private BigDecimal weight;
    private String image;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
