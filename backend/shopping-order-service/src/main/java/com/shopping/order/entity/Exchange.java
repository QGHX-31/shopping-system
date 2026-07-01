package com.shopping.order.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("exchange")
public class Exchange {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String exchangeNo;
    private Long orderId;
    private Long orderItemId;
    private Long userId;
    private Long merchantId;
    private String exchangeReason;
    private String voucherImages;
    private Integer originalOrderStatus;
    
    // 原商品信息
    private Long originalProductId;
    private Long originalSkuId;
    private String originalProductName;
    private String originalSpecValues;
    private Integer originalQuantity;
    private BigDecimal originalPrice;
    
    // 新商品信息
    private Long newProductId;
    private Long newSkuId;
    private String newProductName;
    private String newSpecValues;
    private Integer newQuantity;
    private BigDecimal newPrice;
    private BigDecimal priceDifference;
    
    // 退货物流信息
    private String returnLogisticsCompany;
    private String returnTrackingNo;
    private LocalDateTime returnShipTime;
    private LocalDateTime returnReceiveTime;
    
    // 换货发货物流信息
    private String exchangeLogisticsCompany;
    private String exchangeTrackingNo;
    private LocalDateTime exchangeShipTime;
    private LocalDateTime exchangeReceiveTime;
    
    // 状态与备注
    private Integer status; // 0待审核 1待退货 2已拒绝 3已完成 4已取消 5退货中 6待发货 7已发货
    private String merchantRemark;
    
    // 时间记录
    private LocalDateTime applyTime;
    private LocalDateTime auditTime;
    private LocalDateTime completeTime;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}