package com.shopping.order.vo;

import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class OrderVO {
    private Order order;
    private List<OrderItem> items;
    private CouponInfo coupon;
    private List<CouponInfo> coupons;
    private List<OrderVO> subOrders;
    private Integer refundStatus; // 最新退款记录的状态：null=无退款, 0=待审核, 1=待退货, 2=已拒绝, 3=已完成, 5=退货中
    private String rejectReason; // 退款被拒绝的原因

    @Data
    public static class CouponInfo {
        private Long id;
        private String name;
        private Integer type;
        private BigDecimal discountAmount;
        private BigDecimal minAmount;
        private String description;
    }
}
