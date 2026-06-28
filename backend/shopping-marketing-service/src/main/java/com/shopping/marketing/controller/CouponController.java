package com.shopping.marketing.controller;

import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.entity.UserCoupon;
import com.shopping.common.utils.Result;
import com.shopping.marketing.service.CouponService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/coupon")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class CouponController {

    @Resource
    private CouponService couponService;

    @GetMapping("/template/active")
    public Result<Map<String, Object>> getActiveTemplates() {
        Map<String, Object> data = couponService.getActiveTemplates();
        return Result.success(data);
    }
    
    @GetMapping("/template/platform")
    public Result<Map<String, Object>> getPlatformTemplates(@RequestParam(defaultValue = "1") Integer page,
                                                             @RequestParam(defaultValue = "20") Integer size) {
        Map<String, Object> data = couponService.getPlatformTemplates(page, size);
        return Result.success(data);
    }

    @PostMapping("/template/create")
    public Result<CouponTemplate> createTemplate(@RequestBody CouponTemplate template) {
        CouponTemplate result = couponService.createTemplate(template);
        return Result.success(result);
    }
    
    @PutMapping("/template/{id}/status")
    public Result<Boolean> updateTemplateStatus(@PathVariable Long id, @RequestParam Integer status) {
        boolean result = couponService.updateTemplateStatus(id, status);
        return Result.success(result);
    }

    @GetMapping("/template/merchant")
    public Result<Map<String, Object>> getMerchantTemplates(@RequestParam Long merchantId,
                                                              @RequestParam(defaultValue = "1") Integer page,
                                                              @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> data = couponService.getMerchantTemplates(merchantId, page, size);
        return Result.success(data);
    }

    @PostMapping("/receive")
    public Result<Map<String, Object>> receiveCoupon(@RequestParam Long userId,
                                                      @RequestParam Long templateId) {
        Map<String, Object> result = couponService.receiveCoupon(userId, templateId);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }

    @GetMapping("/mine")
    public Result<Map<String, Object>> getUserCoupons(@RequestParam Long userId,
                                                        @RequestParam(required = false) Integer status,
                                                        @RequestParam(defaultValue = "1") Integer page,
                                                        @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> data = couponService.getUserCoupons(userId, status, page, size);
        return Result.success(data);
    }
    
    @GetMapping("/user/available")
    public Result<List<UserCoupon>> getAvailableCoupons(@RequestParam Long userId,
                                                          @RequestParam(required = false) BigDecimal orderAmount,
                                                          @RequestParam(required = false) Long merchantId,
                                                          @RequestParam(required = false) List<Long> productIds,
                                                          @RequestParam(required = false) List<Long> categoryIds) {
        List<UserCoupon> data = couponService.getAvailableCoupons(userId, orderAmount, merchantId, productIds, categoryIds);
        return Result.success(data);
    }
    
    @PostMapping("/check-usable")
    public Result<Map<String, Object>> checkCouponUsable(@RequestParam Long userCouponId,
                                                          @RequestParam Long userId,
                                                          @RequestParam(required = false) BigDecimal orderAmount,
                                                          @RequestParam(required = false) Long merchantId,
                                                          @RequestParam(required = false) List<Long> productIds,
                                                          @RequestParam(required = false) List<Long> categoryIds) {
        Map<String, Object> result = couponService.checkCouponUsable(userCouponId, userId, orderAmount, merchantId, productIds, categoryIds);
        return Result.success(result);
    }

    @PostMapping("/use")
    public Result<Map<String, Object>> useCoupon(@RequestParam Long userCouponId,
                                                  @RequestParam String orderNo) {
        Map<String, Object> result = couponService.useCoupon(userCouponId, orderNo);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }

    @GetMapping("/calc")
    public Result<Map<String, Object>> calculateDiscount(@RequestParam Long userCouponId,
                                                          @RequestParam BigDecimal orderAmount) {
        Map<String, Object> result = couponService.calculateDiscount(userCouponId, orderAmount);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }
    
    @PostMapping("/best-discount")
    public Result<Map<String, Object>> calculateBestDiscount(@RequestParam Long userId,
                                                              @RequestParam BigDecimal orderAmount,
                                                              @RequestParam(required = false) Long merchantId,
                                                              @RequestParam(required = false) List<Long> productIds,
                                                              @RequestParam(required = false) List<Long> categoryIds) {
        Map<String, Object> result = couponService.calculateBestDiscount(userId, orderAmount, merchantId, productIds, categoryIds);
        return Result.success(result);
    }
    
    @GetMapping("/receivable")
    public Result<List<CouponTemplate>> getReceivableTemplates(@RequestParam Long userId,
                                                                @RequestParam(required = false) Long merchantId,
                                                                @RequestParam(required = false) List<Long> productIds,
                                                                @RequestParam(required = false) List<Long> categoryIds) {
        List<CouponTemplate> result = couponService.getReceivableTemplates(userId, merchantId, productIds, categoryIds);
        return Result.success(result);
    }
    
    @PostMapping("/receive-all")
    public Result<Map<String, Object>> receiveAllAvailableCoupons(@RequestParam Long userId,
                                                                   @RequestParam(required = false) Long merchantId,
                                                                   @RequestParam(required = false) List<Long> productIds,
                                                                   @RequestParam(required = false) List<Long> categoryIds) {
        Map<String, Object> result = couponService.receiveAllAvailableCoupons(userId, merchantId, productIds, categoryIds);
        return Result.success(result);
    }
}
