package com.shopping.marketing.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.entity.*;
import com.shopping.common.mq.MqMessageSender;
import com.shopping.common.mq.MqTopic;
import com.shopping.common.utils.Result;
import com.shopping.marketing.mapper.*;
import com.shopping.marketing.vo.SeckillActivityVO;
import com.shopping.marketing.vo.GroupActivityVO;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/activity")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class ActivityController {

    @Resource
    private PlatformSeckillTemplateMapper platformSeckillTemplateMapper;
    @Resource
    private PlatformCouponTemplateMapper platformCouponTemplateMapper;
    @Resource
    private PlatformGroupTemplateMapper platformGroupTemplateMapper;
    @Resource
    private MerchantSeckillParticipationMapper seckillParticipationMapper;
    @Resource
    private MerchantCouponParticipationMapper couponParticipationMapper;
    @Resource
    private MerchantGroupParticipationMapper groupParticipationMapper;
    @Resource
    private ProductMapper productMapper;

    @Resource
    private MqMessageSender mqMessageSender;
    @Resource
    private UserCouponMapper userCouponMapper;

    // ========== 用户端：查询商品可参加的活动 ==========

    /**
     * 查询商品可参加的秒杀活动
     */
    @GetMapping("/seckill/product/{productId}")
    public Result<List<MerchantSeckillParticipation>> getSeckillByProduct(@PathVariable Long productId) {
        LambdaQueryWrapper<MerchantSeckillParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantSeckillParticipation::getProductId, productId)
               .eq(MerchantSeckillParticipation::getStatus, 2); // 已通过
        List<MerchantSeckillParticipation> list = seckillParticipationMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 查询商品可参加的拼团活动
     */
    @GetMapping("/group/product/{productId}")
    public Result<List<MerchantGroupParticipation>> getGroupByProduct(@PathVariable Long productId) {
        LambdaQueryWrapper<MerchantGroupParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantGroupParticipation::getProductId, productId)
               .eq(MerchantGroupParticipation::getStatus, 2); // 已通过
        List<MerchantGroupParticipation> list = groupParticipationMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 查询商品可用的优惠券
     */
    @GetMapping("/coupon/product/{productId}")
    public Result<List<PlatformCouponTemplate>> getCouponByProduct(@PathVariable Long productId) {
        // 先查该商品关联的优惠券
        LambdaQueryWrapper<MerchantCouponParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantCouponParticipation::getProductId, productId)
               .eq(MerchantCouponParticipation::getStatus, 2);
        List<MerchantCouponParticipation> participations = couponParticipationMapper.selectList(wrapper);

        if (participations.isEmpty()) {
            return Result.success(List.of());
        }

        List<Long> templateIds = participations.stream()
                .map(MerchantCouponParticipation::getTemplateId)
                .toList();

        LambdaQueryWrapper<PlatformCouponTemplate> templateWrapper = new LambdaQueryWrapper<>();
        templateWrapper.in(PlatformCouponTemplate::getId, templateIds)
                       .eq(PlatformCouponTemplate::getStatus, 1);
        List<PlatformCouponTemplate> templates = platformCouponTemplateMapper.selectList(templateWrapper);
        return Result.success(templates);
    }

    // ========== 用户端：查询所有进行中的活动 ==========

    /**
     * 获取所有进行中的秒杀活动（包含商品信息）
     */
    @GetMapping("/seckill/active")
    public Result<List<SeckillActivityVO>> getActiveSeckill() {
        LambdaQueryWrapper<MerchantSeckillParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantSeckillParticipation::getStatus, 2)
               .gt(MerchantSeckillParticipation::getAvailableStock, 0);
        List<MerchantSeckillParticipation> list = seckillParticipationMapper.selectList(wrapper);

        Map<Long, SeckillActivityVO> productMap = new HashMap<>();
        for (MerchantSeckillParticipation p : list) {
            Product product = productMapper.selectById(p.getProductId());
            if (product != null) {
                SeckillActivityVO existing = productMap.get(p.getProductId());
                if (existing != null && existing.getSeckillPrice().compareTo(p.getSeckillPrice()) <= 0) {
                    continue;
                }
                SeckillActivityVO vo = new SeckillActivityVO();
                vo.setId(p.getId());
                vo.setProductId(p.getProductId());
                vo.setProductName(product.getName());
                vo.setImageUrl(product.getImageUrl());
                vo.setSeckillPrice(p.getSeckillPrice());
                vo.setOriginalPrice(p.getOriginalPrice());
                vo.setTotalStock(p.getTotalStock());
                vo.setAvailableStock(p.getAvailableStock());
                vo.setSalesCount(p.getTotalStock() - p.getAvailableStock());
                vo.setLimitPerUser(p.getLimitPerUser());
                PlatformSeckillTemplate template = platformSeckillTemplateMapper.selectById(p.getTemplateId());
                if (template != null && template.getEndTime() != null) {
                    vo.setEndTime(java.sql.Timestamp.valueOf(template.getEndTime()).getTime());
                }
                productMap.put(p.getProductId(), vo);
            }
        }
        return Result.success(new ArrayList<>(productMap.values()));
    }

    /**
     * 获取所有进行中的拼团活动（包含商品信息）
     */
    @GetMapping("/group/active")
    public Result<List<GroupActivityVO>> getActiveGroup() {
        LambdaQueryWrapper<MerchantGroupParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantGroupParticipation::getStatus, 2)
               .gt(MerchantGroupParticipation::getAvailableStock, 0);
        List<MerchantGroupParticipation> list = groupParticipationMapper.selectList(wrapper);

        Map<Long, GroupActivityVO> productMap = new HashMap<>();
        for (MerchantGroupParticipation p : list) {
            Product product = productMapper.selectById(p.getProductId());
            PlatformGroupTemplate template = platformGroupTemplateMapper.selectById(p.getTemplateId());
            if (product != null && template != null) {
                GroupActivityVO existing = productMap.get(p.getProductId());
                if (existing != null && existing.getGroupPrice().compareTo(p.getGroupPrice()) <= 0) {
                    continue;
                }
                GroupActivityVO vo = new GroupActivityVO();
                vo.setId(p.getId());
                vo.setProductId(p.getProductId());
                vo.setProductName(product.getName());
                vo.setImageUrl(product.getImageUrl());
                vo.setGroupPrice(p.getGroupPrice());
                vo.setOriginalPrice(p.getOriginalPrice());
                vo.setRequiredNum(template.getRequiredNum());
                vo.setAvailableStock(p.getAvailableStock());
                productMap.put(p.getProductId(), vo);
            }
        }
        return Result.success(new ArrayList<>(productMap.values()));
    }

    /**
     * 获取所有可领取的优惠券
     */
    @GetMapping("/coupon/active")
    public Result<List<PlatformCouponTemplate>> getActiveCoupon() {
        LambdaQueryWrapper<PlatformCouponTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlatformCouponTemplate::getStatus, 1)
               .gt(PlatformCouponTemplate::getRemainingCount, 0);
        List<PlatformCouponTemplate> list = platformCouponTemplateMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 用户领取优惠券
     */
    @PostMapping("/coupon/receive")
    public Result<String> receiveCoupon(@RequestParam Long userId, @RequestParam Long templateId) {
        PlatformCouponTemplate template = platformCouponTemplateMapper.selectById(templateId);
        if (template == null) {
            return Result.error("优惠券不存在");
        }
        if (template.getStatus() != 1) {
            return Result.error("优惠券已下架");
        }
        if (template.getRemainingCount() <= 0) {
            return Result.error("优惠券已领完");
        }
        if (template.getStartTime() != null && template.getStartTime().isAfter(java.time.LocalDateTime.now())) {
            return Result.error("活动未开始");
        }
        if (template.getEndTime() != null && template.getEndTime().isBefore(java.time.LocalDateTime.now())) {
            return Result.error("活动已结束");
        }

        Integer perUserLimit = template.getPerUserLimit();
        if (perUserLimit == null) {
            perUserLimit = 1;
        }
        if (perUserLimit > 0) {
            LambdaQueryWrapper<UserCoupon> countWrapper = new LambdaQueryWrapper<>();
            countWrapper.eq(UserCoupon::getUserId, userId)
                        .eq(UserCoupon::getTemplateId, templateId);
            Long count = userCouponMapper.selectCount(countWrapper);
            if (count >= perUserLimit) {
                return Result.error("已达领取上限");
            }
        }

        UserCoupon userCoupon = new UserCoupon();
        userCoupon.setUserId(userId);
        userCoupon.setTemplateId(templateId);
        userCoupon.setCouponCode("C" + System.currentTimeMillis() + new java.util.Random().nextInt(1000));
        userCoupon.setName(template.getName());
        userCoupon.setType(template.getType());
        userCoupon.setDiscountAmount(template.getDiscountAmount());
        userCoupon.setMinAmount(template.getMinAmount());
        userCoupon.setStatus(0);
        userCoupon.setReceiveTime(java.time.LocalDateTime.now());
        userCoupon.setExpireTime(template.getEndTime());
        userCouponMapper.insert(userCoupon);

        template.setRemainingCount(template.getRemainingCount() - 1);
        platformCouponTemplateMapper.updateById(template);

        Map<String, Object> msg = new HashMap<>();
        msg.put("userId", userId);
        msg.put("templateId", templateId);
        msg.put("userCouponId", userCoupon.getId());
        msg.put("couponCode", userCoupon.getCouponCode());
        mqMessageSender.send(MqTopic.COUPON_RECEIVE, "receive", String.valueOf(userCoupon.getId()), msg);

        return Result.success("领取成功");
    }

    /**
     * 获取我的优惠券
     */
    @GetMapping("/coupon/mine")
    public Result<List<UserCoupon>> getMyCoupons(@RequestParam Long userId,
                                                  @RequestParam(required = false) Integer status) {
        LambdaQueryWrapper<UserCoupon> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserCoupon::getUserId, userId);
        if (status != null) {
            wrapper.eq(UserCoupon::getStatus, status);
        }
        wrapper.orderByDesc(UserCoupon::getReceiveTime);
        List<UserCoupon> list = userCouponMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 获取用户可用的优惠券（未使用 + 未过期）
     * 结算页用
     */
    @GetMapping("/coupon/user/available")
    public Result<List<UserCoupon>> getAvailableCoupons(@RequestParam Long userId,
                                                         @RequestParam(required = false) BigDecimal orderAmount) {
        LambdaQueryWrapper<UserCoupon> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserCoupon::getUserId, userId)
               .eq(UserCoupon::getStatus, 0)
               .gt(UserCoupon::getExpireTime, java.time.LocalDateTime.now())
               .orderByDesc(UserCoupon::getDiscountAmount);
        List<UserCoupon> list = userCouponMapper.selectList(wrapper);

        if (orderAmount != null) {
            list = list.stream().filter(c -> {
                BigDecimal min = c.getMinAmount();
                return min == null || orderAmount.compareTo(min) >= 0;
            }).toList();
        }
        return Result.success(list);
    }

    // ========== 管理员：活动模板管理 ==========

    /**
     * 获取所有秒杀模板
     */
    @GetMapping("/admin/seckill/template/list")
    public Result<List<PlatformSeckillTemplate>> listSeckillTemplates() {
        List<PlatformSeckillTemplate> list = platformSeckillTemplateMapper.selectList(null);
        return Result.success(list);
    }

    /**
     * 创建秒杀模板
     */
    @PostMapping("/admin/seckill/template/create")
    public Result<PlatformSeckillTemplate> createSeckillTemplate(@RequestBody PlatformSeckillTemplate template) {
        platformSeckillTemplateMapper.insert(template);
        Map<String, Object> msg = new HashMap<>();
        msg.put("templateId", template.getId());
        msg.put("templateName", template.getName());
        msg.put("startTime", template.getStartTime());
        msg.put("endTime", template.getEndTime());
        mqMessageSender.send(MqTopic.SECKILL_START, "seckill", String.valueOf(template.getId()), msg);
        return Result.success(template);
    }

    /**
     * 获取所有优惠券模板
     */
    @GetMapping("/admin/coupon/template/list")
    public Result<List<PlatformCouponTemplate>> listCouponTemplates() {
        List<PlatformCouponTemplate> list = platformCouponTemplateMapper.selectList(null);
        return Result.success(list);
    }

    /**
     * 创建优惠券模板
     */
    @PostMapping("/admin/coupon/template/create")
    public Result<PlatformCouponTemplate> createCouponTemplate(@RequestBody PlatformCouponTemplate template) {
        platformCouponTemplateMapper.insert(template);
        Map<String, Object> msg = new HashMap<>();
        msg.put("templateId", template.getId());
        msg.put("templateName", template.getName());
        msg.put("type", template.getType());
        msg.put("discountAmount", template.getDiscountAmount());
        msg.put("minAmount", template.getMinAmount());
        mqMessageSender.send(MqTopic.COUPON_RECEIVE, "coupon_publish", String.valueOf(template.getId()), msg);
        return Result.success(template);
    }

    /**
     * 获取所有拼团模板
     */
    @GetMapping("/admin/group/template/list")
    public Result<List<PlatformGroupTemplate>> listGroupTemplates() {
        List<PlatformGroupTemplate> list = platformGroupTemplateMapper.selectList(null);
        return Result.success(list);
    }

    /**
     * 创建拼团模板
     */
    @PostMapping("/admin/group/template/create")
    public Result<PlatformGroupTemplate> createGroupTemplate(@RequestBody PlatformGroupTemplate template) {
        platformGroupTemplateMapper.insert(template);
        Map<String, Object> msg = new HashMap<>();
        msg.put("templateId", template.getId());
        msg.put("templateName", template.getName());
        msg.put("requiredNum", template.getRequiredNum());
        msg.put("discountRate", template.getDiscountRate());
        mqMessageSender.send(MqTopic.GROUP_CREATED, "group", String.valueOf(template.getId()), msg);
        return Result.success(template);
    }

    // ========== 商家：查看平台活动 ==========

    /**
     * 商家查询所有可报名的秒杀活动模板
     */
    @GetMapping("/merchant/seckill/templates")
    public Result<List<PlatformSeckillTemplate>> listMerchantSeckillTemplates() {
        LambdaQueryWrapper<PlatformSeckillTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlatformSeckillTemplate::getStatus, 1);
        List<PlatformSeckillTemplate> list = platformSeckillTemplateMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 商家查询所有可报名的拼团活动模板
     */
    @GetMapping("/merchant/group/templates")
    public Result<List<PlatformGroupTemplate>> listMerchantGroupTemplates() {
        LambdaQueryWrapper<PlatformGroupTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlatformGroupTemplate::getStatus, 1);
        List<PlatformGroupTemplate> list = platformGroupTemplateMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 商家查询所有可报名的优惠券模板
     */
    @GetMapping("/merchant/coupon/templates")
    public Result<List<PlatformCouponTemplate>> listMerchantCouponTemplates() {
        LambdaQueryWrapper<PlatformCouponTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PlatformCouponTemplate::getStatus, 1);
        List<PlatformCouponTemplate> list = platformCouponTemplateMapper.selectList(wrapper);
        return Result.success(list);
    }

    // ========== 商家：报名活动 ==========

    /**
     * 商家报名秒杀活动
     */
    @PostMapping("/merchant/seckill/join")
    public Result<MerchantSeckillParticipation> joinSeckill(@RequestBody MerchantSeckillParticipation participation) {
        participation.setStatus(1); // 待审核
        seckillParticipationMapper.insert(participation);
        return Result.success(participation);
    }

    /**
     * 商家报名拼团活动
     */
    @PostMapping("/merchant/group/join")
    public Result<MerchantGroupParticipation> joinGroup(@RequestBody MerchantGroupParticipation participation) {
        participation.setStatus(1); // 待审核
        groupParticipationMapper.insert(participation);
        return Result.success(participation);
    }

    /**
     * 商家报名优惠券活动
     */
    @PostMapping("/merchant/coupon/join")
    public Result<MerchantCouponParticipation> joinCoupon(@RequestBody MerchantCouponParticipation participation) {
        participation.setStatus(1); // 待审核
        couponParticipationMapper.insert(participation);
        return Result.success(participation);
    }

    /**
     * 获取商家的秒杀报名列表
     */
    @GetMapping("/merchant/seckill/list/{merchantId}")
    public Result<List<MerchantSeckillParticipation>> listMerchantSeckill(@PathVariable Long merchantId) {
        LambdaQueryWrapper<MerchantSeckillParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantSeckillParticipation::getMerchantId, merchantId);
        List<MerchantSeckillParticipation> list = seckillParticipationMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 获取商家的拼团报名列表
     */
    @GetMapping("/merchant/group/list/{merchantId}")
    public Result<List<MerchantGroupParticipation>> listMerchantGroup(@PathVariable Long merchantId) {
        LambdaQueryWrapper<MerchantGroupParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantGroupParticipation::getMerchantId, merchantId);
        List<MerchantGroupParticipation> list = groupParticipationMapper.selectList(wrapper);
        return Result.success(list);
    }

    /**
     * 获取商家的优惠券报名列表
     */
    @GetMapping("/merchant/coupon/list/{merchantId}")
    public Result<List<MerchantCouponParticipation>> listMerchantCoupon(@PathVariable Long merchantId) {
        LambdaQueryWrapper<MerchantCouponParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantCouponParticipation::getMerchantId, merchantId);
        List<MerchantCouponParticipation> list = couponParticipationMapper.selectList(wrapper);
        return Result.success(list);
    }

    // ========== 管理员：审核商家报名 ==========

    /**
     * 审核秒杀报名
     */
    @PostMapping("/admin/seckill/approve/{id}")
    public Result<Boolean> approveSeckill(@PathVariable Long id, @RequestParam Integer status) {
        MerchantSeckillParticipation participation = seckillParticipationMapper.selectById(id);
        if (participation != null) {
            participation.setStatus(status);
            seckillParticipationMapper.updateById(participation);
            if (status == 2) {
                Map<String, Object> msg = new HashMap<>();
                msg.put("participationId", id);
                msg.put("merchantId", participation.getMerchantId());
                msg.put("templateId", participation.getTemplateId());
                msg.put("productId", participation.getProductId());
                msg.put("type", "seckill");
                mqMessageSender.send(MqTopic.MERCHANT_STATS, "approve", String.valueOf(id), msg);
            }
            return Result.success(true);
        }
        return Result.error("报名不存在");
    }

    /**
     * 审核拼团报名
     */
    @PostMapping("/admin/group/approve/{id}")
    public Result<Boolean> approveGroup(@PathVariable Long id, @RequestParam Integer status) {
        MerchantGroupParticipation participation = groupParticipationMapper.selectById(id);
        if (participation != null) {
            participation.setStatus(status);
            groupParticipationMapper.updateById(participation);
            if (status == 2) {
                Map<String, Object> msg = new HashMap<>();
                msg.put("participationId", id);
                msg.put("merchantId", participation.getMerchantId());
                msg.put("templateId", participation.getTemplateId());
                msg.put("productId", participation.getProductId());
                msg.put("type", "group");
                mqMessageSender.send(MqTopic.MERCHANT_STATS, "approve", String.valueOf(id), msg);
            }
            return Result.success(true);
        }
        return Result.error("报名不存在");
    }

    /**
     * 审核优惠券报名
     */
    @PostMapping("/admin/coupon/approve/{id}")
    public Result<Boolean> approveCoupon(@PathVariable Long id, @RequestParam Integer status) {
        MerchantCouponParticipation participation = couponParticipationMapper.selectById(id);
        if (participation != null) {
            participation.setStatus(status);
            couponParticipationMapper.updateById(participation);
            if (status == 2) {
                Map<String, Object> msg = new HashMap<>();
                msg.put("participationId", id);
                msg.put("merchantId", participation.getMerchantId());
                msg.put("templateId", participation.getTemplateId());
                msg.put("productId", participation.getProductId());
                msg.put("type", "coupon");
                mqMessageSender.send(MqTopic.MERCHANT_STATS, "approve", String.valueOf(id), msg);
            }
            return Result.success(true);
        }
        return Result.error("报名不存在");
    }
}