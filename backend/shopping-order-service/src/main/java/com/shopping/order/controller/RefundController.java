package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.entity.Refund;
import com.shopping.order.service.RefundService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/refund")
public class RefundController {

    @Autowired private RefundService refundService;

    /**
     * 申请退款
     * POST /refund/apply
     */
    @PostMapping("/apply")
    public Result<Refund> apply(
            @RequestParam Long userId,
            @RequestParam Long orderId,
            @RequestParam BigDecimal refundAmount,
            @RequestParam String reason,
            @RequestParam(defaultValue = "1") Integer type) {
        try {
            return Result.success(refundService.apply(userId, orderId, refundAmount, reason, type));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 商家/管理员审核
     */
    @PostMapping("/audit")
    public Result<Void> audit(
            @RequestParam Long refundId,
            @RequestParam Boolean approve,
            @RequestParam(required = false) String remark) {
        try {
            refundService.audit(refundId, approve, remark);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 退款列表（管理后台）
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> list(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(refundService.listRefunds(status, page, size));
    }

    /**
     * 用户的退款列表
     */
    @GetMapping("/user")
    public Result<Map<String, Object>> userRefunds(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(refundService.listUserRefunds(userId, page, size));
    }

    /**
     * 商家的退款列表
     */
    @GetMapping("/merchant")
    public Result<Map<String, Object>> merchantRefunds(
            @RequestParam Long merchantId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(refundService.listMerchantRefunds(merchantId, status, page, size));
    }

    /**
     * 用户填写退货物流信息
     */
    @PostMapping("/return-ship")
    public Result<Void> returnShip(
            @RequestParam Long refundId,
            @RequestParam Long userId,
            @RequestParam String logisticsCompany,
            @RequestParam String trackingNo) {
        try {
            refundService.userReturnGoods(refundId, userId, logisticsCompany, trackingNo);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 商家确认收货并完成退款
     */
    @PostMapping("/return-receive")
    public Result<Void> returnReceive(
            @RequestParam Long refundId,
            @RequestParam Long merchantId) {
        try {
            refundService.merchantConfirmReceive(refundId, merchantId);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 退款详情
     */
    @GetMapping("/detail")
    public Result<Refund> detail(@RequestParam Long id) {
        Refund refund = refundService.getById(id);
        if (refund == null) {
            return Result.error("退款记录不存在");
        }
        return Result.success(refund);
    }
}
