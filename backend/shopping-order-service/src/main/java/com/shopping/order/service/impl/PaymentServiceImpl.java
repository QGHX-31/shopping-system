package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.exception.BusinessException;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.Payment;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.mapper.PaymentMapper;
import com.shopping.order.service.OrderService;
import com.shopping.order.service.PaymentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 支付服务（沙箱模式）
 * <p>
 * 真实场景应集成微信/支付宝 SDK，本项目为简化直接模拟回调
 */
@Slf4j
@Service
public class PaymentServiceImpl implements PaymentService {

    @Autowired private PaymentMapper paymentMapper;
    @Autowired private OrderMapper orderMapper;
    @Autowired private OrderService orderService;

    @Override
    @Transactional
    public String createPayment(Long orderId, Integer payMethod) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) throw new BusinessException("订单不存在");
        if (order.getStatus() != 0) throw new BusinessException("订单状态不允许支付");

        // 创建支付记录
        Payment payment = new Payment();
        payment.setOrderId(orderId);
        payment.setOrderNo(order.getOrderNo());
        payment.setUserId(order.getUserId());
        payment.setPayMethod(payMethod);
        payment.setPayAmount(order.getPayAmount());
        payment.setStatus(0);
        payment.setCreatedAt(LocalDateTime.now());
        payment.setUpdatedAt(LocalDateTime.now());
        paymentMapper.insert(payment);

        // 沙箱：返回模拟的支付页面 URL，前端会立即调用 mockPayCallback
        return "/mock-pay?orderNo=" + order.getOrderNo() + "&payMethod=" + payMethod;
    }

    @Override
    @Transactional
    public void mockPayCallback(String orderNo, Integer payMethod, String payTradeNo) {
        Order order = orderMapper.selectOne(
                new LambdaQueryWrapper<Order>().eq(Order::getOrderNo, orderNo));
        if (order == null) throw new BusinessException("订单不存在");

        String tradeNo = payTradeNo != null ? payTradeNo : "MOCK" + UUID.randomUUID().toString().replace("-", "").substring(0, 16);

        // 更新支付记录
        Payment payment = paymentMapper.selectOne(
                new LambdaQueryWrapper<Payment>().eq(Payment::getOrderId, order.getId()));
        if (payment != null) {
            payment.setStatus(1);
            payment.setPayTradeNo(tradeNo);
            payment.setPayTime(LocalDateTime.now());
            payment.setCallbackTime(LocalDateTime.now());
            payment.setUpdatedAt(LocalDateTime.now());
            paymentMapper.updateById(payment);
        }

        // 更新订单状态
        orderService.onPaySuccess(orderNo, payMethod, tradeNo);
        log.info("沙箱支付成功: orderNo={}, tradeNo={}", orderNo, tradeNo);
    }
}
