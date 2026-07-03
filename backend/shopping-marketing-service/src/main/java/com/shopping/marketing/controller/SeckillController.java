package com.shopping.marketing.controller;

import com.shopping.common.entity.SeckillActivity;
import com.shopping.common.entity.SeckillProduct;
import com.shopping.common.utils.Result;
import com.shopping.marketing.service.SeckillService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Map;

@RestController
@RequestMapping("/seckill")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class SeckillController {

    @Resource
    private SeckillService seckillService;

    @GetMapping("/activity/list")
    public Result<Map<String, Object>> getActiveActivities(
            @RequestParam(required = false) Long merchantId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> data = seckillService.getActivityList(merchantId, status, page, size);
        return Result.success(data);
    }

    @GetMapping("/activity/{id}")
    public Result<Map<String, Object>> getActivityDetail(@PathVariable Long id) {
        Map<String, Object> data = seckillService.getActivityDetail(id);
        if (data == null) {
            return Result.error("Activity not found");
        }
        return Result.success(data);
    }

    @PostMapping("/activity/create")
    public Result<SeckillActivity> createActivity(@RequestBody SeckillActivity activity) {
        SeckillActivity result = seckillService.createActivity(activity);
        return Result.success(result);
    }

    @PutMapping("/activity/update/{id}")
    public Result<SeckillActivity> updateActivity(@PathVariable Long id, @RequestBody SeckillActivity activity) {
        SeckillActivity result = seckillService.updateActivity(id, activity);
        if (result == null) {
            return Result.error("活动不存在");
        }
        return Result.success(result);
    }

    @PutMapping("/activity/status/{id}")
    public Result<Boolean> updateActivityStatus(@PathVariable Long id, @RequestParam Integer status) {
        boolean success = seckillService.updateActivityStatus(id, status);
        if (!success) {
            return Result.error("活动不存在");
        }
        return Result.success(true);
    }

    @DeleteMapping("/activity/delete/{id}")
    public Result<Boolean> deleteActivity(@PathVariable Long id) {
        boolean success = seckillService.deleteActivity(id);
        if (!success) {
            return Result.error("活动不存在");
        }
        return Result.success(true);
    }

    @PostMapping("/activity/product/add")
    public Result<SeckillProduct> addProductToActivity(@RequestBody SeckillProduct product) {
        SeckillProduct result = seckillService.addProductToActivity(product);
        return Result.success(result);
    }

    @PostMapping("/order")
    public Result<Map<String, Object>> placeOrder(@RequestParam Long activityId,
                                                    @RequestParam Long productId,
                                                    @RequestParam Long skuId,
                                                    @RequestParam Long userId,
                                                    @RequestParam Integer quantity) {
        Map<String, Object> result = seckillService.placeOrder(activityId, productId, skuId, userId, quantity);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }

    @GetMapping("/order/my")
    public Result<Map<String, Object>> getUserOrders(@RequestParam Long userId,
                                                      @RequestParam(defaultValue = "1") Integer page,
                                                      @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> data = seckillService.getUserOrders(userId, page, size);
        return Result.success(data);
    }

    @GetMapping("/order/merchant")
    public Result<Map<String, Object>> getMerchantOrders(@RequestParam Long merchantId,
                                                          @RequestParam(defaultValue = "1") Integer page,
                                                          @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> data = seckillService.getMerchantOrders(merchantId, page, size);
        return Result.success(data);
    }

    @PostMapping("/order/deliver")
    public Result<Boolean> deliverOrder(@RequestParam Long orderId, @RequestParam(required = false) String trackingNo) {
        boolean success = seckillService.deliverOrder(orderId, trackingNo);
        if (!success) {
            return Result.error("发货失败，订单状态不正确");
        }
        return Result.success(true);
    }

    @PostMapping("/stock/deduct")
    public Result<Boolean> deductStock(@RequestParam Long activityId, @RequestParam Integer quantity) {
        boolean success = seckillService.deductActivityStock(activityId, quantity);
        if (!success) {
            return Result.error("秒杀库存不足");
        }
        return Result.success(true);
    }

    @PostMapping("/stock/rollback")
    public Result<Boolean> rollbackStock(@RequestParam Long activityId, @RequestParam Integer quantity) {
        boolean success = seckillService.rollbackActivityStock(activityId, quantity);
        return Result.success(success);
    }
}
