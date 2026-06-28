package com.shopping.marketing.vo;

import lombok.Data;

import java.math.BigDecimal;

/**
 * 拼团活动VO - 包含商品信息
 */
@Data
public class GroupActivityVO {
    private Long id;
    private Long productId;
    private String productName;
    private String imageUrl;
    private BigDecimal groupPrice;
    private BigDecimal originalPrice;
    private Integer requiredNum;
    private Integer availableStock;
}