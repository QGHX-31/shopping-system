package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("seckill_activity")
public class SeckillActivity {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Long merchantId;
    private Long productId;
    private Long skuId;
    private BigDecimal seckillPrice;
    private BigDecimal originalPrice;
    private Integer totalStock;
    private Integer availableStock;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer status;
    private String description;
    private String banner;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
