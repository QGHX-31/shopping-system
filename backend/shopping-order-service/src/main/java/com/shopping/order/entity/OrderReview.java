package com.shopping.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("order_review")
public class OrderReview {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orderId;
    private Long orderItemId;
    private Long userId;
    private Long productId;
    private Long skuId;
    private Long merchantId;
    private BigDecimal rating;
    private String content;
    private String images;
    private Integer isAnonymous;
    private Integer isTop;
    private Integer status;
    private String replyContent;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime replyTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
