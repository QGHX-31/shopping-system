package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("platform_group_template")
public class PlatformGroupTemplate {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Integer requiredNum;
    private BigDecimal discountRate;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer groupDuration;
    private String description;
    private String banner;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}