package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.entity.OrderReview;
import com.shopping.order.service.OrderReviewService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/order/review")
public class OrderReviewController {

    @Autowired
    private OrderReviewService orderReviewService;

    @PostMapping("/add")
    public Result<Void> add(@RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.valueOf(String.valueOf(body.get("userId")));
            Long orderId = Long.valueOf(String.valueOf(body.get("orderId")));
            Long orderItemId = body.get("orderItemId") != null ? Long.valueOf(String.valueOf(body.get("orderItemId"))) : null;
            Long productId = Long.valueOf(String.valueOf(body.get("productId")));
            Long merchantId = body.get("merchantId") != null ? Long.valueOf(String.valueOf(body.get("merchantId"))) : null;
            Integer rating = Integer.valueOf(String.valueOf(body.get("rating")));
            String content = (String) body.get("content");
            String images = (String) body.get("images");
            Integer isAnonymous = body.get("isAnonymous") != null ? Integer.valueOf(String.valueOf(body.get("isAnonymous"))) : 0;
            orderReviewService.addReview(userId, orderId, orderItemId, productId, merchantId, rating, content, images, isAnonymous);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/submit")
    public Result<Void> submit(@RequestBody Map<String, Object> body) {
        try {
            Long userId = Long.valueOf(String.valueOf(body.get("userId")));
            Long orderId = Long.valueOf(String.valueOf(body.get("orderId")));
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> reviews = (List<Map<String, Object>>) body.get("reviews");
            orderReviewService.batchAddReviews(userId, orderId, reviews);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/product/{productId}")
    public Result<Map<String, Object>> productReviews(
            @PathVariable Long productId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Map<String, Object> data = orderReviewService.getByProductId(productId, page, size);
            return Result.success(data);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/order/{orderId}")
    public Result<List<OrderReview>> orderReviews(@PathVariable Long orderId) {
        try {
            List<OrderReview> list = orderReviewService.getByOrderId(orderId);
            return Result.success(list);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/merchant/list")
    public Result<Map<String, Object>> merchantReviews(
            @RequestParam Long merchantId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            Map<String, Object> data = orderReviewService.getByMerchantId(merchantId, page, size);
            return Result.success(data);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/reply")
    public Result<Void> reply(@RequestBody Map<String, Object> body) {
        try {
            Long id = Long.valueOf(String.valueOf(body.get("id")));
            Long merchantId = Long.valueOf(String.valueOf(body.get("merchantId")));
            String reply = (String) body.get("reply");
            orderReviewService.merchantReply(id, merchantId, reply);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/check")
    public Result<Boolean> check(@RequestParam Long orderId, @RequestParam Long productId) {
        try {
            boolean reviewed = orderReviewService.checkReviewed(orderId, productId);
            return Result.success(reviewed);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
