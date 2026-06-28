package com.shopping.order.service;

import com.shopping.order.entity.OrderReview;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface OrderReviewService {

    void addReview(Long userId, Long orderId, Long orderItemId, Long productId, Long merchantId, Integer rating, String content, String images, Integer isAnonymous);

    Map<String, Object> getByProductId(Long productId, Integer page, Integer size);

    List<OrderReview> getByOrderId(Long orderId);

    Map<String, Object> getByMerchantId(Long merchantId, Integer page, Integer size);

    void merchantReply(Long id, Long merchantId, String reply);

    boolean checkReviewed(Long orderId, Long productId);
}
