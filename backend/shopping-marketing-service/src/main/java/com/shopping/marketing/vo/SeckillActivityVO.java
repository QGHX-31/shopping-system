package com.shopping.marketing.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 秒杀活动VO - 包含商品信息
 */
@Data
public class SeckillActivityVO {
    private Long id;
    private Long productId;
    private String productName;
    private String imageUrl;
    private BigDecimal seckillPrice;
    private BigDecimal originalPrice;
    private Integer totalStock;
    private Integer availableStock;
    private Integer salesCount;
    private Integer limitPerUser;
    private Long endTime;
}