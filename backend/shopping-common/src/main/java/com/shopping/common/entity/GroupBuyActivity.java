package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("group_buy_activity")
public class GroupBuyActivity {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Long merchantId;
    private Long productId;
    private Long skuId;
    private BigDecimal groupPrice;
    private BigDecimal originalPrice;
    private Integer requiredNum;
    private Integer totalStock;
    private Integer availableStock;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer groupDuration;
    private Integer status;
    private String description;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
