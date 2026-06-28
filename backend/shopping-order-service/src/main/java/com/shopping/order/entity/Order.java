package com.shopping.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单主表
 * status: 0待支付 1已支付/待发货 2已发货 3已完成 4已取消 5退款中 6已退款 7已过期
 */
@Data
@TableName("`order`")
public class Order {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long parentOrderId;
    private Integer orderType;
    private String orderNo;
    private Long userId;
    private Long merchantId;
    private BigDecimal totalAmount;
    private BigDecimal payAmount;
    private BigDecimal freightAmount;
    private BigDecimal discountAmount;
    private Long couponId;
    private String couponIds;
    private Integer status;
    private Long groupBuyTeamId;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime groupBuyTime;
    private Long addressId;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime payTime;
    private Integer payMethod; // 1微信 2支付宝 3余额
    private String payTradeNo;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime deliveryTime;
    private String expressCompany;
    private String trackingNo;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime receiveTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime cancelTime;
    private String cancelReason;
    private String remark;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}
