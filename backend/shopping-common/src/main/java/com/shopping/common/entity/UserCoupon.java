package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("user_coupon")
public class UserCoupon {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long templateId;
    private String couponCode;
    private String name;
    private Integer type;
    private BigDecimal discountAmount;
    private BigDecimal minAmount;
    private Integer status;
    private LocalDateTime receiveTime;
    private LocalDateTime useTime;
    private LocalDateTime expireTime;
    private String orderNo;
    private String lockOrderNo;

    @TableField(exist = false)
    private Long merchantId;

    @TableField(exist = false)
    private Integer couponLevel;

    @TableField(exist = false)
    private Integer mutuallyExclusive;

    @TableField(exist = false)
    private Integer scopeType;

    @TableField(exist = false)
    private String scopeIds;
}
