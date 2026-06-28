package com.shopping.common.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("address")
public class Address {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String name;
    private String phone;
    private String province;
    private String city;
    private String district;
    private String detail;
    private Integer isDefault;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    // ====== 兼容订单服务的 getReceiverName 等调用（OrderServiceImpl 用过） ======
    public String getReceiverName() { return this.name; }
    public void setReceiverName(String v) { this.name = v; }
    public String getReceiverPhone() { return this.phone; }
    public void setReceiverPhone(String v) { this.phone = v; }
    public String getDetailAddress() { return this.detail; }
    public void setDetailAddress(String v) { this.detail = v; }
}