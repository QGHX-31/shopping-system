package com.shopping.order.job;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.order.entity.Order;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.service.OrderService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
public class OrderTimeoutJob {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderService orderService;

    /**
     * 每5分钟检查一次超时未支付订单（超过15分钟自动取消）
     */
    @Scheduled(fixedRate = 5 * 60 * 1000)
    public void cancelTimeoutOrders() {
        LocalDateTime timeout = LocalDateTime.now().minusMinutes(15);
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Order::getStatus, 0)
               .lt(Order::getCreatedAt, timeout);
        List<Order> timeoutOrders = orderMapper.selectList(wrapper);

        if (timeoutOrders.isEmpty()) return;

        log.info("扫描到 {} 个超时未支付订单，准备自动取消", timeoutOrders.size());
        for (Order order : timeoutOrders) {
            try {
                orderService.cancelOrder(order.getOrderNo(), "超时未支付，系统自动取消");
                log.info("订单已自动取消: orderNo={}", order.getOrderNo());
            } catch (Exception e) {
                log.error("自动取消订单失败: orderNo={}", order.getOrderNo(), e);
            }
        }
    }
}
