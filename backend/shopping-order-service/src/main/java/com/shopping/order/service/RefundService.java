package com.shopping.order.service;

import com.shopping.order.entity.Refund;

import java.math.BigDecimal;
import java.util.Map;

public interface RefundService {
    Refund apply(Long userId, Long orderId, BigDecimal refundAmount, String reason, Integer type);
    void audit(Long refundId, Boolean approve, String remark);
    void userReturnGoods(Long refundId, Long userId, String logisticsCompany, String trackingNo);
    void merchantConfirmReceive(Long refundId, Long merchantId);
    Map<String, Object> listRefunds(Integer status, Integer page, Integer size);
    Map<String, Object> listUserRefunds(Long userId, Integer page, Integer size);
    Map<String, Object> listMerchantRefunds(Long merchantId, Integer status, Integer page, Integer size);
    Refund getById(Long id);
}
