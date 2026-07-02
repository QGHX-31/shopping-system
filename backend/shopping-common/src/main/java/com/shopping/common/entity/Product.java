package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("product")
public class Product {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Long categoryId;
    private String brand;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer hasGroupBuy;
    private BigDecimal groupPrice;
    private Integer groupNum;
    private Integer stock;
    private Integer salesCount;
    private String description;
    private String imageUrl;
    private String detailImages;
    private Integer isHot;
    private Integer isNew;
    private Integer status;
    private Long merchantId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}