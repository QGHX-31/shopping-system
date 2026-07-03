package com.shopping.marketing.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.CouponStatusApply;
import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.utils.Result;
import com.shopping.marketing.mapper.CouponStatusApplyMapper;
import com.shopping.marketing.mapper.CouponTemplateMapper;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin/coupon")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class AdminCouponController {

    @Resource
    private CouponTemplateMapper couponTemplateMapper;

    @Resource
    private CouponStatusApplyMapper couponStatusApplyMapper;

    @GetMapping("/list")
    public Result<Map<String, Object>> list(
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Integer type,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Integer couponLevel,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        LambdaQueryWrapper<CouponTemplate> wrapper = new LambdaQueryWrapper<>();
        if (name != null && !name.isEmpty()) {
            wrapper.like(CouponTemplate::getName, name);
        }
        if (type != null) {
            wrapper.eq(CouponTemplate::getType, type);
        }
        if (status != null) {
            wrapper.eq(CouponTemplate::getStatus, status);
        }
        if (couponLevel != null) {
            wrapper.eq(CouponTemplate::getCouponLevel, couponLevel);
        }
        wrapper.orderByDesc(CouponTemplate::getCreatedAt);

        Page<CouponTemplate> pageObj = new Page<>(page, size);
        Page<CouponTemplate> resultPage = couponTemplateMapper.selectPage(pageObj, wrapper);

        return Result.success(Map.of(
                "list", resultPage.getRecords(),
                "total", resultPage.getTotal(),
                "page", page,
                "size", size
        ));
    }

    @GetMapping("/detail/{id}")
    public Result<CouponTemplate> detail(@PathVariable Long id) {
        CouponTemplate template = couponTemplateMapper.selectById(id);
        if (template == null) {
            return Result.error("优惠券不存在");
        }
        return Result.success(template);
    }

    @PostMapping("/create")
    public Result<CouponTemplate> create(@RequestBody CouponTemplate template) {
        if (template.getName() == null || template.getName().isEmpty()) {
            return Result.error("优惠券名称不能为空");
        }
        if (template.getType() == null) {
            return Result.error("优惠券类型不能为空");
        }
        if (template.getDiscountAmount() == null || template.getDiscountAmount().compareTo(BigDecimal.ZERO) <= 0) {
            return Result.error("优惠金额不能为空");
        }
        if (template.getMinAmount() == null) {
            template.setMinAmount(BigDecimal.ZERO);
        }
        if (template.getTotalCount() == null || template.getTotalCount() <= 0) {
            return Result.error("发放总量不能为空");
        }
        if (template.getStartTime() == null || template.getEndTime() == null) {
            return Result.error("有效期不能为空");
        }
        if (template.getStartTime().isAfter(template.getEndTime())) {
            return Result.error("开始时间不能晚于结束时间");
        }

        if (template.getRemainingCount() == null) {
            template.setRemainingCount(template.getTotalCount());
        }
        if (template.getPerUserLimit() == null) {
            template.setPerUserLimit(1);
        }
        if (template.getStatus() == null) {
            template.setStatus(0);
        }
        if (template.getCouponLevel() == null) {
            template.setCouponLevel(template.getMerchantId() != null && template.getMerchantId() != 0 ? 2 : 1);
        }
        if (template.getCouponLevel() == 1 && (template.getMerchantId() == null || template.getMerchantId() == 0)) {
            template.setMerchantId(0L);
        }
        if (template.getScopeType() == null) {
            template.setScopeType(template.getMerchantId() != null && template.getMerchantId() != 0 ? 2 : 1);
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
        template.setCreatedAt(LocalDateTime.now());
        template.setUpdatedAt(LocalDateTime.now());

        couponTemplateMapper.insert(template);
        return Result.success(template);
    }

    @PutMapping("/update/{id}")
    public Result<CouponTemplate> update(@PathVariable Long id, @RequestBody CouponTemplate template) {
        CouponTemplate exist = couponTemplateMapper.selectById(id);
        if (exist == null) {
            return Result.error("优惠券不存在");
        }

        if (template.getName() != null) {
            exist.setName(template.getName());
        }
        if (template.getType() != null) {
            exist.setType(template.getType());
        }
        if (template.getDiscountAmount() != null) {
            exist.setDiscountAmount(template.getDiscountAmount());
        }
        if (template.getMinAmount() != null) {
            exist.setMinAmount(template.getMinAmount());
        }
        if (template.getTotalCount() != null) {
            exist.setTotalCount(template.getTotalCount());
            if (exist.getRemainingCount() == null || exist.getRemainingCount() > template.getTotalCount()) {
                exist.setRemainingCount(template.getTotalCount());
            }
        }
        if (template.getPerUserLimit() != null) {
            exist.setPerUserLimit(template.getPerUserLimit());
        }
        if (template.getStartTime() != null) {
            exist.setStartTime(template.getStartTime());
        }
        if (template.getEndTime() != null) {
            exist.setEndTime(template.getEndTime());
        }
        if (template.getDescription() != null) {
            exist.setDescription(template.getDescription());
        }
        if (template.getScopeType() != null) {
            exist.setScopeType(template.getScopeType());
        }
        if (template.getScopeIds() != null) {
            exist.setScopeIds(template.getScopeIds());
        }
        if (template.getCouponLevel() != null) {
            exist.setCouponLevel(template.getCouponLevel());
        }
        if (template.getMutuallyExclusive() != null) {
            exist.setMutuallyExclusive(template.getMutuallyExclusive());
        }
        if (template.getUserType() != null) {
            exist.setUserType(template.getUserType());
        }
        if (template.getMemberLevel() != null) {
            exist.setMemberLevel(template.getMemberLevel());
        }
        exist.setUpdatedAt(LocalDateTime.now());

        couponTemplateMapper.updateById(exist);
        return Result.success(exist);
    }

    @PutMapping("/status/{id}")
    public Result<Boolean> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        CouponTemplate template = couponTemplateMapper.selectById(id);
        if (template == null) {
            return Result.error("优惠券不存在");
        }
        template.setStatus(status);
        template.setUpdatedAt(LocalDateTime.now());
        couponTemplateMapper.updateById(template);
        return Result.success(true);
    }

    @DeleteMapping("/delete/{id}")
    public Result<Boolean> delete(@PathVariable Long id) {
        CouponTemplate template = couponTemplateMapper.selectById(id);
        if (template == null) {
            return Result.error("优惠券不存在");
        }
        couponTemplateMapper.deleteById(id);
        return Result.success(true);
    }

    @GetMapping("/apply/list")
    public Result<Map<String, Object>> applyList(
            @RequestParam(required = false) Integer applyStatus,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        LambdaQueryWrapper<CouponStatusApply> wrapper = new LambdaQueryWrapper<>();
        if (applyStatus != null) {
            wrapper.eq(CouponStatusApply::getApplyStatus, applyStatus);
        }
        wrapper.orderByDesc(CouponStatusApply::getCreatedAt);

        Page<CouponStatusApply> pageObj = new Page<>(page, size);
        Page<CouponStatusApply> resultPage = couponStatusApplyMapper.selectPage(pageObj, wrapper);

        List<CouponStatusApply> records = resultPage.getRecords();
        for (CouponStatusApply apply : records) {
            CouponTemplate template = couponTemplateMapper.selectById(apply.getTemplateId());
            if (template != null) {
                apply.setReason(template.getName() + " - " + (apply.getReason() != null ? apply.getReason() : ""));
            }
        }

        return Result.success(Map.of(
                "list", records,
                "total", resultPage.getTotal(),
                "page", page,
                "size", size
        ));
    }

    @GetMapping("/apply/pendingCount")
    public Result<Integer> pendingCount() {
        LambdaQueryWrapper<CouponStatusApply> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CouponStatusApply::getApplyStatus, 0);
        Long count = couponStatusApplyMapper.selectCount(wrapper);
        return Result.success(count.intValue());
    }

    @PutMapping("/apply/{id}/handle")
    public Result<Boolean> handleApply(@PathVariable Long id,
                                        @RequestParam Integer applyStatus,
                                        @RequestParam(required = false) String adminRemark) {
        CouponStatusApply apply = couponStatusApplyMapper.selectById(id);
        if (apply == null) {
            return Result.error("申请不存在");
        }
        if (apply.getApplyStatus() != 0) {
            return Result.error("申请已处理");
        }

        apply.setApplyStatus(applyStatus);
        apply.setAdminRemark(adminRemark);
        apply.setUpdatedAt(LocalDateTime.now());
        couponStatusApplyMapper.updateById(apply);

        if (applyStatus == 1) {
            CouponTemplate template = couponTemplateMapper.selectById(apply.getTemplateId());
            if (template != null) {
                template.setStatus(apply.getTargetStatus());
                template.setUpdatedAt(LocalDateTime.now());
                couponTemplateMapper.updateById(template);
            }
        }

        return Result.success(true);
    }
}
