package com.shopping.order.service;

import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.vo.OrderCreateRequest;
import com.shopping.order.vo.OrderVO;

import java.util.List;
import java.util.Map;

public interface OrderService {
    /**
     * 创建订单
     */
    Order createOrder(OrderCreateRequest request);

    /**
     * 根据订单号查询
     */
    Order getByOrderNo(String orderNo);

    /**
     * 查询订单详情（含商品列表）
     */
    OrderVO getOrderDetail(String orderNo);

    /**
     * 根据ID查询订单详情
     */
    OrderVO getOrderDetailById(Long id);

    /**
     * 取消订单
     */
    void cancelOrder(String orderNo, String reason);

    /**
     * 支付成功回调（内部调用）
     */
    void onPaySuccess(String orderNo, Integer payMethod, String payTradeNo);

    /**
     * 发货（商家操作）
     */
    void deliver(String orderNo, String expressCompany, String trackingNo);

    /**
     * 确认收货
     */
    void confirmReceive(String orderNo);

    /**
     * 用户删除订单（逻辑删除）
     */
    void deleteOrder(String orderNo, Long userId);

    void batchDeleteOrders(List<String> orderNos, Long userId);

    /**
     * 分页查询用户订单
     */
    Map<String, Object> listUserOrders(Long userId, Integer status, Integer page, Integer size);

    /**
     * 分页查询商家订单
     */
    Map<String, Object> listMerchantOrders(Long merchantId, Integer status, Integer page, Integer size);

    /**
     * 分页查询全部订单（运营后台）
     */
    Map<String, Object> listAllOrders(String orderNo, Integer status, Long userId, Long merchantId, Integer page, Integer size);
}
