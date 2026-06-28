package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("group_buy_team")
public class GroupBuyTeam {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String teamNo;
    private Long activityId;
    private Long leaderId;
    private Integer requiredNum;
    private Integer currentNum;
    private Integer status;
    private LocalDateTime expireTime;
    private LocalDateTime successTime;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
