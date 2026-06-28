package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.service.MerchantDashboardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/order/merchant")
public class MerchantDashboardController {

    @Autowired
    private MerchantDashboardService merchantDashboardService;

    @GetMapping("/dashboard")
    public Result<Map<String, Object>> getDashboardData(@RequestParam Long merchantId) {
        try {
            return Result.success(merchantDashboardService.getDashboardData(merchantId));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/sales-trend")
    public Result<Map<String, Object>> getSalesTrend(
            @RequestParam Long merchantId,
            @RequestParam(defaultValue = "7") Integer days) {
        try {
            return Result.success(merchantDashboardService.getSalesTrend(merchantId, days));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/order-distribution")
    public Result<List<Map<String, Object>>> getOrderStatusDistribution(@RequestParam Long merchantId) {
        try {
            return Result.success(merchantDashboardService.getOrderStatusDistribution(merchantId));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/top-products")
    public Result<List<Map<String, Object>>> getTopProducts(
            @RequestParam Long merchantId,
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            return Result.success(merchantDashboardService.getTopProducts(merchantId, limit));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
