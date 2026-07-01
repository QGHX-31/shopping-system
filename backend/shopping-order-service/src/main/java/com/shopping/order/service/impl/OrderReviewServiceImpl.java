package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.exception.BusinessException;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.entity.OrderReview;
import com.shopping.order.mapper.OrderItemMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.mapper.OrderReviewMapper;
import com.shopping.order.service.OrderReviewService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class OrderReviewServiceImpl implements OrderReviewService {

    @Autowired
    private OrderReviewMapper orderReviewMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addReview(Long userId, Long orderId, Long orderItemId, Long productId, Long merchantId, Integer rating, String content, String images, Integer isAnonymous) {
        if (userId == null || orderId == null || productId == null || rating == null) {
            throw new BusinessException("参数不完整");
        }
        if (rating < 1 || rating > 5) {
            throw new BusinessException("评分必须在1-5之间");
        }

        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException("无权评价此订单");
        }
        if (order.getStatus() != 3) {
            throw new BusinessException("只有已完成的订单才能评价");
        }

        if (checkReviewed(orderId, productId)) {
            throw new BusinessException("该商品已评价");
        }

        OrderReview review = new OrderReview();
        review.setUserId(userId);
        review.setOrderId(orderId);
        review.setOrderItemId(orderItemId);
        review.setProductId(productId);
        review.setMerchantId(merchantId);
        review.setRating(new BigDecimal(rating));
        review.setContent(content);
        review.setImages(images);
        review.setIsAnonymous(isAnonymous != null ? isAnonymous : 0);
        review.setIsTop(0);
        review.setStatus(1);
        review.setCreatedAt(LocalDateTime.now());
        review.setUpdatedAt(LocalDateTime.now());
        orderReviewMapper.insert(review);

        log.info("添加评价成功: orderId={}, productId={}, rating={}", orderId, productId, rating);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchAddReviews(Long userId, Long orderId, List<Map<String, Object>> reviews) {
        if (userId == null || orderId == null || reviews == null || reviews.isEmpty()) {
            throw new BusinessException("参数不完整");
        }

        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new BusinessException("无权评价此订单");
        }
        if (order.getStatus() != 3) {
            throw new BusinessException("只有已完成的订单才能评价");
        }

        List<OrderItem> orderItems = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, orderId));
        Map<Long, OrderItem> itemMap = new HashMap<>();
        for (OrderItem item : orderItems) {
            itemMap.put(item.getProductId(), item);
        }

        for (Map<String, Object> reviewMap : reviews) {
            Long productId = Long.valueOf(String.valueOf(reviewMap.get("productId")));
            Integer rating = Integer.valueOf(String.valueOf(reviewMap.get("rating")));
            String content = (String) reviewMap.get("content");
            String images = reviewMap.get("images") != null ? String.valueOf(reviewMap.get("images")) : null;
            Integer anonymous = reviewMap.get("anonymous") != null ?
                    (Boolean.TRUE.equals(reviewMap.get("anonymous")) ? 1 : 0) : 0;

            if (rating < 1 || rating > 5) {
                throw new BusinessException("评分必须在1-5之间");
            }

            if (checkReviewed(orderId, productId)) {
                throw new BusinessException("商品已评价，请勿重复评价");
            }

            OrderItem orderItem = itemMap.get(productId);
            Long orderItemId = orderItem != null ? orderItem.getId() : null;
            Long merchantId = orderItem != null ? orderItem.getMerchantId() : null;

            OrderReview review = new OrderReview();
            review.setUserId(userId);
            review.setOrderId(orderId);
            review.setOrderItemId(orderItemId);
            review.setProductId(productId);
            review.setMerchantId(merchantId);
            review.setRating(new BigDecimal(rating));
            review.setContent(content);
            review.setImages(images);
            review.setIsAnonymous(anonymous);
            review.setIsTop(0);
            review.setStatus(1);
            review.setCreatedAt(LocalDateTime.now());
            review.setUpdatedAt(LocalDateTime.now());
            orderReviewMapper.insert(review);
        }

        log.info("批量评价成功: orderId={}, count={}", orderId, reviews.size());
    }

    @Override
    public Map<String, Object> getByProductId(Long productId, Integer page, Integer size) {
        if (productId == null) {
            throw new BusinessException("商品ID不能为空");
        }
        Page<OrderReview> p = new Page<>(page, size);
        LambdaQueryWrapper<OrderReview> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderReview::getProductId, productId)
                .eq(OrderReview::getStatus, 1)
                .orderByDesc(OrderReview::getIsTop)
                .orderByDesc(OrderReview::getCreatedAt);
        Page<OrderReview> result = orderReviewMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    public List<OrderReview> getByOrderId(Long orderId) {
        if (orderId == null) {
            throw new BusinessException("订单ID不能为空");
        }
        LambdaQueryWrapper<OrderReview> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderReview::getOrderId, orderId)
                .orderByDesc(OrderReview::getCreatedAt);
        return orderReviewMapper.selectList(wrapper);
    }

    @Override
    public Map<String, Object> getByMerchantId(Long merchantId, Integer page, Integer size) {
        if (merchantId == null) {
            throw new BusinessException("商家ID不能为空");
        }
        Page<OrderReview> p = new Page<>(page, size);
        LambdaQueryWrapper<OrderReview> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderReview::getMerchantId, merchantId)
                .eq(OrderReview::getStatus, 1)
                .orderByDesc(OrderReview::getCreatedAt);
        Page<OrderReview> result = orderReviewMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void merchantReply(Long id, Long merchantId, String reply) {
        if (id == null || merchantId == null) {
            throw new BusinessException("参数不完整");
        }
        OrderReview review = orderReviewMapper.selectById(id);
        if (review == null) {
            throw new BusinessException("评价不存在");
        }
        if (!review.getMerchantId().equals(merchantId)) {
            throw new BusinessException("无权回复此评价");
        }

        review.setReplyContent(reply);
        review.setReplyTime(LocalDateTime.now());
        review.setUpdatedAt(LocalDateTime.now());
        orderReviewMapper.updateById(review);

        log.info("商家回复评价成功: reviewId={}, merchantId={}", id, merchantId);
    }

    @Override
    public boolean checkReviewed(Long orderId, Long productId) {
        if (orderId == null || productId == null) {
            return false;
        }
        LambdaQueryWrapper<OrderReview> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderReview::getOrderId, orderId)
                .eq(OrderReview::getProductId, productId);
        Long count = orderReviewMapper.selectCount(wrapper);
        return count != null && count > 0;
    }
}
