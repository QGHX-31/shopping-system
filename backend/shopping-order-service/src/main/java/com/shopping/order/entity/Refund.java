package com.shopping.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("refund")
public class Refund {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String refundNo;
    private Long orderId;
    private Long userId;
    private BigDecimal refundAmount;
    private String refundReason;
    private Integer refundType; // 1仅退款 2退货退款
    private Integer status; // 0待审核 1已同意/待退货 2已拒绝 3已完成 4已取消 5退货中
    private String voucherImages;
    private String merchantRemark;
    private String adminRemark;
    private String returnLogisticsCompany;
    private String returnTrackingNo;
    private LocalDateTime returnShipTime;
    private LocalDateTime returnReceiveTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime applyTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime auditTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime refundTime;
}
