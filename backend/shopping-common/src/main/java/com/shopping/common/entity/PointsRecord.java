package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("points_record")
public class PointsRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Integer points;
    private Integer type;
    private String source;
    private String orderNo;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}