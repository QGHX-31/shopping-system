package com.shopping.marketing.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.entity.GroupBuyActivity;
import com.shopping.common.entity.SeckillActivity;
import com.shopping.common.utils.Result;
import com.shopping.marketing.mapper.GroupBuyActivityMapper;
import com.shopping.marketing.mapper.SeckillActivityMapper;
import com.shopping.marketing.service.GroupBuyService;
import com.shopping.marketing.service.SeckillService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/activity")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class ActivityController {

    @Resource
    private SeckillService seckillService;

    @Resource
    private GroupBuyService groupBuyService;

    @Resource
    private SeckillActivityMapper seckillActivityMapper;

    @Resource
    private GroupBuyActivityMapper groupBuyActivityMapper;

    @GetMapping("/seckill/active")
    public Result<List<Map<String, Object>>> getActiveSeckill() {
        Map<String, Object> data = seckillService.getActiveActivities();
        return Result.success((List<Map<String, Object>>) data.get("list"));
    }

    @GetMapping("/group/active")
    public Result<List<Map<String, Object>>> getActiveGroup() {
        Map<String, Object> data = groupBuyService.getActiveActivities();
        return Result.success((List<Map<String, Object>>) data.get("list"));
    }

    @GetMapping("/seckill/product/{productId}")
    public Result<List<SeckillActivity>> getSeckillByProduct(@PathVariable Long productId) {
        LambdaQueryWrapper<SeckillActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SeckillActivity::getProductId, productId)
               .eq(SeckillActivity::getStatus, 1)
               .le(SeckillActivity::getStartTime, LocalDateTime.now())
               .ge(SeckillActivity::getEndTime, LocalDateTime.now());
        List<SeckillActivity> activities = seckillActivityMapper.selectList(wrapper);
        return Result.success(activities);
    }

    @GetMapping("/group/product/{productId}")
    public Result<List<GroupBuyActivity>> getGroupByProduct(@PathVariable Long productId) {
        LambdaQueryWrapper<GroupBuyActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupBuyActivity::getProductId, productId)
               .eq(GroupBuyActivity::getStatus, 1)
               .le(GroupBuyActivity::getStartTime, LocalDateTime.now())
               .ge(GroupBuyActivity::getEndTime, LocalDateTime.now());
        List<GroupBuyActivity> activities = groupBuyActivityMapper.selectList(wrapper);
        return Result.success(activities);
    }

    @GetMapping("/coupon/product/{productId}")
    public Result<List<Map<String, Object>>> getCouponsByProduct(@PathVariable Long productId) {
        return Result.success(List.of());
    }
}