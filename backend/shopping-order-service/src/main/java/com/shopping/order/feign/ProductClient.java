package com.shopping.order.feign;

import com.shopping.common.entity.Product;
import com.shopping.common.utils.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "shopping-product-service")
public interface ProductClient {

    @PostMapping("/product/addStock")
    Result<Product> addStock(@RequestParam Long productId, @RequestParam Integer quantity, @RequestParam(required = false) Long skuId);

    @PostMapping("/product/deductStock")
    Result<Product> deductStock(@RequestParam Long productId, @RequestParam Integer quantity, @RequestParam(required = false) Long skuId);

    @GetMapping("/product/detail/{id}")
    Result<Product> getById(@PathVariable("id") Long id);
}
