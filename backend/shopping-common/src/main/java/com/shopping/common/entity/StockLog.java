package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("stock_log")
public class StockLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long skuId;
    private Long productId;
    private Long merchantId;
    private Integer type;
    private Integer quantity;
    private Integer beforeStock;
    private Integer afterStock;
    private String refNo;
    private String remark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}
