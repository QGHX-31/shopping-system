package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("platform_coupon_template")
public class PlatformCouponTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Integer type;
    private BigDecimal discountAmount;
    private BigDecimal minAmount;
    private Integer totalCount;
    private Integer remainingCount;
    private Integer perUserLimit;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String description;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}