package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("merchant")
public class Merchant {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String password;
    private String shopName;
    private String logo;
    private String contactName;
    private String contactPhone;
    private String email;
    private String address;
    private String businessLicense;
    private Integer status;
    private Integer level;
    @TableField(exist = false)
    private Boolean isAdmin;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
