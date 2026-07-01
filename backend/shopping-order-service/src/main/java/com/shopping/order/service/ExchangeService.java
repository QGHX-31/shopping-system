package com.shopping.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.order.entity.Exchange;

import java.math.BigDecimal;
import java.util.Map;

public interface ExchangeService {
    /**
     * 申请换货
     */
    Exchange apply(Long userId, Long orderId, Long orderItemId,
                   Long newProductId, Long newSkuId, Integer newQuantity,
                   String exchangeReason, String voucherImages);
    
    /**
     * 审核换货申请
     */
    void audit(Long exchangeId, Boolean approve, String remark);
    
    /**
     * 用户填写退货物流
     */
    void userReturnShip(Long exchangeId, Long userId, String logisticsCompany, String trackingNo);
    
    /**
     * 商家确认收到退货
     */
    void merchantConfirmReceive(Long exchangeId, Long merchantId);
    
    /**
     * 商家发货换货商品
     */
    void merchantShip(Long exchangeId, Long merchantId, String logisticsCompany, String trackingNo);
    
    /**
     * 用户确认收到换货商品
     */
    void userConfirmReceive(Long exchangeId, Long userId);
    
    /**
     * 用户取消换货
     */
    void cancel(Long exchangeId, Long userId);
    
    /**
     * 根据ID查询
     */
    Exchange getById(Long id);
    
    /**
     * 用户换货列表
     */
    Map<String, Object> listUserExchanges(Long userId, Integer status, Integer page, Integer size);
    
    /**
     * 商家换货列表
     */
    Map<String, Object> listMerchantExchanges(Long merchantId, Integer status, Integer page, Integer size);
    
    /**
     * 所有换货列表（管理员）
     */
    Map<String, Object> listExchanges(Integer status, Integer page, Integer size);
}