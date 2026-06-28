package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/payment")
public class PaymentController {

    @Autowired private PaymentService paymentService;

    /**
     * 创建支付（沙箱）
     * POST /payment/create?orderId=1&payMethod=2
     */
    @PostMapping("/create")
    public Result<Map<String, Object>> create(@RequestParam Long orderId, @RequestParam Integer payMethod) {
        try {
            String payUrl = paymentService.createPayment(orderId, payMethod);
            Map<String, Object> data = new HashMap<>();
            data.put("payUrl", payUrl);
            return Result.success(data);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 模拟支付回调
     * POST /payment/mockCallback?orderNo=Oxxx&payMethod=2
     */
    @PostMapping("/mockCallback")
    public Result<Void> mockCallback(
            @RequestParam String orderNo,
            @RequestParam Integer payMethod,
            @RequestParam(required = false) String payTradeNo) {
        try {
            paymentService.mockPayCallback(orderNo, payMethod, payTradeNo);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
