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
