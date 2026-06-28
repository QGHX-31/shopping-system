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
    public Result<Map<String, Object>> getActiveActivities() {
        Map<String, Object> data = seckillService.getActiveActivities();
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
}
