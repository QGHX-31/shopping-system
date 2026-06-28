package com.shopping.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("freight_template")
public class FreightTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long merchantId;
    private String name;
    private Integer type;
    private BigDecimal firstWeight;
    private BigDecimal firstFee;
    private BigDecimal continueWeight;
    private BigDecimal continueFee;
    private String freeCondition;
    private BigDecimal freeAmount;
    private Integer status;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
