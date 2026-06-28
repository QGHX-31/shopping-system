package com.shopping.order.feign;

import com.shopping.common.utils.Result;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "shopping-user-service")
public interface UserClient {

    @PostMapping("/message/send")
    Result<Void> sendMessage(@RequestParam Long userId,
                             @RequestParam String title,
                             @RequestParam String content,
                             @RequestParam Integer type);
}
