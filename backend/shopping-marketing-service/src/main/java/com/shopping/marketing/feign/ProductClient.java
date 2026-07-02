package com.shopping.marketing.feign;

import com.shopping.common.entity.Product;
import com.shopping.common.utils.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "shopping-product-service", url = "http://localhost:8082")
public interface ProductClient {

    @GetMapping("/product/detail/{id}")
    Result<Product> getById(@PathVariable("id") Long id);

    @GetMapping("/product/{id}")
    Result<Product> getProduct(@PathVariable("id") Long id);
}