package com.shopping.order.feign;

import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.utils.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "shopping-marketing-service")
public interface MarketingClient {

    @GetMapping("/coupon/template/{id}")
    Result<CouponTemplate> getCouponById(@PathVariable("id") Long id);
}
