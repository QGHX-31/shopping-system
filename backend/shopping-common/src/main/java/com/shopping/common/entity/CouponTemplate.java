package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("coupon_template")
public class CouponTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Long merchantId;
    private Integer type;
    private BigDecimal discountAmount;
    private BigDecimal minAmount;
    private Integer totalCount;
    private Integer remainingCount;
    private Integer perUserLimit;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer status;
    private String description;
    private Integer scopeType;
    private String scopeIds;
    private Integer couponLevel;
    private Integer mutuallyExclusive;
    private Integer userType;
    private Integer memberLevel;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
