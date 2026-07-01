package com.shopping.order.admin.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.service.ExchangeService;
import com.shopping.order.service.OrderService;
import com.shopping.order.service.RefundService;
import com.shopping.order.vo.OrderVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/admin/order")
public class AdminOrderController {

    @Autowired
    private OrderService orderService;
    @Autowired
    private RefundService refundService;
    @Autowired
    private ExchangeService exchangeService;

    @GetMapping("/list")
    public Result<Map<String, Object>> listOrders(
            @RequestParam(required = false) String orderNo,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) Long merchantId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            return Result.success(orderService.listAllOrders(orderNo, status, userId, merchantId, page, size));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/detail/{id}")
    public Result<OrderVO> detail(@PathVariable Long id) {
        try {
            return Result.success(orderService.getOrderDetailById(id));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/deliver")
    public Result<Void> deliver(@RequestParam String orderNo,
                                @RequestParam(required = false) String expressCompany,
                                @RequestParam(required = false) String trackingNo) {
        try {
            orderService.deliver(orderNo, expressCompany, trackingNo);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/refund/list")
    public Result<Map<String, Object>> listRefunds(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            return Result.success(refundService.listRefunds(status, page, size));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/refund/audit")
    public Result<Void> auditRefund(
            @RequestParam Long refundId,
            @RequestParam Boolean approve,
            @RequestParam(required = false) String remark) {
        try {
            refundService.audit(refundId, approve, remark);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/exchange/list")
    public Result<Map<String, Object>> listExchanges(
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            return Result.success(exchangeService.listExchanges(status, page, size));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/exchange/detail/{id}")
    public Result<com.shopping.order.entity.Exchange> getExchangeDetail(@PathVariable Long id) {
        try {
            com.shopping.order.entity.Exchange exchange = exchangeService.getById(id);
            if (exchange == null) {
                return Result.error("换货记录不存在");
            }
            return Result.success(exchange);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
