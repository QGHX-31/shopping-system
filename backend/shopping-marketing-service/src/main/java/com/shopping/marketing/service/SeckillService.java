package com.shopping.marketing.service;

import com.shopping.common.entity.SeckillActivity;
import com.shopping.common.entity.SeckillOrder;
import com.shopping.common.entity.SeckillProduct;

import java.util.List;
import java.util.Map;

public interface SeckillService {
    
    Map<String, Object> getActiveActivities();
    
    Map<String, Object> getActivityList(Long merchantId, Integer status, Integer page, Integer size);
    
    Map<String, Object> getActivityDetail(Long id);
    
    SeckillActivity createActivity(SeckillActivity activity);
    
    SeckillActivity updateActivity(Long id, SeckillActivity activity);
    
    boolean updateActivityStatus(Long id, Integer status);
    
    boolean deleteActivity(Long id);
    
    SeckillProduct addProductToActivity(SeckillProduct product);
    
    Map<String, Object> placeOrder(Long activityId, Long productId, Long skuId, Long userId, Integer quantity);
    
    Map<String, Object> getUserOrders(Long userId, Integer page, Integer size);
    
    Map<String, Object> getMerchantOrders(Long merchantId, Integer page, Integer size);
    
    boolean deliverOrder(Long orderId, String trackingNo);
}
