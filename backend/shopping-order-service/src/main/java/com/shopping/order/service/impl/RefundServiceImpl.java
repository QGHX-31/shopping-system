package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.utils.Result;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.entity.Refund;
import com.shopping.common.entity.UserCoupon;
import com.shopping.order.feign.ProductClient;
import com.shopping.order.mapper.OrderItemMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.mapper.RefundMapper;
import com.shopping.order.mapper.UserCouponMapper;
import com.shopping.order.service.MessageService;
import com.shopping.order.service.RefundService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
public class RefundServiceImpl implements RefundService {

    @Autowired private RefundMapper refundMapper;
    @Autowired private OrderMapper orderMapper;
    @Autowired private OrderItemMapper orderItemMapper;
    @Autowired private UserCouponMapper userCouponMapper;
    @Autowired private MessageService messageService;
    @Autowired(required = false) private ProductClient productClient;

    @Value("${shopping.product-service-url:http://localhost:8082}")
    private String productServiceUrl;

    private final org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();

    @Override
    @Transactional
    @com.shopping.order.annotation.Idempotent
    public Refund apply(Long userId, Long orderId, BigDecimal refundAmount, String reason, Integer type) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) throw new BusinessException("订单不存在");
        if (!order.getUserId().equals(userId)) throw new BusinessException("无权操作此订单");
        if (order.getStatus() != 1 && order.getStatus() != 2 && order.getStatus() != 3) {
            throw new BusinessException("当前订单状态不支持退款");
        }
        if (refundAmount.compareTo(order.getPayAmount()) > 0) {
            throw new BusinessException("退款金额不能超过实付金额");
        }

        // 待发货订单只能申请仅退款
        if (order.getStatus() == 1 && type != null && type == 2) {
            throw new BusinessException("商品未发货，仅支持仅退款");
        }

        // 检查是否已有待审核的退款申请
        Long pendingCount = refundMapper.selectCount(
                new LambdaQueryWrapper<Refund>()
                        .eq(Refund::getOrderId, orderId)
                        .eq(Refund::getStatus, 0)
        );
        if (pendingCount != null && pendingCount > 0) {
            throw new BusinessException("该订单已有待审核的退款申请，请等待处理");
        }

        Refund refund = new Refund();
        refund.setRefundNo(generateRefundNo());
        refund.setOrderId(orderId);
        refund.setUserId(userId);
        refund.setRefundAmount(refundAmount);
        refund.setRefundReason(reason);
        refund.setRefundType(type != null ? type : 1);
        refund.setStatus(0); // 待审核
        refund.setApplyTime(LocalDateTime.now());
        refundMapper.insert(refund);

        // 更新订单状态为退款中
        order.setStatus(5);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        messageService.sendRefundMessage(userId, "退款申请已提交", "您的退款申请已提交，等待商家审核");

        return refund;
    }

    @Override
    @Transactional
    public void audit(Long refundId, Boolean approve, String remark) {
        Refund refund = refundMapper.selectById(refundId);
        if (refund == null) throw new BusinessException("退款记录不存在");
        if (refund.getStatus() != 0) throw new BusinessException("已审核，不可重复操作");

        Order order = orderMapper.selectById(refund.getOrderId());
        if (order == null) throw new BusinessException("订单不存在");

        if (approve) {
            if (refund.getRefundType() != null && refund.getRefundType() == 2) {
                // 退货退款：审核通过 → 状态变为待退货(1)，等待用户发货
                refund.setStatus(1);
                refund.setMerchantRemark(remark);
                refund.setAuditTime(LocalDateTime.now());
                refundMapper.updateById(refund);
                log.info("退货退款审核通过，等待用户退货: refundId={}", refundId);

                messageService.sendRefundMessage(refund.getUserId(), "退款申请已通过", "您的退款申请已通过");
                messageService.sendRefundMessage(refund.getUserId(), "请尽快寄回商品", "请尽快寄回商品");
            } else {
                // 仅退款：审核通过直接完成退款
                refund.setStatus(3);
                refund.setMerchantRemark(remark);
                refund.setAuditTime(LocalDateTime.now());
                refund.setRefundTime(LocalDateTime.now());
                refundMapper.updateById(refund);

                order.setStatus(6); // 已退款
                order.setUpdatedAt(LocalDateTime.now());
                orderMapper.updateById(order);

                // 退款成功，返还优惠券
                releaseOrderCoupons(order);
                log.info("仅退款审核通过，退款完成: refundId={}", refundId);

                messageService.sendRefundMessage(refund.getUserId(), "退款申请已通过", "您的退款申请已通过");
                messageService.sendRefundMessage(refund.getUserId(), "退款已完成", "退款已完成，款项已退回");
            }
        } else {
            refund.setStatus(2); // 已拒绝
            refund.setMerchantRemark(remark);
            refund.setAuditTime(LocalDateTime.now());
            refundMapper.updateById(refund);

            // 恢复订单状态（根据原状态推断：已支付/待发货 或 已发货 或 已完成）
            if (order.getStatus() == 5) {
                // 根据订单状态是退款中，根据时间字段判断原状态
                // 有收货时间 -> 已完成
                if (order.getReceiveTime() != null) {
                    order.setStatus(3); // 已完成
                }
                // 有发货时间但无收货时间 -> 已发货
                else if (order.getDeliveryTime() != null) {
                    order.setStatus(2); // 已发货
                }
                // 都没有 -> 待发货
                else {
                    order.setStatus(1); // 已支付/待发货
                }
            }
            order.setUpdatedAt(LocalDateTime.now());
            orderMapper.updateById(order);

            messageService.sendRefundMessage(refund.getUserId(), "退款申请被拒绝", "您的退款申请被拒绝");
        }
    }

    @Override
    public Map<String, Object> listRefunds(Integer status, Integer page, Integer size) {
        Page<Refund> p = new Page<>(page, size);
        LambdaQueryWrapper<Refund> wrapper = new LambdaQueryWrapper<Refund>().orderByDesc(Refund::getApplyTime);
        if (status != null) wrapper.eq(Refund::getStatus, status);
        Page<Refund> result = refundMapper.selectPage(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    public Map<String, Object> listUserRefunds(Long userId, Integer page, Integer size) {
        Page<Refund> p = new Page<>(page, size);
        LambdaQueryWrapper<Refund> wrapper = new LambdaQueryWrapper<Refund>()
                .eq(Refund::getUserId, userId)
                .orderByDesc(Refund::getApplyTime);
        Page<Refund> result = refundMapper.selectPage(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    public Map<String, Object> listMerchantRefunds(Long merchantId, Integer status, Integer page, Integer size) {
        Page<Refund> p = new Page<>(page, size);

        // 管理员视角：直接查全部退款
        if (merchantId == null || merchantId == 0) {
            LambdaQueryWrapper<Refund> wrapper = new LambdaQueryWrapper<Refund>()
                    .orderByDesc(Refund::getApplyTime);
            if (status != null) wrapper.eq(Refund::getStatus, status);
            Page<Refund> result = refundMapper.selectPage(p, wrapper);
            Map<String, Object> data = new HashMap<>();
            data.put("total", result.getTotal());
            data.put("list", result.getRecords());
            return data;
        }

        // 通过 order_item 关联查询包含该商家商品的订单ID
        LambdaQueryWrapper<OrderItem> itemWrapper = new LambdaQueryWrapper<OrderItem>()
                .eq(OrderItem::getMerchantId, merchantId)
                .select(OrderItem::getOrderId);
        List<OrderItem> itemList = orderItemMapper.selectList(itemWrapper);
        Set<Long> orderIds = itemList.stream().map(OrderItem::getOrderId).collect(Collectors.toSet());

        // 兼容旧数据
        LambdaQueryWrapper<Order> orderWrapper = new LambdaQueryWrapper<Order>()
                .eq(Order::getMerchantId, merchantId)
                .select(Order::getId);
        List<Order> directOrders = orderMapper.selectList(orderWrapper);
        for (Order o : directOrders) {
            orderIds.add(o.getId());
        }

        LambdaQueryWrapper<Refund> wrapper = new LambdaQueryWrapper<Refund>()
                .orderByDesc(Refund::getApplyTime);
        if (orderIds.isEmpty()) {
            wrapper.eq(Refund::getId, -1);
        } else {
            wrapper.in(Refund::getOrderId, orderIds);
        }
        if (status != null) wrapper.eq(Refund::getStatus, status);
        Page<Refund> result = refundMapper.selectPage(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    @Transactional
    public void userReturnGoods(Long refundId, Long userId, String logisticsCompany, String trackingNo) {
        Refund refund = refundMapper.selectById(refundId);
        if (refund == null) throw new BusinessException("退款申请不存在");
        if (!refund.getUserId().equals(userId)) throw new BusinessException("无权操作此退款申请");
        if (refund.getStatus() != 1) {
            throw new BusinessException("当前状态不支持退货操作");
        }
        if (refund.getRefundType() != null && refund.getRefundType() != 2) {
            throw new BusinessException("仅退货退款类型需要退货操作");
        }
        if (logisticsCompany == null || logisticsCompany.trim().isEmpty()) {
            throw new BusinessException("请填写物流公司");
        }
        if (trackingNo == null || trackingNo.trim().isEmpty()) {
            throw new BusinessException("请填写物流单号");
        }

        refund.setReturnLogisticsCompany(logisticsCompany.trim());
        refund.setReturnTrackingNo(trackingNo.trim());
        refund.setReturnShipTime(LocalDateTime.now());
        refund.setStatus(5); // 退货中
        refundMapper.updateById(refund);
        log.info("用户已发货: refundId={}, logisticsCompany={}, trackingNo={}", refundId, logisticsCompany, trackingNo);
    }

    @Override
    @Transactional
    public void merchantConfirmReceive(Long refundId, Long merchantId) {
        Refund refund = refundMapper.selectById(refundId);
        if (refund == null) throw new BusinessException("退款申请不存在");
        if (refund.getStatus() != 5) {
            throw new BusinessException("当前状态不支持确认收货操作");
        }
        if (refund.getRefundType() != null && refund.getRefundType() != 2) {
            throw new BusinessException("仅退货退款类型需要确认收货");
        }

        Order order = orderMapper.selectById(refund.getOrderId());
        if (order == null) throw new BusinessException("订单不存在");

        // 完成退款
        refund.setReturnReceiveTime(LocalDateTime.now());
        refund.setStatus(3); // 已完成
        refund.setRefundTime(LocalDateTime.now());
        refundMapper.updateById(refund);

        order.setStatus(6); // 已退款
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        // 退款成功，返还优惠券
        releaseOrderCoupons(order);

        // 退货退款，恢复商品库存
        restoreStock(order.getId());

        log.info("商家确认收货，退款完成: refundId={}", refundId);

        messageService.sendRefundMessage(refund.getUserId(), "退货中", "商家已收到您的退货");
        messageService.sendRefundMessage(refund.getUserId(), "退款已完成", "退款已完成，款项已退回");
    }

    @Override
    public Refund getById(Long id) {
        return refundMapper.selectById(id);
    }

    private void releaseOrderCoupons(Order order) {
        if (order == null) return;
        java.util.List<Long> couponIds = new java.util.ArrayList<>();
        if (order.getCouponId() != null) {
            couponIds.add(order.getCouponId());
        }
        if (order.getCouponIds() != null && !order.getCouponIds().isEmpty()) {
            try {
                String json = order.getCouponIds().replace("[", "").replace("]", "");
                for (String s : json.split(",")) {
                    s = s.trim();
                    if (!s.isEmpty()) couponIds.add(Long.valueOf(s));
                }
            } catch (Exception e) {
                log.error("解析couponIds失败: {}", order.getCouponIds(), e);
            }
        }
        java.util.Set<Long> uniqueIds = new java.util.LinkedHashSet<>(couponIds);
        for (Long cid : uniqueIds) {
            UserCoupon coupon = userCouponMapper.selectById(cid);
            if (coupon != null && coupon.getStatus() == 1) {
                coupon.setStatus(0);
                coupon.setOrderNo(null);
                coupon.setUseTime(null);
                userCouponMapper.updateById(coupon);
                log.info("退款返还优惠券: couponId={}, orderNo={}", cid, order.getOrderNo());
            }
        }
    }

    private void restoreStock(Long orderId) {
        try {
            java.util.List<OrderItem> items = orderItemMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<OrderItem>()
                            .eq(OrderItem::getOrderId, orderId));
            for (OrderItem item : items) {
                try {
                    if (productClient != null) {
                        try {
                            productClient.addStock(item.getProductId(), item.getQuantity());
                            log.info("退款恢复库存(Feign): productId={}, quantity={}", item.getProductId(), item.getQuantity());
                            continue;
                        } catch (Exception e) {
                            log.warn("Feign调用恢复库存失败，降级使用RestTemplate: productId={}", item.getProductId(), e);
                        }
                    }
                    String url = productServiceUrl + "/product/addStock?productId=" + item.getProductId()
                            + "&quantity=" + item.getQuantity();
                    restTemplate.postForEntity(url, null, java.util.Map.class);
                    log.info("退款恢复库存(RestTemplate): productId={}, quantity={}", item.getProductId(), item.getQuantity());
                } catch (Exception e) {
                    log.error("恢复单个商品库存失败: productId={}", item.getProductId(), e);
                }
            }
        } catch (Exception e) {
            log.error("退款恢复库存失败: orderId={}", orderId, e);
        }
    }

    private String generateRefundNo() {
        return "R" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));
    }
}
