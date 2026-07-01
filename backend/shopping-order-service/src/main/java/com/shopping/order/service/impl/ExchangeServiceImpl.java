package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.exception.BusinessException;
import com.shopping.order.entity.Exchange;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.mapper.ExchangeMapper;
import com.shopping.order.mapper.OrderItemMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.service.ExchangeService;
import com.shopping.order.service.MessageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.stream.Collectors;

@Slf4j
@Service
public class ExchangeServiceImpl implements ExchangeService {

    @Autowired private ExchangeMapper exchangeMapper;
    @Autowired private OrderMapper orderMapper;
    @Autowired private OrderItemMapper orderItemMapper;
    @Autowired private MessageService messageService;

    @Value("${shopping.product-service-url:http://localhost:8082}")
    private String productServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    @Transactional
    public Exchange apply(Long userId, Long orderId, Long orderItemId,
                          Long newProductId, Long newSkuId, Integer newQuantity,
                          String exchangeReason, String voucherImages) {
        // 验证订单
        Order order = orderMapper.selectById(orderId);
        if (order == null) throw new BusinessException("订单不存在");
        if (!order.getUserId().equals(userId)) throw new BusinessException("无权操作此订单");
        // 只有已发货(status=2)或已完成(status=3)的订单可以申请换货
        if (order.getStatus() != 2 && order.getStatus() != 3) {
            throw new BusinessException("当前订单状态不支持换货，只有已发货或已完成的订单可以申请换货");
        }

        // 验证订单明细
        OrderItem orderItem = orderItemMapper.selectById(orderItemId);
        if (orderItem == null || !orderItem.getOrderId().equals(orderId)) {
            throw new BusinessException("订单明细不存在或不属于该订单");
        }

        // 检查是否已有待处理的换货申请
        Long pendingCount = exchangeMapper.selectCount(
                new LambdaQueryWrapper<Exchange>()
                        .eq(Exchange::getOrderItemId, orderItemId)
                        .in(Exchange::getStatus, 0, 1, 5, 6, 7)
        );
        if (pendingCount != null && pendingCount > 0) {
            throw new BusinessException("该商品已有待处理的换货申请");
        }

        // 获取新商品信息
        Map<String, Object> newProductInfo = getProductInfo(newProductId, newSkuId);
        BigDecimal newPrice = toBigDecimal(newProductInfo.get("price"));
        String newProductName = (String) newProductInfo.get("productName");
        String newSpecValues = (String) newProductInfo.get("specValues");

        // 计算价格差异
        BigDecimal originalPrice = orderItem.getPrice();
        BigDecimal priceDiff = newPrice.multiply(BigDecimal.valueOf(newQuantity))
                .subtract(originalPrice.multiply(BigDecimal.valueOf(orderItem.getQuantity())));

        // 创建换货申请
        Exchange exchange = new Exchange();
        exchange.setExchangeNo(generateExchangeNo());
        exchange.setOrderId(orderId);
        exchange.setOrderItemId(orderItemId);
        exchange.setUserId(userId);
        exchange.setMerchantId(orderItem.getMerchantId());
        exchange.setExchangeReason(exchangeReason);
        exchange.setVoucherImages(voucherImages);
        exchange.setOriginalOrderStatus(order.getStatus());

        // 原商品信息
        exchange.setOriginalProductId(orderItem.getProductId());
        exchange.setOriginalSkuId(orderItem.getSkuId());
        exchange.setOriginalProductName(orderItem.getProductName());
        exchange.setOriginalSpecValues(orderItem.getSpecValues());
        exchange.setOriginalQuantity(orderItem.getQuantity());
        exchange.setOriginalPrice(originalPrice);

        // 新商品信息
        exchange.setNewProductId(newProductId);
        exchange.setNewSkuId(newSkuId);
        exchange.setNewProductName(newProductName);
        exchange.setNewSpecValues(newSpecValues);
        exchange.setNewQuantity(newQuantity);
        exchange.setNewPrice(newPrice);
        exchange.setPriceDifference(priceDiff);

        exchange.setStatus(0); // 待审核
        exchange.setApplyTime(LocalDateTime.now());
        exchangeMapper.insert(exchange);

        // 更新订单状态为换货中（使用状态5，与退款共用）
        order.setStatus(5);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        messageService.sendExchangeMessage(userId, "换货申请已提交", "您的换货申请已提交，等待商家审核");

        log.info("用户申请换货: userId={}, orderId={}, exchangeId={}, exchangeNo={}", 
                userId, orderId, exchange.getId(), exchange.getExchangeNo());
        return exchange;
    }

    @Override
    @Transactional
    public void audit(Long exchangeId, Boolean approve, String remark) {
        Exchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) throw new BusinessException("换货申请不存在");
        if (exchange.getStatus() != 0) throw new BusinessException("已审核，不可重复操作");

        Order order = orderMapper.selectById(exchange.getOrderId());
        if (order == null) throw new BusinessException("订单不存在");

        if (approve) {
            // 审核通过，等待用户退货
            exchange.setStatus(1); // 待退货
            exchange.setMerchantRemark(remark);
            exchange.setAuditTime(LocalDateTime.now());
            exchangeMapper.updateById(exchange);
            log.info("换货申请审核通过: exchangeId={}", exchangeId);

            messageService.sendExchangeMessage(exchange.getUserId(), "换货申请已通过", 
                    "您的换货申请已通过，请尽快寄回原商品");
        } else {
            // 审核拒绝
            exchange.setStatus(2); // 已拒绝
            exchange.setMerchantRemark(remark);
            exchange.setAuditTime(LocalDateTime.now());
            exchangeMapper.updateById(exchange);

            // 恢复订单状态
            if (exchange.getOriginalOrderStatus() != null) {
                order.setStatus(exchange.getOriginalOrderStatus());
            } else if (order.getStatus() == 5) {
                order.setStatus(3); // 默认恢复为已完成
            }
            order.setUpdatedAt(LocalDateTime.now());
            orderMapper.updateById(order);

            log.info("换货申请已拒绝: exchangeId={}", exchangeId);
            messageService.sendExchangeMessage(exchange.getUserId(), "换货申请被拒绝", 
                    "您的换货申请被拒绝：" + (remark != null ? remark : ""));
        }
    }

    @Override
    @Transactional
    public void userReturnShip(Long exchangeId, Long userId, String logisticsCompany, String trackingNo) {
        Exchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) throw new BusinessException("换货申请不存在");
        if (!exchange.getUserId().equals(userId)) throw new BusinessException("无权操作此换货申请");
        if (exchange.getStatus() != 1) {
            throw new BusinessException("当前状态不支持退货操作");
        }
        if (logisticsCompany == null || logisticsCompany.trim().isEmpty()) {
            throw new BusinessException("请填写物流公司");
        }
        if (trackingNo == null || trackingNo.trim().isEmpty()) {
            throw new BusinessException("请填写物流单号");
        }

        exchange.setReturnLogisticsCompany(logisticsCompany.trim());
        exchange.setReturnTrackingNo(trackingNo.trim());
        exchange.setReturnShipTime(LocalDateTime.now());
        exchange.setStatus(5); // 退货中
        exchangeMapper.updateById(exchange);
        log.info("用户已发送退货: exchangeId={}, logisticsCompany={}, trackingNo={}", 
                exchangeId, logisticsCompany, trackingNo);

        messageService.sendExchangeMessage(userId, "退货已发出", "商家将在收到退货后为您发送换货商品");
    }

    @Override
    @Transactional
    public void merchantConfirmReceive(Long exchangeId, Long merchantId) {
        Exchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) throw new BusinessException("换货申请不存在");
        if (exchange.getStatus() != 5) {
            throw new BusinessException("当前状态不支持确认收货操作");
        }

        Order order = orderMapper.selectById(exchange.getOrderId());
        if (order == null) throw new BusinessException("订单不存在");

        // 商家确认收到退货，准备发货
        exchange.setReturnReceiveTime(LocalDateTime.now());
        exchange.setStatus(6); // 待发货
        exchangeMapper.updateById(exchange);

        log.info("商家确认收到退货: exchangeId={}", exchangeId);
        messageService.sendExchangeMessage(exchange.getUserId(), "退货已收到", 
                "商家已收到您的退货，正在准备发货");
    }

    @Override
    @Transactional
    public void merchantShip(Long exchangeId, Long merchantId, String logisticsCompany, String trackingNo) {
        Exchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) throw new BusinessException("换货申请不存在");
        if (exchange.getStatus() != 6) {
            throw new BusinessException("当前状态不支持发货操作");
        }
        if (logisticsCompany == null || logisticsCompany.trim().isEmpty()) {
            throw new BusinessException("请填写物流公司");
        }
        if (trackingNo == null || trackingNo.trim().isEmpty()) {
            throw new BusinessException("请填写物流单号");
        }

        // 商家发货换货商品
        exchange.setExchangeLogisticsCompany(logisticsCompany.trim());
        exchange.setExchangeTrackingNo(trackingNo.trim());
        exchange.setExchangeShipTime(LocalDateTime.now());
        exchange.setStatus(7); // 已发货
        exchangeMapper.updateById(exchange);

        // 更新库存：原商品加库存，新商品减库存
        try {
            // 原商品加库存
            restTemplate.postForEntity(
                    productServiceUrl + "/product/addStock?productId=" + exchange.getOriginalProductId() 
                            + "&quantity=" + exchange.getOriginalQuantity(),
                    null, Map.class);
            // 新商品减库存
            restTemplate.postForEntity(
                    productServiceUrl + "/product/reduceStock?productId=" + exchange.getNewProductId() 
                            + "&quantity=" + exchange.getNewQuantity(),
                    null, Map.class);
        } catch (Exception e) {
            log.warn("更新库存失败: exchangeId={}, error={}", exchangeId, e.getMessage());
        }

        log.info("商家已发送换货商品: exchangeId={}, logisticsCompany={}, trackingNo={}", 
                exchangeId, logisticsCompany, trackingNo);

        messageService.sendExchangeMessage(exchange.getUserId(), "换货商品已发出", 
                "您的换货商品已发出，物流公司：" + logisticsCompany + "，单号：" + trackingNo);
    }

    @Override
    @Transactional
    public void userConfirmReceive(Long exchangeId, Long userId) {
        Exchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) throw new BusinessException("换货申请不存在");
        if (!exchange.getUserId().equals(userId)) throw new BusinessException("无权操作此换货申请");
        if (exchange.getStatus() != 7) {
            throw new BusinessException("当前状态不支持确认收货操作");
        }

        Order order = orderMapper.selectById(exchange.getOrderId());
        if (order == null) throw new BusinessException("订单不存在");

        // 用户确认收到换货商品，换货完成
        exchange.setExchangeReceiveTime(LocalDateTime.now());
        exchange.setStatus(3); // 已完成
        exchange.setCompleteTime(LocalDateTime.now());
        exchangeMapper.updateById(exchange);

        // 恢复订单状态为已完成
        order.setStatus(3);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        log.info("用户确认收到换货商品，换货完成: exchangeId={}", exchangeId);
        messageService.sendExchangeMessage(userId, "换货已完成", "您的换货申请已完成");
    }

    @Override
    @Transactional
    public void cancel(Long exchangeId, Long userId) {
        Exchange exchange = exchangeMapper.selectById(exchangeId);
        if (exchange == null) throw new BusinessException("换货申请不存在");
        if (!exchange.getUserId().equals(userId)) throw new BusinessException("无权操作此换货申请");
        if (exchange.getStatus() != 0 && exchange.getStatus() != 1) {
            throw new BusinessException("当前状态不支持取消操作");
        }

        Order order = orderMapper.selectById(exchange.getOrderId());
        if (order == null) throw new BusinessException("订单不存在");

        // 取消换货
        exchange.setStatus(4); // 已取消
        exchangeMapper.updateById(exchange);

        // 恢复订单状态
        if (exchange.getOriginalOrderStatus() != null) {
            order.setStatus(exchange.getOriginalOrderStatus());
        } else if (order.getStatus() == 5) {
            order.setStatus(3); // 默认恢复为已完成
        }
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        log.info("用户取消换货: exchangeId={}", exchangeId);
        messageService.sendExchangeMessage(userId, "换货已取消", "您的换货申请已取消");
    }

    @Override
    public Exchange getById(Long id) {
        return exchangeMapper.selectById(id);
    }

    @Override
    public Map<String, Object> listUserExchanges(Long userId, Integer status, Integer page, Integer size) {
        Page<Exchange> p = new Page<>(page, size);
        LambdaQueryWrapper<Exchange> wrapper = new LambdaQueryWrapper<Exchange>()
                .eq(Exchange::getUserId, userId)
                .orderByDesc(Exchange::getApplyTime);
        if (status != null && status >= 0) wrapper.eq(Exchange::getStatus, status);
        Page<Exchange> result = exchangeMapper.selectPage(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    public Map<String, Object> listMerchantExchanges(Long merchantId, Integer status, Integer page, Integer size) {
        Page<Exchange> p = new Page<>(page, size);
        LambdaQueryWrapper<Exchange> wrapper = new LambdaQueryWrapper<Exchange>()
                .eq(Exchange::getMerchantId, merchantId)
                .orderByDesc(Exchange::getApplyTime);
        if (status != null && status >= 0) wrapper.eq(Exchange::getStatus, status);
        Page<Exchange> result = exchangeMapper.selectPage(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    public Map<String, Object> listExchanges(Integer status, Integer page, Integer size) {
        Page<Exchange> p = new Page<>(page, size);
        LambdaQueryWrapper<Exchange> wrapper = new LambdaQueryWrapper<Exchange>()
                .orderByDesc(Exchange::getApplyTime);
        if (status != null && status >= 0) wrapper.eq(Exchange::getStatus, status);
        Page<Exchange> result = exchangeMapper.selectPage(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    private Map<String, Object> getProductInfo(Long productId, Long skuId) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 调用product-service获取商品信息
            String url = productServiceUrl + "/product/" + productId;
            Map<String, Object> productRes = restTemplate.getForEntity(url, Map.class).getBody();
            if (productRes != null && productRes.get("data") != null) {
                Map<String, Object> productData = (Map<String, Object>) productRes.get("data");
                result.put("productName", productData.get("name"));
                
                // 如果有SKU，通过sku/list接口获取SKU价格
                if (skuId != null && skuId > 0) {
                    String skuUrl = productServiceUrl + "/sku/list?productId=" + productId;
                    Map<String, Object> skuRes = restTemplate.getForEntity(skuUrl, Map.class).getBody();
                    if (skuRes != null && skuRes.get("data") != null) {
                        List<Map<String, Object>> skuList = (List<Map<String, Object>>) skuRes.get("data");
                        if (skuList != null) {
                            for (Map<String, Object> sku : skuList) {
                                Object idObj = sku.get("id");
                                if (idObj != null && Long.valueOf(idObj.toString()).equals(skuId)) {
                                    result.put("price", sku.get("price"));
                                    result.put("specValues", sku.get("specValues"));
                                    break;
                                }
                            }
                        }
                    }
                    // 如果没找到对应SKU，用商品价格
                    if (result.get("price") == null) {
                        result.put("price", productData.get("price"));
                        result.put("specValues", null);
                    }
                } else {
                    result.put("price", productData.get("price"));
                    result.put("specValues", null);
                }
            }
        } catch (Exception e) {
            log.error("获取商品信息失败: productId={}, skuId={}, error={}", productId, skuId, e.getMessage());
            throw new BusinessException("获取商品信息失败");
        }
        
        if (result.get("price") == null) {
            throw new BusinessException("无法获取商品价格信息");
        }
        return result;
    }

    private String generateExchangeNo() {
        return "E" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value == null) return BigDecimal.ZERO;
        if (value instanceof BigDecimal) return (BigDecimal) value;
        if (value instanceof Number) return BigDecimal.valueOf(((Number) value).doubleValue());
        try {
            return new BigDecimal(value.toString());
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }
}