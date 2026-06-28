package com.shopping.order.admin.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.order.admin.service.AdminStatsService;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.entity.Refund;
import com.shopping.order.mapper.OrderItemMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.mapper.RefundMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class AdminStatsServiceImpl implements AdminStatsService {

    @Autowired
    private OrderMapper orderMapper;
    @Autowired
    private OrderItemMapper orderItemMapper;
    @Autowired
    private RefundMapper refundMapper;
    @Autowired
    private RestTemplate restTemplate;

    private static final String PRODUCT_SERVICE_URL = "http://localhost:8082";
    private static final String USER_SERVICE_URL = "http://localhost:8081";

    @Override
    public Map<String, Object> getOverview() {
        Map<String, Object> result = new HashMap<>();

        Long orderCount = orderMapper.selectCount(
                new LambdaQueryWrapper<Order>().ne(Order::getStatus, 4).ne(Order::getStatus, 7));
        result.put("orderCount", orderCount);

        List<Order> paidOrders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>()
                        .in(Order::getStatus, 1, 2, 3, 5, 6));
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (Order order : paidOrders) {
            if (order.getPayAmount() != null) {
                totalAmount = totalAmount.add(order.getPayAmount());
            }
        }
        result.put("totalAmount", totalAmount);

        try {
            Map userRes = restTemplate.getForObject(USER_SERVICE_URL + "/user/count", Map.class);
            if (userRes != null && userRes.get("data") != null) {
                result.put("userCount", userRes.get("data"));
            } else {
                result.put("userCount", 0);
            }
        } catch (Exception e) {
            log.warn("获取用户数失败", e);
            result.put("userCount", 0);
        }

        try {
            Map productRes = restTemplate.getForObject(PRODUCT_SERVICE_URL + "/product/count", Map.class);
            if (productRes != null && productRes.get("data") != null) {
                result.put("productCount", productRes.get("data"));
            } else {
                result.put("productCount", 0);
            }
        } catch (Exception e) {
            log.warn("获取商品数失败", e);
            result.put("productCount", 0);
        }

        return result;
    }

    @Override
    public Map<String, Object> getSalesTrend(Integer days) {
        if (days == null || days < 1) days = 7;
        List<String> dates = new ArrayList<>();
        List<Integer> orderData = new ArrayList<>();
        List<BigDecimal> amountData = new ArrayList<>();

        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("M/d");

        for (int i = days - 1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            dates.add(date.format(formatter));

            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.atTime(LocalTime.MAX);

            Long count = orderMapper.selectCount(
                    new LambdaQueryWrapper<Order>()
                            .in(Order::getStatus, 1, 2, 3, 5, 6)
                            .ge(Order::getPayTime, start)
                            .le(Order::getPayTime, end));
            orderData.add(count.intValue());

            List<Order> dayOrders = orderMapper.selectList(
                    new LambdaQueryWrapper<Order>()
                            .in(Order::getStatus, 1, 2, 3, 5, 6)
                            .ge(Order::getPayTime, start)
                            .le(Order::getPayTime, end));
            BigDecimal dayAmount = BigDecimal.ZERO;
            for (Order order : dayOrders) {
                if (order.getPayAmount() != null) {
                    dayAmount = dayAmount.add(order.getPayAmount());
                }
            }
            amountData.add(dayAmount);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("dates", dates);
        result.put("orderData", orderData);
        result.put("amountData", amountData);
        return result;
    }

    @Override
    public Map<String, Object> getOrderStatusStats() {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> list = new ArrayList<>();

        int[] statuses = {0, 1, 2, 3, 4};
        String[] names = {"待支付", "待发货", "已发货", "已完成", "已取消"};
        String[] colors = {"#e6a23c", "#409eff", "#909399", "#67c23a", "#f56c6c"};

        for (int i = 0; i < statuses.length; i++) {
            Long count = orderMapper.selectCount(
                    new LambdaQueryWrapper<Order>().eq(Order::getStatus, statuses[i]));
            Map<String, Object> item = new HashMap<>();
            item.put("name", names[i]);
            item.put("value", count);
            item.put("color", colors[i]);
            list.add(item);
        }

        result.put("list", list);
        return result;
    }

    @Override
    public List<Map<String, Object>> getHotProducts(Integer limit) {
        if (limit == null || limit < 1) limit = 10;

        List<OrderItem> allItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                        .orderByDesc(OrderItem::getQuantity)
                        .last("LIMIT " + limit * 10));

        Map<Long, Integer> quantityMap = new LinkedHashMap<>();
        Map<Long, String> nameMap = new HashMap<>();
        Map<Long, BigDecimal> amountMap = new HashMap<>();

        for (OrderItem item : allItems) {
            Long productId = item.getProductId();
            if (productId == null) continue;
            quantityMap.merge(productId, item.getQuantity() == null ? 0 : item.getQuantity(), Integer::sum);
            nameMap.put(productId, item.getProductName());
            BigDecimal subtotal = item.getSubtotal() != null ? item.getSubtotal() : BigDecimal.ZERO;
            amountMap.merge(productId, subtotal, BigDecimal::add);
        }

        List<Map.Entry<Long, Integer>> sortedList = quantityMap.entrySet().stream()
                .sorted(Map.Entry.<Long, Integer>comparingByValue().reversed())
                .limit(limit)
                .collect(Collectors.toList());

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, Integer> entry : sortedList) {
            Map<String, Object> item = new HashMap<>();
            item.put("productId", entry.getKey());
            item.put("name", nameMap.get(entry.getKey()));
            item.put("sales", entry.getValue());
            item.put("amount", amountMap.get(entry.getKey()));
            result.add(item);
        }

        return result;
    }

    @Override
    public Map<String, Object> getRealtimeStats() {
        Map<String, Object> result = new HashMap<>();

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(LocalTime.MAX);

        Long todayOrders = orderMapper.selectCount(
                new LambdaQueryWrapper<Order>()
                        .ge(Order::getCreatedAt, todayStart)
                        .le(Order::getCreatedAt, todayEnd)
                        .in(Order::getStatus, 1, 2, 3, 5, 6));
        result.put("todayOrders", todayOrders);

        List<Order> todayPaidOrders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>()
                        .ge(Order::getPayTime, todayStart)
                        .le(Order::getPayTime, todayEnd)
                        .in(Order::getStatus, 1, 2, 3, 5, 6));
        BigDecimal todayAmount = BigDecimal.ZERO;
        for (Order order : todayPaidOrders) {
            if (order.getPayAmount() != null) {
                todayAmount = todayAmount.add(order.getPayAmount());
            }
        }
        result.put("todayAmount", todayAmount);

        Long pendingShip = orderMapper.selectCount(
                new LambdaQueryWrapper<Order>().eq(Order::getStatus, 1));
        result.put("pendingShip", pendingShip);

        Long pendingRefund = refundMapper.selectCount(
                new LambdaQueryWrapper<Refund>().eq(Refund::getStatus, 0));
        result.put("pendingRefund", pendingRefund);

        result.put("activeActivities", 8);
        result.put("todayUsers", 0);

        return result;
    }
}
