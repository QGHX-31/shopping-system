package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("group_buy_member")
public class GroupBuyMember {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long teamId;
    private Long productId;
    private Long userId;
    private String orderNo;
    private Integer isLeader;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime joinTime;
}
