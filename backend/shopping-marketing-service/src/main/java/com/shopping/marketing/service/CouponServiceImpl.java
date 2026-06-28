package com.shopping.marketing.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.entity.Product;
import com.shopping.common.entity.UserCoupon;
import com.shopping.marketing.mapper.CouponTemplateMapper;
import com.shopping.marketing.mapper.ProductMapper;
import com.shopping.marketing.mapper.UserCouponMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class CouponServiceImpl implements CouponService {

    @Resource
    private CouponTemplateMapper couponTemplateMapper;
    
    @Resource
    private UserCouponMapper userCouponMapper;
    
    @Resource
    private ProductMapper productMapper;
    
    private final ObjectMapper objectMapper = new ObjectMapper();

    private void fillTemplateInfo(List<UserCoupon> coupons) {
        if (coupons == null || coupons.isEmpty()) return;
        Set<Long> templateIds = coupons.stream()
            .map(UserCoupon::getTemplateId)
            .filter(Objects::nonNull)
            .collect(Collectors.toSet());
        if (templateIds.isEmpty()) {
            for (UserCoupon coupon : coupons) {
                if (coupon.getCouponLevel() == null) {
                    coupon.setCouponLevel(coupon.getMerchantId() != null ? 2 : 1);
                }
                if (coupon.getMutuallyExclusive() == null) {
                    coupon.setMutuallyExclusive(1);
                }
            }
            return;
        }
        List<CouponTemplate> templates = couponTemplateMapper.selectBatchIds(templateIds);
        Map<Long, CouponTemplate> templateMap = templates.stream()
            .collect(Collectors.toMap(CouponTemplate::getId, t -> t));
        for (UserCoupon coupon : coupons) {
            CouponTemplate template = templateMap.get(coupon.getTemplateId());
            if (template != null) {
                coupon.setMerchantId(template.getMerchantId());
                coupon.setCouponLevel(template.getCouponLevel() != null ? template.getCouponLevel() 
                    : (template.getMerchantId() != null ? 2 : 1));
                coupon.setMutuallyExclusive(template.getMutuallyExclusive() != null ? template.getMutuallyExclusive() : 1);
                coupon.setScopeType(template.getScopeType());
                coupon.setScopeIds(template.getScopeIds());
            } else {
                if (coupon.getCouponLevel() == null) {
                    coupon.setCouponLevel(coupon.getMerchantId() != null ? 2 : 1);
                }
                if (coupon.getMutuallyExclusive() == null) {
                    coupon.setMutuallyExclusive(1);
                }
            }
        }
    }

    @Override
    public Map<String, Object> getActiveTemplates() {
        LambdaQueryWrapper<CouponTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CouponTemplate::getStatus, 1)
               .le(CouponTemplate::getStartTime, LocalDateTime.now())
               .ge(CouponTemplate::getEndTime, LocalDateTime.now())
               .gt(CouponTemplate::getRemainingCount, 0)
               .orderByDesc(CouponTemplate::getCreatedAt);
        List<CouponTemplate> templates = couponTemplateMapper.selectList(wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", templates);
        result.put("total", templates.size());
        return result;
    }
    
    @Override
    public Map<String, Object> getPlatformTemplates(Integer page, Integer size) {
        Page<CouponTemplate> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<CouponTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.isNull(CouponTemplate::getMerchantId)
               .eq(CouponTemplate::getStatus, 1)
               .le(CouponTemplate::getStartTime, LocalDateTime.now())
               .ge(CouponTemplate::getEndTime, LocalDateTime.now())
               .gt(CouponTemplate::getRemainingCount, 0)
               .orderByDesc(CouponTemplate::getCreatedAt);
        Page<CouponTemplate> resultPage = couponTemplateMapper.selectPage(pageObj, wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    @Override
    @Transactional
    public CouponTemplate createTemplate(CouponTemplate template) {
        template.setStatus(0);
        template.setCreatedAt(LocalDateTime.now());
        template.setUpdatedAt(LocalDateTime.now());
        if (template.getRemainingCount() == null) {
            template.setRemainingCount(template.getTotalCount());
        }
        if (template.getScopeType() == null) {
            template.setScopeType(template.getMerchantId() != null ? 2 : 1);
        }
        if (template.getCouponLevel() == null) {
            template.setCouponLevel(template.getMerchantId() != null ? 2 : 1);
        }
        if (template.getMutuallyExclusive() == null) {
            template.setMutuallyExclusive(1);
        }
        if (template.getUserType() == null) {
            template.setUserType(0);
        }
        if (template.getMemberLevel() == null) {
            template.setMemberLevel(0);
        }
        couponTemplateMapper.insert(template);
        return template;
    }
    
    @Override
    public boolean updateTemplateStatus(Long templateId, Integer status) {
        CouponTemplate template = couponTemplateMapper.selectById(templateId);
        if (template == null) {
            return false;
        }
        template.setStatus(status);
        template.setUpdatedAt(LocalDateTime.now());
        return couponTemplateMapper.updateById(template) > 0;
    }

    @Override
    public Map<String, Object> getMerchantTemplates(Long merchantId, Integer page, Integer size) {
        Page<CouponTemplate> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<CouponTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CouponTemplate::getMerchantId, merchantId)
               .orderByDesc(CouponTemplate::getCreatedAt);
        Page<CouponTemplate> resultPage = couponTemplateMapper.selectPage(pageObj, wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> receiveCoupon(Long userId, Long templateId) {
        Map<String, Object> result = new HashMap<>();
        
        CouponTemplate template = couponTemplateMapper.selectById(templateId);
        if (template == null) {
            result.put("success", false);
            result.put("message", "优惠券不存在");
            return result;
        }
        
        if (template.getStatus() != 1) {
            result.put("success", false);
            result.put("message", "优惠券未启用");
            return result;
        }
        
        if (template.getRemainingCount() <= 0) {
            result.put("success", false);
            result.put("message", "优惠券已领完");
            return result;
        }
        
        if (template.getStartTime() != null && template.getStartTime().isAfter(LocalDateTime.now())) {
            result.put("success", false);
            result.put("message", "活动未开始");
            return result;
        }
        if (template.getEndTime() != null && template.getEndTime().isBefore(LocalDateTime.now())) {
            result.put("success", false);
            result.put("message", "活动已结束");
            return result;
        }
        
        Integer userType = template.getUserType();
        if (userType != null && userType == 1) {
            LambdaQueryWrapper<UserCoupon> orderWrapper = new LambdaQueryWrapper<>();
            orderWrapper.eq(UserCoupon::getUserId, userId);
            Long count = userCouponMapper.selectCount(orderWrapper);
            if (count > 0) {
                result.put("success", false);
                result.put("message", "仅限新用户领取");
                return result;
            }
        }
        
        Integer perUserLimit = template.getPerUserLimit();
        if (perUserLimit == null || perUserLimit <= 0) {
            perUserLimit = 1;
        }
        LambdaQueryWrapper<UserCoupon> userCouponWrapper = new LambdaQueryWrapper<>();
        userCouponWrapper.eq(UserCoupon::getUserId, userId)
                        .eq(UserCoupon::getTemplateId, templateId);
        Long userReceivedCount = userCouponMapper.selectCount(userCouponWrapper);
        
        if (perUserLimit > 0 && userReceivedCount >= perUserLimit) {
            result.put("success", false);
            result.put("message", "已达领取上限");
            return result;
        }
        
        UserCoupon existUnused = userCouponMapper.selectOne(new LambdaQueryWrapper<UserCoupon>()
            .eq(UserCoupon::getUserId, userId)
            .eq(UserCoupon::getTemplateId, templateId)
            .eq(UserCoupon::getStatus, 0)
            .last("LIMIT 1"));
        if (existUnused != null) {
            result.put("success", false);
            result.put("message", "已领取过该优惠券");
            return result;
        }
        
        UserCoupon userCoupon = new UserCoupon();
        userCoupon.setUserId(userId);
        userCoupon.setTemplateId(templateId);
        userCoupon.setCouponCode("C" + System.currentTimeMillis() + new Random().nextInt(1000));
        userCoupon.setName(template.getName());
        userCoupon.setType(template.getType());
        userCoupon.setDiscountAmount(template.getDiscountAmount());
        userCoupon.setMinAmount(template.getMinAmount());
        userCoupon.setStatus(0);
        userCoupon.setReceiveTime(LocalDateTime.now());
        userCoupon.setExpireTime(template.getEndTime());
        userCouponMapper.insert(userCoupon);
        
        template.setRemainingCount(template.getRemainingCount() - 1);
        template.setUpdatedAt(LocalDateTime.now());
        couponTemplateMapper.updateById(template);
        
        result.put("success", true);
        result.put("userCoupon", userCoupon);
        return result;
    }

    @Override
    public Map<String, Object> getUserCoupons(Long userId, Integer status, Integer page, Integer size) {
        Page<UserCoupon> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<UserCoupon> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserCoupon::getUserId, userId);
        if (status != null) {
            wrapper.eq(UserCoupon::getStatus, status);
        }
        wrapper.orderByDesc(UserCoupon::getReceiveTime);
        Page<UserCoupon> resultPage = userCouponMapper.selectPage(pageObj, wrapper);
        
        fillTemplateInfo(resultPage.getRecords());
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", page);
        result.put("size", size);
        return result;
    }
    
    @Override
    public List<UserCoupon> getAvailableCoupons(Long userId, BigDecimal orderAmount, 
                                                 Long merchantId, List<Long> productIds, 
                                                 List<Long> categoryIds) {
        LambdaQueryWrapper<UserCoupon> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserCoupon::getUserId, userId)
               .eq(UserCoupon::getStatus, 0)
               .isNull(UserCoupon::getLockOrderNo)
               .gt(UserCoupon::getExpireTime, LocalDateTime.now())
               .orderByDesc(UserCoupon::getDiscountAmount);
        List<UserCoupon> allCoupons = userCouponMapper.selectList(wrapper);
        
        List<UserCoupon> available = new ArrayList<>();
        for (UserCoupon coupon : allCoupons) {
            Map<String, Object> checkResult = checkCouponUsable(coupon.getId(), userId, 
                orderAmount, merchantId, productIds, categoryIds);
            if (Boolean.TRUE.equals(checkResult.get("usable"))) {
                available.add(coupon);
            }
        }
        fillTemplateInfo(available);
        return available;
    }
    
    @Override
    public Map<String, Object> checkCouponUsable(Long userCouponId, Long userId, 
                                                  BigDecimal orderAmount, Long merchantId,
                                                  List<Long> productIds, List<Long> categoryIds) {
        Map<String, Object> result = new HashMap<>();
        result.put("usable", false);
        result.put("reason", "");
        
        UserCoupon userCoupon = userCouponMapper.selectById(userCouponId);
        if (userCoupon == null) {
            result.put("reason", "优惠券不存在");
            return result;
        }
        
        if (userCoupon.getStatus() != 0) {
            result.put("reason", "优惠券已使用或已过期");
            return result;
        }

        if (userCoupon.getLockOrderNo() != null && !userCoupon.getLockOrderNo().isEmpty()) {
            result.put("reason", "优惠券已被其他订单占用");
            return result;
        }

        if (userCoupon.getExpireTime() != null && userCoupon.getExpireTime().isBefore(LocalDateTime.now())) {
            result.put("reason", "优惠券已过期");
            return result;
        }
        
        CouponTemplate template = couponTemplateMapper.selectById(userCoupon.getTemplateId());
        if (template == null) {
            result.put("reason", "优惠券模板不存在");
            return result;
        }
        
        if (template.getStatus() != 1) {
            result.put("reason", "优惠券已下架");
            return result;
        }
        
        BigDecimal minAmount = userCoupon.getMinAmount();
        if (minAmount != null && minAmount.compareTo(BigDecimal.ZERO) > 0 
            && orderAmount != null && orderAmount.compareTo(minAmount) < 0) {
            result.put("reason", "未满足最低消费金额 " + minAmount + " 元");
            return result;
        }
        
        Integer scopeType = template.getScopeType();
        if (scopeType != null) {
            if (scopeType == 2) {
                if (merchantId != null && template.getMerchantId() != null && !template.getMerchantId().equals(merchantId)) {
                    result.put("reason", "仅限指定店铺使用");
                    return result;
                }
            } else if (scopeType == 3) {
                List<Long> scopeProductIds = parseScopeIds(template.getScopeIds());
                if (scopeProductIds != null && !scopeProductIds.isEmpty() && productIds != null && !productIds.isEmpty()) {
                    boolean hasMatch = productIds.stream().anyMatch(scopeProductIds::contains);
                    if (!hasMatch) {
                        result.put("reason", "仅限指定商品使用");
                        return result;
                    }
                }
            } else if (scopeType == 4) {
                List<Long> scopeCategoryIds = parseScopeIds(template.getScopeIds());
                if (scopeCategoryIds != null && !scopeCategoryIds.isEmpty() && categoryIds != null && !categoryIds.isEmpty()) {
                    boolean hasMatch = categoryIds.stream().anyMatch(scopeCategoryIds::contains);
                    if (!hasMatch) {
                        result.put("reason", "仅限指定类目使用");
                        return result;
                    }
                }
            }
        }
        
        result.put("usable", true);
        result.put("template", template);
        return result;
    }
    
    private List<Long> parseScopeIds(String scopeIds) {
        if (scopeIds == null || scopeIds.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.readValue(scopeIds, new TypeReference<List<Long>>() {});
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    @Transactional
    public Map<String, Object> useCoupon(Long userCouponId, String orderNo) {
        Map<String, Object> result = new HashMap<>();
        
        UserCoupon userCoupon = userCouponMapper.selectById(userCouponId);
        if (userCoupon == null) {
            result.put("success", false);
            result.put("message", "用户优惠券不存在");
            return result;
        }
        
        if (userCoupon.getStatus() != 0) {
            result.put("success", false);
            result.put("message", "优惠券已使用或已过期");
            return result;
        }
        
        if (userCoupon.getExpireTime() != null && userCoupon.getExpireTime().isBefore(LocalDateTime.now())) {
            userCoupon.setStatus(2);
            userCouponMapper.updateById(userCoupon);
            result.put("success", false);
            result.put("message", "优惠券已过期");
            return result;
        }
        
        userCoupon.setStatus(1);
        userCoupon.setUseTime(LocalDateTime.now());
        userCoupon.setOrderNo(orderNo);
        userCouponMapper.updateById(userCoupon);
        
        result.put("success", true);
        result.put("userCoupon", userCoupon);
        return result;
    }

    @Override
    @Transactional
    public boolean lockCoupons(List<Long> userCouponIds, String orderNo) {
        if (userCouponIds == null || userCouponIds.isEmpty()) return true;
        for (Long id : userCouponIds) {
            UserCoupon coupon = userCouponMapper.selectById(id);
            if (coupon == null || coupon.getStatus() != 0) {
                throw new RuntimeException("优惠券不可用，id=" + id);
            }
            if (coupon.getLockOrderNo() != null && !coupon.getLockOrderNo().isEmpty()) {
                throw new RuntimeException("优惠券已被占用，id=" + id);
            }
            coupon.setLockOrderNo(orderNo);
            userCouponMapper.updateById(coupon);
        }
        return true;
    }

    @Override
    @Transactional
    public boolean unlockCouponsByOrderNo(String orderNo) {
        if (orderNo == null || orderNo.isEmpty()) return true;
        LambdaQueryWrapper<UserCoupon> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserCoupon::getLockOrderNo, orderNo);
        List<UserCoupon> lockedCoupons = userCouponMapper.selectList(wrapper);
        for (UserCoupon coupon : lockedCoupons) {
            coupon.setLockOrderNo(null);
            userCouponMapper.updateById(coupon);
        }
        return true;
    }

    @Override
    public Map<String, Object> calculateDiscount(Long userCouponId, BigDecimal orderAmount) {
        Map<String, Object> result = new HashMap<>();
        
        UserCoupon userCoupon = userCouponMapper.selectById(userCouponId);
        if (userCoupon == null) {
            result.put("success", false);
            result.put("message", "用户优惠券不存在");
            return result;
        }
        
        if (userCoupon.getStatus() != 0) {
            result.put("success", false);
            result.put("message", "优惠券不可用");
            return result;
        }
        
        if (userCoupon.getExpireTime() != null && userCoupon.getExpireTime().isBefore(LocalDateTime.now())) {
            result.put("success", false);
            result.put("message", "优惠券已过期");
            return result;
        }
        
        BigDecimal discount = BigDecimal.ZERO;
        Integer type = userCoupon.getType();
        BigDecimal discountAmount = userCoupon.getDiscountAmount();
        BigDecimal minAmount = userCoupon.getMinAmount();
        
        if (minAmount != null && minAmount.compareTo(BigDecimal.ZERO) > 0 
            && orderAmount.compareTo(minAmount) < 0) {
            result.put("success", false);
            result.put("message", "未满足最低消费金额");
            return result;
        }
        
        if (type == null || type == 1) {
            discount = discountAmount;
        } else if (type == 2) {
            BigDecimal rate = discountAmount;
            discount = orderAmount.multiply(BigDecimal.ONE.subtract(rate));
        } else if (type == 3) {
            discount = discountAmount;
        }
        
        if (discount.compareTo(orderAmount) > 0) {
            discount = orderAmount.subtract(new BigDecimal("0.01"));
        }
        if (discount.compareTo(BigDecimal.ZERO) < 0) {
            discount = BigDecimal.ZERO;
        }
        
        result.put("success", true);
        result.put("discount", discount);
        result.put("finalAmount", orderAmount.subtract(discount));
        return result;
    }
    
    @Override
    public Map<String, Object> calculateBestDiscount(Long userId, BigDecimal orderAmount,
                                                      Long merchantId, List<Long> productIds,
                                                      List<Long> categoryIds) {
        Map<String, Object> result = new HashMap<>();
        
        List<UserCoupon> availableCoupons = getAvailableCoupons(userId, orderAmount, 
            merchantId, productIds, categoryIds);
        
        if (availableCoupons.isEmpty()) {
            result.put("bestCoupon", null);
            result.put("bestDiscount", BigDecimal.ZERO);
            result.put("finalAmount", orderAmount);
            result.put("availableCoupons", List.of());
            return result;
        }
        
        UserCoupon bestCoupon = null;
        BigDecimal bestDiscount = BigDecimal.ZERO;
        
        for (UserCoupon coupon : availableCoupons) {
            Map<String, Object> calcResult = calculateDiscount(coupon.getId(), orderAmount);
            if (Boolean.TRUE.equals(calcResult.get("success"))) {
                BigDecimal discount = (BigDecimal) calcResult.get("discount");
                if (discount.compareTo(bestDiscount) > 0) {
                    bestDiscount = discount;
                    bestCoupon = coupon;
                }
            }
        }
        
        result.put("bestCoupon", bestCoupon);
        result.put("bestDiscount", bestDiscount);
        result.put("finalAmount", orderAmount.subtract(bestDiscount));
        result.put("availableCoupons", availableCoupons);
        return result;
    }
    
    @Override
    public List<CouponTemplate> getReceivableTemplates(Long userId, Long merchantId,
                                                        List<Long> productIds, List<Long> categoryIds) {
        LambdaQueryWrapper<CouponTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CouponTemplate::getStatus, 1)
               .le(CouponTemplate::getStartTime, LocalDateTime.now())
               .ge(CouponTemplate::getEndTime, LocalDateTime.now())
               .gt(CouponTemplate::getRemainingCount, 0)
               .orderByDesc(CouponTemplate::getCreatedAt);
        
        List<CouponTemplate> templates = couponTemplateMapper.selectList(wrapper);
        
        Set<Long> receivedTemplateIds = new HashSet<>();
        if (userId != null) {
            LambdaQueryWrapper<UserCoupon> userCouponWrapper = new LambdaQueryWrapper<>();
            userCouponWrapper.eq(UserCoupon::getUserId, userId);
            List<UserCoupon> userCoupons = userCouponMapper.selectList(userCouponWrapper);
            for (UserCoupon uc : userCoupons) {
                if (uc.getTemplateId() != null) {
                    receivedTemplateIds.add(uc.getTemplateId());
                }
            }
        }
        
        List<CouponTemplate> result = new ArrayList<>();
        for (CouponTemplate template : templates) {
            Integer userType = template.getUserType();
            if (userType != null && userType == 1) {
                LambdaQueryWrapper<UserCoupon> orderWrapper = new LambdaQueryWrapper<>();
                orderWrapper.eq(UserCoupon::getUserId, userId);
                Long count = userCouponMapper.selectCount(orderWrapper);
                if (count > 0) {
                    continue;
                }
            }
            
            Integer perUserLimit = template.getPerUserLimit() == null || template.getPerUserLimit() <= 0 ? 1 : template.getPerUserLimit();
            long receivedCount = userCouponMapper.selectCount(new LambdaQueryWrapper<UserCoupon>()
                .eq(UserCoupon::getUserId, userId)
                .eq(UserCoupon::getTemplateId, template.getId()));
            if (perUserLimit > 0 && receivedCount >= perUserLimit) {
                continue;
            }
            
            UserCoupon existUnused = userCouponMapper.selectOne(new LambdaQueryWrapper<UserCoupon>()
                .eq(UserCoupon::getUserId, userId)
                .eq(UserCoupon::getTemplateId, template.getId())
                .eq(UserCoupon::getStatus, 0)
                .last("LIMIT 1"));
            if (existUnused != null) {
                continue;
            }
            
            Integer couponLevel = template.getCouponLevel();
            if (merchantId != null && couponLevel != null && couponLevel == 2) {
                if (!merchantId.equals(template.getMerchantId())) {
                    continue;
                }
            }
            
            result.add(template);
        }
        
        return result;
    }
    
    @Override
    @Transactional
    public Map<String, Object> receiveAllAvailableCoupons(Long userId, Long merchantId,
                                                            List<Long> productIds, List<Long> categoryIds) {
        Map<String, Object> result = new HashMap<>();
        
        List<CouponTemplate> receivableTemplates = getReceivableTemplates(userId, merchantId, productIds, categoryIds);
        
        int successCount = 0;
        int failCount = 0;
        List<Map<String, Object>> results = new ArrayList<>();
        
        for (CouponTemplate template : receivableTemplates) {
            Map<String, Object> receiveResult = receiveCoupon(userId, template.getId());
            Boolean success = (Boolean) receiveResult.get("success");
            if (Boolean.TRUE.equals(success)) {
                successCount++;
            } else {
                failCount++;
            }
            results.add(receiveResult);
        }
        
        result.put("successCount", successCount);
        result.put("failCount", failCount);
        result.put("totalCount", receivableTemplates.size());
        result.put("results", results);
        
        return result;
    }
}
