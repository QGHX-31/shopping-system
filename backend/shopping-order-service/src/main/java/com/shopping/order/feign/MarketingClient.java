package com.shopping.order.feign;

import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.utils.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@FeignClient(name = "shopping-marketing-service")
public interface MarketingClient {

    @GetMapping("/coupon/template/{id}")
    Result<CouponTemplate> getCouponById(@PathVariable("id") Long id);

    @GetMapping("/seckill/activity/{id}")
    Result<Map<String, Object>> getSeckillActivity(@PathVariable("id") Long id);

    @PostMapping("/seckill/stock/deduct")
    Result<Boolean> deductSeckillStock(@RequestParam("activityId") Long activityId,
                                        @RequestParam("quantity") Integer quantity);

    @PostMapping("/seckill/stock/rollback")
    Result<Boolean> rollbackSeckillStock(@RequestParam("activityId") Long activityId,
                                          @RequestParam("quantity") Integer quantity);
}
