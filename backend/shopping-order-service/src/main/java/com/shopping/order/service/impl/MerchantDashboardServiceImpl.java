package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.entity.Refund;
import com.shopping.order.mapper.OrderItemMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.mapper.RefundMapper;
import com.shopping.order.service.MerchantDashboardService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
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
public class MerchantDashboardServiceImpl implements MerchantDashboardService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private RefundMapper refundMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${shopping.product-service-url:http://localhost:8082}")
    private String productServiceUrl;

    @Override
    public Map<String, Object> getDashboardData(Long merchantId) {
        Map<String, Object> result = new HashMap<>();

        LocalDateTime todayStart = LocalDate.now().atStartOfDay();
        LocalDateTime todayEnd = LocalDate.now().atTime(LocalTime.MAX);

        Set<Long> merchantOrderIds = getMerchantOrderIds(merchantId);

        Long todayOrderCount = 0L;
        BigDecimal todaySalesAmount = BigDecimal.ZERO;
        if (!merchantOrderIds.isEmpty()) {
            todayOrderCount = orderMapper.selectCount(
                    new LambdaQueryWrapper<Order>()
                            .in(Order::getId, merchantOrderIds)
                            .ge(Order::getCreatedAt, todayStart)
                            .le(Order::getCreatedAt, todayEnd)
                            .in(Order::getStatus, 1, 2, 3, 5, 6));

            List<Order> todayPaidOrders = orderMapper.selectList(
                    new LambdaQueryWrapper<Order>()
                            .in(Order::getId, merchantOrderIds)
                            .ge(Order::getPayTime, todayStart)
                            .le(Order::getPayTime, todayEnd)
                            .in(Order::getStatus, 1, 2, 3, 5, 6));
            for (Order order : todayPaidOrders) {
                if (order.getPayAmount() != null) {
                    todaySalesAmount = todaySalesAmount.add(order.getPayAmount());
                }
            }
        }
        result.put("todayOrderCount", todayOrderCount);
        result.put("todaySalesAmount", todaySalesAmount);

        Long pendingShipCount = 0L;
        if (!merchantOrderIds.isEmpty()) {
            pendingShipCount = orderMapper.selectCount(
                    new LambdaQueryWrapper<Order>()
                            .in(Order::getId, merchantOrderIds)
                            .eq(Order::getStatus, 1));
        }
        result.put("pendingShipCount", pendingShipCount);

        Set<Long> merchantRefundOrderIds = getMerchantRefundOrderIds(merchantId);
        Long pendingRefundCount = 0L;
        if (!merchantRefundOrderIds.isEmpty()) {
            pendingRefundCount = refundMapper.selectCount(
                    new LambdaQueryWrapper<Refund>()
                            .in(Refund::getOrderId, merchantRefundOrderIds)
                            .eq(Refund::getStatus, 0));
        }
        result.put("pendingRefundCount", pendingRefundCount);

        try {
            Map productRes = restTemplate.getForObject(
                    productServiceUrl + "/product/count?merchantId=" + merchantId, Map.class);
            if (productRes != null && productRes.get("data") != null) {
                result.put("totalProductCount", productRes.get("data"));
            } else {
                result.put("totalProductCount", 0);
            }
        } catch (Exception e) {
            log.warn("获取商家商品数失败: merchantId={}", merchantId, e);
            result.put("totalProductCount", 0);
        }

        return result;
    }

    @Override
    public Map<String, Object> getSalesTrend(Long merchantId, Integer days) {
        if (days == null || days < 1) days = 7;
        List<String> dates = new ArrayList<>();
        List<Integer> orderData = new ArrayList<>();
        List<BigDecimal> amountData = new ArrayList<>();

        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("M/d");

        Set<Long> merchantOrderIds = getMerchantOrderIds(merchantId);

        for (int i = days - 1; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            dates.add(date.format(formatter));

            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.atTime(LocalTime.MAX);

            int orderCount = 0;
            BigDecimal dayAmount = BigDecimal.ZERO;

            if (!merchantOrderIds.isEmpty()) {
                Long count = orderMapper.selectCount(
                        new LambdaQueryWrapper<Order>()
                                .in(Order::getId, merchantOrderIds)
                                .in(Order::getStatus, 1, 2, 3, 5, 6)
                                .ge(Order::getPayTime, start)
                                .le(Order::getPayTime, end));
                orderCount = count.intValue();

                List<Order> dayOrders = orderMapper.selectList(
                        new LambdaQueryWrapper<Order>()
                                .in(Order::getId, merchantOrderIds)
                                .in(Order::getStatus, 1, 2, 3, 5, 6)
                                .ge(Order::getPayTime, start)
                                .le(Order::getPayTime, end));
                for (Order order : dayOrders) {
                    if (order.getPayAmount() != null) {
                        dayAmount = dayAmount.add(order.getPayAmount());
                    }
                }
            }

            orderData.add(orderCount);
            amountData.add(dayAmount);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("dates", dates);
        result.put("orderData", orderData);
        result.put("amountData", amountData);
        return result;
    }

    @Override
    public List<Map<String, Object>> getOrderStatusDistribution(Long merchantId) {
        List<Map<String, Object>> list = new ArrayList<>();

        Set<Long> merchantOrderIds = getMerchantOrderIds(merchantId);

        int[] statuses = {0, 1, 2, 3, 4, 5, 6};
        String[] names = {"待支付", "待发货", "已发货", "已完成", "已取消", "退款中", "已退款"};
        String[] colors = {"#e6a23c", "#409eff", "#909399", "#67c23a", "#f56c6c", "#9b59b6", "#16baaa"};

        for (int i = 0; i < statuses.length; i++) {
            Long count = 0L;
            if (!merchantOrderIds.isEmpty()) {
                count = orderMapper.selectCount(
                        new LambdaQueryWrapper<Order>()
                                .in(Order::getId, merchantOrderIds)
                                .eq(Order::getStatus, statuses[i]));
            }
            Map<String, Object> item = new HashMap<>();
            item.put("name", names[i]);
            item.put("value", count);
            item.put("color", colors[i]);
            list.add(item);
        }

        return list;
    }

    @Override
    public List<Map<String, Object>> getTopProducts(Long merchantId, Integer limit) {
        if (limit == null || limit < 1) limit = 10;

        List<OrderItem> merchantItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>()
                        .eq(OrderItem::getMerchantId, merchantId));

        Set<Long> paidOrderIds = getPaidOrderIds(merchantId);

        Map<Long, Integer> quantityMap = new LinkedHashMap<>();
        Map<Long, String> nameMap = new HashMap<>();
        Map<Long, BigDecimal> amountMap = new HashMap<>();

        for (OrderItem item : merchantItems) {
            if (item.getProductId() == null) continue;
            if (!paidOrderIds.contains(item.getOrderId())) continue;

            quantityMap.merge(item.getProductId(), item.getQuantity() == null ? 0 : item.getQuantity(), Integer::sum);
            nameMap.put(item.getProductId(), item.getProductName());
            BigDecimal subtotal = item.getSubtotal() != null ? item.getSubtotal() : BigDecimal.ZERO;
            amountMap.merge(item.getProductId(), subtotal, BigDecimal::add);
        }

        List<Map.Entry<Long, Integer>> sortedList = quantityMap.entrySet().stream()
                .sorted(Map.Entry.<Long, Integer>comparingByValue().reversed())
                .limit(limit)
                .collect(Collectors.toList());

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, Integer> entry : sortedList) {
            Map<String, Object> item = new HashMap<>();
            item.put("productId", entry.getKey());
            item.put("productName", nameMap.get(entry.getKey()));
            item.put("sales", entry.getValue());
            item.put("salesAmount", amountMap.get(entry.getKey()));
            result.add(item);
        }

        return result;
    }

    private Set<Long> getMerchantOrderIds(Long merchantId) {
        Set<Long> orderIds = new HashSet<>();

        LambdaQueryWrapper<OrderItem> itemWrapper = new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getMerchantId, merchantId)
                .select(OrderItem::getOrderId);
        List<OrderItem> itemList = orderItemMapper.selectList(itemWrapper);
        for (OrderItem item : itemList) {
            orderIds.add(item.getOrderId());
        }

        LambdaQueryWrapper<Order> directWrapper = new LambdaQueryWrapper<Order>()
                .eq(Order::getMerchantId, merchantId)
                .select(Order::getId);
        List<Order> directOrders = orderMapper.selectList(directWrapper);
        for (Order o : directOrders) {
            orderIds.add(o.getId());
        }

        return orderIds;
    }

    private Set<Long> getMerchantRefundOrderIds(Long merchantId) {
        return getMerchantOrderIds(merchantId);
    }

    private Set<Long> getPaidOrderIds(Long merchantId) {
        Set<Long> merchantOrderIds = getMerchantOrderIds(merchantId);
        if (merchantOrderIds.isEmpty()) {
            return merchantOrderIds;
        }
        List<Order> paidOrders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>()
                        .in(Order::getId, merchantOrderIds)
                        .in(Order::getStatus, 1, 2, 3, 5, 6)
                        .select(Order::getId));
        return paidOrders.stream().map(Order::getId).collect(Collectors.toSet());
    }
}
