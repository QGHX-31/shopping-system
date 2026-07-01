package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.entity.Exchange;
import com.shopping.order.service.ExchangeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/exchange")
public class ExchangeController {

    @Autowired private ExchangeService exchangeService;

    /**
     * 申请换货
     * POST /exchange/apply
     */
    @PostMapping("/apply")
    public Result<Exchange> apply(
            @RequestParam Long userId,
            @RequestParam Long orderId,
            @RequestParam Long orderItemId,
            @RequestParam Long newProductId,
            @RequestParam(required = false) Long newSkuId,
            @RequestParam(defaultValue = "1") Integer newQuantity,
            @RequestParam String exchangeReason,
            @RequestParam(required = false) String voucherImages) {
        try {
            Exchange exchange = exchangeService.apply(userId, orderId, orderItemId,
                    newProductId, newSkuId, newQuantity, exchangeReason, voucherImages);
            return Result.success(exchange);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 商家审核换货申请
     * POST /exchange/audit
     */
    @PostMapping("/audit")
    public Result<Void> audit(
            @RequestParam Long exchangeId,
            @RequestParam Boolean approve,
            @RequestParam(required = false) String remark) {
        try {
            exchangeService.audit(exchangeId, approve, remark);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户填写退货物流
     * POST /exchange/return-ship
     */
    @PostMapping("/return-ship")
    public Result<Void> userReturnShip(
            @RequestParam Long exchangeId,
            @RequestParam Long userId,
            @RequestParam String logisticsCompany,
            @RequestParam String trackingNo) {
        try {
            exchangeService.userReturnShip(exchangeId, userId, logisticsCompany, trackingNo);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 商家确认收到退货
     * POST /exchange/confirm-receive
     */
    @PostMapping("/confirm-receive")
    public Result<Void> merchantConfirmReceive(
            @RequestParam Long exchangeId,
            @RequestParam Long merchantId) {
        try {
            exchangeService.merchantConfirmReceive(exchangeId, merchantId);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 商家发货换货商品
     * POST /exchange/ship
     */
    @PostMapping("/ship")
    public Result<Void> merchantShip(
            @RequestParam Long exchangeId,
            @RequestParam Long merchantId,
            @RequestParam String logisticsCompany,
            @RequestParam String trackingNo) {
        try {
            exchangeService.merchantShip(exchangeId, merchantId, logisticsCompany, trackingNo);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户确认收到换货商品
     * POST /exchange/user-confirm
     */
    @PostMapping("/user-confirm")
    public Result<Void> userConfirmReceive(
            @RequestParam Long exchangeId,
            @RequestParam Long userId) {
        try {
            exchangeService.userConfirmReceive(exchangeId, userId);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户取消换货
     * POST /exchange/cancel
     */
    @PostMapping("/cancel")
    public Result<Void> cancel(
            @RequestParam Long exchangeId,
            @RequestParam Long userId) {
        try {
            exchangeService.cancel(exchangeId, userId);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 换货详情
     * GET /exchange/detail
     */
    @GetMapping("/detail")
    public Result<Exchange> detail(@RequestParam Long id) {
        try {
            Exchange exchange = exchangeService.getById(id);
            if (exchange == null) return Result.error("换货记录不存在");
            return Result.success(exchange);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户换货列表
     * GET /exchange/user
     */
    @GetMapping("/user")
    public Result<Map<String, Object>> userExchanges(
            @RequestParam Long userId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            return Result.success(exchangeService.listUserExchanges(userId, status, page, size));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 商家换货列表
     * GET /exchange/merchant
     */
    @GetMapping("/merchant")
    public Result<Map<String, Object>> merchantExchanges(
            @RequestParam Long merchantId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            return Result.success(exchangeService.listMerchantExchanges(merchantId, status, page, size));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 所有换货列表（管理员）
     * GET /exchange/list
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> list(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            return Result.success(exchangeService.listExchanges(status, page, size));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
