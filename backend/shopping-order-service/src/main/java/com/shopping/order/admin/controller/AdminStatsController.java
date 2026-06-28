package com.shopping.order.admin.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.admin.service.AdminStatsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/admin/stats")
public class AdminStatsController {

    @Autowired
    private AdminStatsService adminStatsService;

    @GetMapping("/overview")
    public Result<Map<String, Object>> getOverview() {
        try {
            return Result.success(adminStatsService.getOverview());
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/sales-trend")
    public Result<Map<String, Object>> getSalesTrend(@RequestParam(defaultValue = "7") Integer days) {
        try {
            return Result.success(adminStatsService.getSalesTrend(days));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/order-status")
    public Result<Map<String, Object>> getOrderStatusStats() {
        try {
            return Result.success(adminStatsService.getOrderStatusStats());
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/hot-products")
    public Result<java.util.List<Map<String, Object>>> getHotProducts(@RequestParam(defaultValue = "10") Integer limit) {
        try {
            return Result.success(adminStatsService.getHotProducts(limit));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/realtime")
    public Result<Map<String, Object>> getRealtimeStats() {
        try {
            return Result.success(adminStatsService.getRealtimeStats());
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
