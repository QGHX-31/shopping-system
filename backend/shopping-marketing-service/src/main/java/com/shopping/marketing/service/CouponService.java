package com.shopping.marketing.service;

import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.entity.UserCoupon;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public interface CouponService {
    
    Map<String, Object> getActiveTemplates();
    
    Map<String, Object> getPlatformTemplates(Integer page, Integer size);
    
    Map<String, Object> getMerchantTemplates(Long merchantId, Integer page, Integer size);
    
    CouponTemplate createTemplate(CouponTemplate template);
    
    boolean updateTemplateStatus(Long templateId, Integer status);
    
    Map<String, Object> receiveCoupon(Long userId, Long templateId);
    
    Map<String, Object> getUserCoupons(Long userId, Integer status, Integer page, Integer size);
    
    List<UserCoupon> getAvailableCoupons(Long userId, BigDecimal orderAmount, Long merchantId, List<Long> productIds, List<Long> categoryIds);
    
    Map<String, Object> checkCouponUsable(Long userCouponId, Long userId, BigDecimal orderAmount, Long merchantId, List<Long> productIds, List<Long> categoryIds);
    
    Map<String, Object> useCoupon(Long userCouponId, String orderNo);

    boolean lockCoupons(List<Long> userCouponIds, String orderNo);

    boolean unlockCouponsByOrderNo(String orderNo);

    Map<String, Object> calculateDiscount(Long userCouponId, BigDecimal orderAmount);
    
    Map<String, Object> calculateBestDiscount(Long userId, BigDecimal orderAmount, Long merchantId, List<Long> productIds, List<Long> categoryIds);
    
    Map<String, Object> receiveAllAvailableCoupons(Long userId, Long merchantId, List<Long> productIds, List<Long> categoryIds);
    
    List<CouponTemplate> getReceivableTemplates(Long userId, Long merchantId, List<Long> productIds, List<Long> categoryIds);
}
