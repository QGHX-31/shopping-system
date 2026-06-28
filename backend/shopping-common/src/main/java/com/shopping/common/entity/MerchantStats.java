package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("merchant_stats")
public class MerchantStats {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long merchantId;
    private LocalDate statDate;
    private Integer orderCount;
    private BigDecimal orderAmount;
    private Integer productViews;
    private Integer productSales;
    private Integer newCustomers;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
