package com.shopping.order.admin.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;

@Data
@TableName("admin_role")
public class AdminRole implements Serializable {
    @TableId(type = IdType.INPUT)
    private Long adminId;
    private Long roleId;
}
