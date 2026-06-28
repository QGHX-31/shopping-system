package com.shopping.order.service;

import com.shopping.order.entity.Payment;

public interface PaymentService {
    /**
     * 创建支付记录（沙箱模拟：直接返回成功 URL）
     */
    String createPayment(Long orderId, Integer payMethod);

    /**
     * 模拟支付回调
     */
    void mockPayCallback(String orderNo, Integer payMethod, String payTradeNo);
}
