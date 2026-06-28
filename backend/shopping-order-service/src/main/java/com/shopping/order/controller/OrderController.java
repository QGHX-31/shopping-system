package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.entity.Order;
import com.shopping.order.service.OrderService;
import com.shopping.order.vo.OrderCreateRequest;
import com.shopping.order.vo.OrderVO;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/order")
public class OrderController {

    @Autowired private OrderService orderService;

    /**
     * 创建订单
     * POST /order/create
     * body: {userId, items:[{productId, quantity}], addressId, couponId?, remark?}
     */
    @PostMapping("/create")
    public Result<Order> create(@Valid @RequestBody OrderCreateRequest request) {
        try {
            Order order = orderService.createOrder(request);
            return Result.success(order);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 查询订单详情
     * GET /order/detail?orderNo=Oxxx&userId=1
     */
    @GetMapping("/detail")
    public Result<OrderVO> detail(@RequestParam String orderNo) {
        return Result.success(orderService.getOrderDetail(orderNo));
    }

    /**
     * 根据ID查询订单详情
     * GET /order/{id}
     */
    @GetMapping("/{id}")
    public Result<OrderVO> getById(@PathVariable Long id) {
        return Result.success(orderService.getOrderDetailById(id));
    }

    /**
     * 取消订单
     * POST /order/cancel
     */
    @PostMapping("/cancel")
    public Result<Void> cancel(@RequestParam String orderNo, @RequestParam(required = false) String reason) {
        try {
            orderService.cancelOrder(orderNo, reason);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 确认收货
     */
    @PostMapping("/confirmReceive")
    public Result<Void> confirmReceive(@RequestParam String orderNo) {
        try {
            orderService.confirmReceive(orderNo);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除订单（逻辑删除）
     * POST /order/delete?orderNo=xxx&userId=1
     */
    @PostMapping("/delete")
    public Result<Void> delete(@RequestParam String orderNo, @RequestParam Long userId) {
        try {
            orderService.deleteOrder(orderNo, userId);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 批量删除订单
     * POST /order/batch-delete  body: { orderNos: [], userId: 1 }
     */
    @PostMapping("/batch-delete")
    public Result<Void> batchDelete(@RequestBody Map<String, Object> body) {
        try {
            List<String> orderNos = (List<String>) body.get("orderNos");
            Long userId = Long.valueOf(String.valueOf(body.get("userId")));
            orderService.batchDeleteOrders(orderNos, userId);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 用户订单列表
     * GET /order/user?userId=1&status=0&page=1&size=10
     */
    @GetMapping("/user")
    public Result<Map<String, Object>> userOrders(
            @RequestParam Long userId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(orderService.listUserOrders(userId, status, page, size));
    }

    /**
     * 商家订单列表
     */
    @GetMapping("/merchant")
    public Result<Map<String, Object>> merchantOrders(
            @RequestParam Long merchantId,
            @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        return Result.success(orderService.listMerchantOrders(merchantId, status, page, size));
    }

    /**
     * 发货（商家操作）
     */
    @PostMapping("/deliver")
    public Result<Void> deliver(@RequestParam String orderNo,
                                @RequestParam(required = false) String expressCompany,
                                @RequestParam(required = false) String trackingNo) {
        try {
            orderService.deliver(orderNo, expressCompany, trackingNo);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
