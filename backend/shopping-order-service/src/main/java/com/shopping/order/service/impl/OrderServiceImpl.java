package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.Address;
import com.shopping.common.entity.CouponTemplate;
import com.shopping.common.entity.MerchantCouponParticipation;
import com.shopping.common.entity.Product;
import com.shopping.common.entity.ProductSku;
import com.shopping.common.entity.UserCoupon;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.utils.Result;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderItem;
import com.shopping.order.feign.ProductClient;
import com.shopping.order.mapper.CouponTemplateMapper;
import com.shopping.order.mapper.MerchantCouponParticipationMapper;
import com.shopping.order.mapper.OrderItemMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.mapper.UserCouponMapper;
import com.shopping.order.service.MessageService;
import com.shopping.order.service.OrderService;
import com.shopping.order.vo.OrderCreateRequest;
import com.shopping.order.vo.OrderItemRequest;
import com.shopping.order.vo.OrderVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 订单服务核心实现
 * <p>
 * 关键流程：
 * 1. 校验商品、库存、地址
 * 2. 通过商品服务扣减库存（Redis Lua 原子操作）
 * 3. 锁定优惠券
 * 4. 计算金额（满减、优惠券、运费）
 * 5. 插入 order + order_item
 * 6. 15 分钟未支付自动取消（定时任务）
 */
@Slf4j
@Service
public class OrderServiceImpl implements OrderService {

    @Autowired private OrderMapper orderMapper;
    @Autowired private OrderItemMapper orderItemMapper;
    @Autowired private UserCouponMapper userCouponMapper;
    @Autowired private CouponTemplateMapper couponTemplateMapper;
    @Autowired private MerchantCouponParticipationMapper merchantCouponParticipationMapper;
    @Autowired private MessageService messageService;
    @Autowired(required = false) private ProductClient productClient;

    @Value("${shopping.product-service-url:http://localhost:8082}")
    private String productServiceUrl;

    @Value("${shopping.marketing-service-url:http://localhost:8083}")
    private String marketingServiceUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Order createOrder(OrderCreateRequest request) {
        // 0. 幂等性校验：检查10秒内是否有相同商品的待支付订单
        Order duplicateOrder = checkDuplicateOrder(request);
        if (duplicateOrder != null) {
            log.info("检测到重复下单，直接返回已有订单: orderNo={}, userId={}", duplicateOrder.getOrderNo(), request.getUserId());
            return duplicateOrder;
        }

        // 1. 参数校验
        if (request.getUserId() == null || request.getItems() == null || request.getItems().isEmpty()) {
            throw new BusinessException("参数不完整");
        }
        if (request.getAddressId() == null) {
            throw new BusinessException("请选择收货地址");
        }

        // 2. 查询地址
        Address address = queryAddress(request.getUserId(), request.getAddressId());
        if (address == null) {
            throw new BusinessException("收货地址不存在");
        }

        // 3. 校验商品、库存，按商家分组
        Map<Long, List<OrderItemRequest>> byMerchant = new LinkedHashMap<>();
        Map<Long, Product> productCache = new HashMap<>();
        for (OrderItemRequest item : request.getItems()) {
            Product product = queryProduct(item.getProductId());
            if (product == null || product.getStatus() != 1) {
                throw new BusinessException("商品已下架: " + item.getProductId());
            }
            if (product.getStock() < item.getQuantity()) {
                throw new BusinessException(product.getName() + " 库存不足");
            }
            productCache.put(product.getId(), product);
            byMerchant.computeIfAbsent(product.getMerchantId(), k -> new ArrayList<>()).add(item);
        }

        // 4. 扣减库存（预占库存）
        List<OrderItemRequest> deductedItems = new ArrayList<>();
        for (OrderItemRequest item : request.getItems()) {
            Boolean ok = callProductDeductStock(item.getProductId(), item.getQuantity());
            if (!Boolean.TRUE.equals(ok)) {
                // 回滚已扣减的库存
                for (OrderItemRequest d : deductedItems) {
                    callProductAddStock(d.getProductId(), d.getQuantity());
                }
                throw new BusinessException("库存扣减失败");
            }
            deductedItems.add(item);
        }

        try {
            // 5. 计算总金额和各商家金额
            BigDecimal totalAmount = BigDecimal.ZERO;
            Map<Long, BigDecimal> merchantAmountMap = new HashMap<>();
            Map<Long, List<OrderItem>> merchantItemsMap = new HashMap<>();

            for (Map.Entry<Long, List<OrderItemRequest>> entry : byMerchant.entrySet()) {
                Long merchantId = entry.getKey();
                List<OrderItemRequest> merchantItems = entry.getValue();
                BigDecimal merchantTotal = BigDecimal.ZERO;
                List<OrderItem> orderItems = new ArrayList<>();

                for (OrderItemRequest item : merchantItems) {
                    Product product = productCache.get(item.getProductId());
                    BigDecimal price = product.getPrice();
                    BigDecimal subtotal = price.multiply(BigDecimal.valueOf(item.getQuantity()));
                    merchantTotal = merchantTotal.add(subtotal);

                    OrderItem oi = new OrderItem();
                    oi.setProductId(product.getId());
                    oi.setSkuId(item.getSkuId());
                    oi.setMerchantId(product.getMerchantId());
                    oi.setProductName(product.getName());
                    oi.setProductImage(product.getImageUrl());
                    oi.setPrice(price);
                    oi.setQuantity(item.getQuantity());
                    oi.setSubtotal(subtotal);
                    orderItems.add(oi);
                }

                totalAmount = totalAmount.add(merchantTotal);
                merchantAmountMap.put(merchantId, merchantTotal);
                merchantItemsMap.put(merchantId, orderItems);
            }

            // 6. 计算优惠券
            BigDecimal discountAmount = BigDecimal.ZERO;
            List<Long> couponIds = new ArrayList<>();
            if (request.getCouponIds() != null && !request.getCouponIds().isEmpty()) {
                couponIds = new ArrayList<>(request.getCouponIds());
            } else if (request.getCouponId() != null) {
                couponIds = Collections.singletonList(request.getCouponId());
            }

            Map<Long, CouponTemplate> templateMap = new HashMap<>();
            if (!couponIds.isEmpty()) {
                List<UserCoupon> userCoupons = userCouponMapper.selectBatchIds(couponIds);
                if (userCoupons == null || userCoupons.isEmpty()) {
                    throw new BusinessException("优惠券不存在");
                }
                if (userCoupons.size() != couponIds.size()) {
                    throw new BusinessException("部分优惠券不存在");
                }
                for (UserCoupon uc : userCoupons) {
                    if (uc.getTemplateId() != null) {
                        CouponTemplate tpl = couponTemplateMapper.selectById(uc.getTemplateId());
                        if (tpl != null) templateMap.put(uc.getId(), tpl);
                    }
                }

                // 优惠券叠加规则校验
                int platformCouponCount = 0;
                Map<Long, Integer> merchantCouponCount = new HashMap<>();
                for (UserCoupon uc : userCoupons) {
                    CouponTemplate tpl = templateMap.get(uc.getId());
                    int level = tpl != null && tpl.getCouponLevel() != null ? tpl.getCouponLevel()
                            : (tpl != null && tpl.getMerchantId() != null ? 2 : 1);
                    Long tplMerchantId = tpl != null ? tpl.getMerchantId() : null;

                    if (level == 1) {
                        platformCouponCount++;
                        if (platformCouponCount > 1) {
                            throw new BusinessException("平台券最多只能使用一张");
                        }
                    } else if (level == 2 && tplMerchantId != null) {
                        int count = merchantCouponCount.getOrDefault(tplMerchantId, 0) + 1;
                        merchantCouponCount.put(tplMerchantId, count);
                        if (count > 1) {
                            throw new BusinessException("同一店铺的店铺券最多只能使用一张");
                        }
                    }
                }

                for (UserCoupon uc : userCoupons) {
                    if (uc.getStatus() != 0) {
                        throw new BusinessException("优惠券不可用: " + uc.getName());
                    }
                    if (uc.getLockOrderNo() != null && !uc.getLockOrderNo().isEmpty()) {
                        throw new BusinessException("优惠券已被占用: " + uc.getName());
                    }
                    if (uc.getExpireTime() != null && uc.getExpireTime().isBefore(LocalDateTime.now())) {
                        throw new BusinessException("优惠券已过期: " + uc.getName());
                    }

                    CouponTemplate tpl = templateMap.get(uc.getId());
                    int level = tpl != null && tpl.getCouponLevel() != null ? tpl.getCouponLevel()
                            : (tpl != null && tpl.getMerchantId() != null ? 2 : 1);
                    Long tplMerchantId = tpl != null ? tpl.getMerchantId() : null;

                    if ((level == 2 || level == 3) && tplMerchantId != null) {
                        if (!byMerchant.containsKey(tplMerchantId)) {
                            throw new BusinessException("优惠券「" + uc.getName() + "」仅限指定店铺使用");
                        }
                    }

                    if (tpl != null && tpl.getScopeType() != null && tpl.getScopeType() == 3) {
                        List<Long> scopeProductIds = getCouponProductIds(tpl.getId());
                        if (scopeProductIds != null && !scopeProductIds.isEmpty()) {
                            List<Long> orderProductIds = request.getItems().stream()
                                .map(OrderItemRequest::getProductId)
                                .filter(Objects::nonNull)
                                .collect(Collectors.toList());
                            boolean hasMatch = orderProductIds.stream().anyMatch(scopeProductIds::contains);
                            if (!hasMatch) {
                                throw new BusinessException("优惠券「" + uc.getName() + "」仅限指定商品使用");
                            }
                        }
                    }

                    BigDecimal baseAmount;
                    if (level == 2 && tplMerchantId != null) {
                        baseAmount = merchantAmountMap.getOrDefault(tplMerchantId, BigDecimal.ZERO);
                    } else {
                        baseAmount = totalAmount;
                    }

                    BigDecimal minAmount = uc.getMinAmount() != null ? uc.getMinAmount() : BigDecimal.ZERO;
                    if (baseAmount.compareTo(minAmount) < 0) {
                        throw new BusinessException("优惠券「" + uc.getName() + "」未达到使用门槛：满" + minAmount + "元可用");
                    }

                    BigDecimal d = BigDecimal.ZERO;
                    if (uc.getType() != null && uc.getType() == 2) {
                        d = baseAmount.multiply(BigDecimal.ONE.subtract(uc.getDiscountAmount()));
                    } else {
                        d = uc.getDiscountAmount() != null ? uc.getDiscountAmount() : BigDecimal.ZERO;
                    }
                    if (d.compareTo(baseAmount) > 0) {
                        d = baseAmount;
                    }
                    discountAmount = discountAmount.add(d.setScale(2, RoundingMode.HALF_UP));
                    log.info("订单使用优惠券: couponId={}, level={}, baseAmount={}, 优惠金额={}", uc.getId(), level, baseAmount, d);
                }
            }

            if (discountAmount.compareTo(totalAmount) > 0) {
                discountAmount = totalAmount;
            }

            // 7. 计算总运费（按商家分别计算后汇总）
            String province = address.getProvince() != null ? address.getProvince() : "";
            String city = address.getCity() != null ? address.getCity() : "";
            String district = address.getDistrict() != null ? address.getDistrict() : "";
            String detail = address.getDetailAddress() != null ? address.getDetailAddress() : "";
            String fullAddress = province + city + district + detail;

            BigDecimal totalFreight = BigDecimal.ZERO;
            Map<Long, BigDecimal> merchantFreightMap = new HashMap<>();
            for (Long merchantId : byMerchant.keySet()) {
                BigDecimal merchantAmount = merchantAmountMap.get(merchantId);
                BigDecimal freight = merchantAmount.compareTo(new BigDecimal("99")) >= 0
                        ? BigDecimal.ZERO : new BigDecimal("10.00");
                merchantFreightMap.put(merchantId, freight);
                totalFreight = totalFreight.add(freight);
            }

            BigDecimal payAmount = totalAmount.subtract(discountAmount).add(totalFreight);
            if (payAmount.compareTo(BigDecimal.ZERO) < 0) {
                payAmount = BigDecimal.ZERO;
            }

            String couponIdsJson = null;
            if (!couponIds.isEmpty()) {
                couponIdsJson = couponIds.stream().map(String::valueOf).collect(Collectors.joining(",", "[", "]"));
            }

            // 8. 按商家拆单
            boolean multiMerchant = byMerchant.size() > 1;
            Order mainOrder = null;

            if (multiMerchant) {
                // 多商家：创建主订单（parentOrderId=0, orderType=1）
                Order parentOrder = new Order();
                parentOrder.setOrderNo(generateOrderNo());
                parentOrder.setParentOrderId(0L);
                parentOrder.setOrderType(1);
                parentOrder.setUserId(request.getUserId());
                parentOrder.setMerchantId(0L);
                parentOrder.setTotalAmount(totalAmount);
                parentOrder.setPayAmount(payAmount);
                parentOrder.setFreightAmount(totalFreight);
                parentOrder.setDiscountAmount(discountAmount);
                parentOrder.setCouponId(couponIds.isEmpty() ? null : couponIds.get(0));
                parentOrder.setCouponIds(couponIdsJson);
                parentOrder.setStatus(0);
                parentOrder.setAddressId(address.getId());
                parentOrder.setReceiverName(address.getReceiverName());
                parentOrder.setReceiverPhone(address.getReceiverPhone());
                parentOrder.setReceiverAddress(fullAddress);
                parentOrder.setRemark(request.getRemark());
                parentOrder.setCreatedAt(LocalDateTime.now());
                parentOrder.setUpdatedAt(LocalDateTime.now());
                orderMapper.insert(parentOrder);
                mainOrder = parentOrder;

                // 为每个商家创建子订单
                int merchantIndex = 0;
                for (Map.Entry<Long, List<OrderItemRequest>> entry : byMerchant.entrySet()) {
                    Long merchantId = entry.getKey();
                    BigDecimal merchantTotal = merchantAmountMap.get(merchantId);
                    BigDecimal merchantFreight = merchantFreightMap.get(merchantId);
                    List<OrderItem> merchantItems = merchantItemsMap.get(merchantId);

                    // 计算该子订单分摊的优惠金额（按金额比例）
                    BigDecimal merchantDiscount = BigDecimal.ZERO;
                    if (discountAmount.compareTo(BigDecimal.ZERO) > 0 && totalAmount.compareTo(BigDecimal.ZERO) > 0) {
                        merchantDiscount = discountAmount.multiply(merchantTotal)
                                .divide(totalAmount, 2, RoundingMode.HALF_UP);
                    }
                    BigDecimal merchantPayAmount = merchantTotal.subtract(merchantDiscount).add(merchantFreight);
                    if (merchantPayAmount.compareTo(BigDecimal.ZERO) < 0) {
                        merchantPayAmount = BigDecimal.ZERO;
                    }

                    Order subOrder = new Order();
                    subOrder.setOrderNo(generateOrderNo());
                    subOrder.setParentOrderId(parentOrder.getId());
                    subOrder.setOrderType(2);
                    subOrder.setUserId(request.getUserId());
                    subOrder.setMerchantId(merchantId);
                    subOrder.setTotalAmount(merchantTotal);
                    subOrder.setPayAmount(merchantPayAmount);
                    subOrder.setFreightAmount(merchantFreight);
                    subOrder.setDiscountAmount(merchantDiscount);
                    subOrder.setStatus(0);
                    subOrder.setAddressId(address.getId());
                    subOrder.setReceiverName(address.getReceiverName());
                    subOrder.setReceiverPhone(address.getReceiverPhone());
                    subOrder.setReceiverAddress(fullAddress);
                    subOrder.setRemark(request.getRemark());
                    subOrder.setCreatedAt(LocalDateTime.now());
                    subOrder.setUpdatedAt(LocalDateTime.now());
                    orderMapper.insert(subOrder);

                    // 插入子订单明细
                    for (OrderItem oi : merchantItems) {
                        oi.setOrderId(subOrder.getId());
                        oi.setCreatedAt(LocalDateTime.now());
                        orderItemMapper.insert(oi);
                    }

                    merchantIndex++;
                }

                // 锁定优惠券（锁定在主订单上）
                if (!couponIds.isEmpty()) {
                    for (Long cid : couponIds) {
                        UserCoupon uc = userCouponMapper.selectById(cid);
                        if (uc != null && uc.getStatus() == 0) {
                            uc.setLockOrderNo(parentOrder.getOrderNo());
                            userCouponMapper.updateById(uc);
                            log.info("优惠券已锁定: couponId={}, orderNo={}", cid, parentOrder.getOrderNo());
                        }
                    }
                }

                log.info("多商家拆单成功: parentOrderNo={}, merchantCount={}, payAmount={}",
                        parentOrder.getOrderNo(), byMerchant.size(), payAmount);
            } else {
                // 单商家：与原逻辑一致
                Long merchantId = byMerchant.keySet().iterator().next();
                List<OrderItem> orderItems = merchantItemsMap.get(merchantId);
                BigDecimal merchantTotal = merchantAmountMap.get(merchantId);
                BigDecimal merchantFreight = merchantFreightMap.get(merchantId);

                Order order = new Order();
                order.setOrderNo(generateOrderNo());
                order.setParentOrderId(0L);
                order.setOrderType(0);
                order.setUserId(request.getUserId());
                order.setMerchantId(merchantId);
                order.setTotalAmount(totalAmount);
                order.setPayAmount(payAmount);
                order.setFreightAmount(merchantFreight);
                order.setDiscountAmount(discountAmount);
                order.setCouponId(couponIds.isEmpty() ? null : couponIds.get(0));
                order.setCouponIds(couponIdsJson);
                order.setStatus(0);
                order.setAddressId(address.getId());
                order.setReceiverName(address.getReceiverName());
                order.setReceiverPhone(address.getReceiverPhone());
                order.setReceiverAddress(fullAddress);
                order.setRemark(request.getRemark());
                order.setCreatedAt(LocalDateTime.now());
                order.setUpdatedAt(LocalDateTime.now());

                if (request.getGroupTeamNo() != null && !request.getGroupTeamNo().isEmpty()) {
                    Long groupTeamId = queryGroupTeamId(request.getGroupTeamNo());
                    if (groupTeamId != null) {
                        order.setGroupBuyTeamId(groupTeamId);
                        order.setGroupBuyTime(LocalDateTime.now());
                    }
                }

                orderMapper.insert(order);
                mainOrder = order;

                // 插入订单明细
                for (OrderItem oi : orderItems) {
                    oi.setOrderId(order.getId());
                    oi.setCreatedAt(LocalDateTime.now());
                    orderItemMapper.insert(oi);
                }

                // 锁定优惠券
                if (!couponIds.isEmpty()) {
                    for (Long cid : couponIds) {
                        UserCoupon uc = userCouponMapper.selectById(cid);
                        if (uc != null && uc.getStatus() == 0) {
                            uc.setLockOrderNo(order.getOrderNo());
                            userCouponMapper.updateById(uc);
                            log.info("优惠券已锁定: couponId={}, orderNo={}", cid, order.getOrderNo());
                        }
                    }
                }

                log.info("订单创建成功: orderNo={}, merchantId={}, payAmount={}", order.getOrderNo(), merchantId, payAmount);
            }

            messageService.sendOrderMessage(mainOrder.getUserId(), "订单创建成功", "您的订单已创建成功，请尽快支付", 1);

            return mainOrder;
        } catch (Exception e) {
            // 创建订单失败，回滚已扣减的库存
            for (OrderItemRequest item : deductedItems) {
                callProductAddStock(item.getProductId(), item.getQuantity());
            }
            throw e;
        }
    }

    @Override
    public Order getByOrderNo(String orderNo) {
        return orderMapper.selectOne(new LambdaQueryWrapper<Order>().eq(Order::getOrderNo, orderNo));
    }

    @Override
    public OrderVO getOrderDetail(String orderNo) {
        Order order = getByOrderNo(orderNo);
        if (order == null) return null;
        return buildOrderVO(order);
    }

    @Override
    public OrderVO getOrderDetailById(Long id) {
        Order order = orderMapper.selectById(id);
        if (order == null) return null;
        return buildOrderVO(order);
    }

    private OrderVO buildOrderVO(Order order) {
        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId()));
        ensureFullAddress(order);
        OrderVO vo = new OrderVO();
        vo.setOrder(order);
        vo.setItems(items);
        vo.setCoupon(buildCouponInfo(order.getCouponId()));
        vo.setCoupons(buildCouponInfoList(order));

        boolean isParent = order.getParentOrderId() != null && order.getParentOrderId() == 0L
                && order.getOrderType() != null && order.getOrderType() == 1;
        if (isParent) {
            List<Order> subOrders = orderMapper.selectList(
                    new LambdaQueryWrapper<Order>().eq(Order::getParentOrderId, order.getId())
                            .orderByAsc(Order::getCreatedAt));
            List<OrderVO> subVOList = new ArrayList<>();
            for (Order subOrder : subOrders) {
                OrderVO subVO = new OrderVO();
                List<OrderItem> subItems = orderItemMapper.selectList(
                        new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, subOrder.getId()));
                subVO.setOrder(subOrder);
                subVO.setItems(subItems);
                subVOList.add(subVO);
            }
            vo.setSubOrders(subVOList);
        }

        return vo;
    }

    private void ensureFullAddress(Order order) {
        if (order == null || order.getAddressId() == null) return;
        String addr = order.getReceiverAddress();
        if (addr != null && addr.length() > 15) return;
        try {
            Address address = queryAddress(order.getUserId(), order.getAddressId());
            if (address != null) {
                String province = address.getProvince() != null ? address.getProvince() : "";
                String city = address.getCity() != null ? address.getCity() : "";
                String district = address.getDistrict() != null ? address.getDistrict() : "";
                String detail = address.getDetailAddress() != null ? address.getDetailAddress() : "";
                order.setReceiverAddress(province + city + district + detail);
            }
        } catch (Exception e) {
            log.warn("补全订单地址失败: orderNo={}", order.getOrderNo(), e);
        }
    }

    private OrderVO.CouponInfo buildCouponInfo(Long userCouponId) {
        if (userCouponId == null) return null;
        UserCoupon userCoupon = userCouponMapper.selectById(userCouponId);
        if (userCoupon == null) return null;
        OrderVO.CouponInfo info = new OrderVO.CouponInfo();
        info.setId(userCoupon.getId());
        info.setName(userCoupon.getName());
        info.setType(userCoupon.getType());
        info.setDiscountAmount(userCoupon.getDiscountAmount());
        info.setMinAmount(userCoupon.getMinAmount());
        return info;
    }

    private List<OrderVO.CouponInfo> buildCouponInfoList(Order order) {
        List<Long> ids = new ArrayList<>();
        if (order.getCouponId() != null) ids.add(order.getCouponId());
        if (order.getCouponIds() != null && !order.getCouponIds().isEmpty()) {
            try {
                String json = order.getCouponIds().replace("[", "").replace("]", "");
                for (String s : json.split(",")) {
                    s = s.trim();
                    if (!s.isEmpty()) ids.add(Long.valueOf(s));
                }
            } catch (Exception e) {
                log.error("解析couponIds失败: {}", order.getCouponIds(), e);
            }
        }
        Set<Long> uniqueIds = new LinkedHashSet<>(ids);
        List<OrderVO.CouponInfo> list = new ArrayList<>();
        for (Long id : uniqueIds) {
            OrderVO.CouponInfo info = buildCouponInfo(id);
            if (info != null) list.add(info);
        }
        return list;
    }

    @Override
    @Transactional
    @com.shopping.order.annotation.Idempotent
    public void cancelOrder(String orderNo, String reason) {
        Order order = getByOrderNo(orderNo);
        if (order == null) throw new BusinessException("订单不存在");
        if (order.getStatus() != 0) throw new BusinessException("只有待支付订单可以取消");

        boolean isParent = order.getParentOrderId() != null && order.getParentOrderId() == 0L
                && order.getOrderType() != null && order.getOrderType() == 1;

        if (isParent) {
            List<Order> subOrders = orderMapper.selectList(
                    new LambdaQueryWrapper<Order>().eq(Order::getParentOrderId, order.getId()));
            for (Order subOrder : subOrders) {
                if (subOrder.getStatus() == 0) {
                    cancelSingleOrder(subOrder, reason);
                }
            }
        }

        cancelSingleOrder(order, reason);
    }

    private void cancelSingleOrder(Order order, String reason) {
        order.setStatus(4);
        order.setCancelTime(LocalDateTime.now());
        order.setCancelReason(reason);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId()));
        for (OrderItem item : items) {
            callProductAddStock(item.getProductId(), item.getQuantity());
        }

        releaseLockedCoupons(order.getOrderNo());

        if (order.getGroupBuyTeamId() != null) {
            try {
                restTemplate.postForObject(
                        marketingServiceUrl + "/group/team/cancel?teamId=" + order.getGroupBuyTeamId(),
                        null,
                        Result.class
                );
            } catch (Exception e) {
                log.warn("取消拼团团队失败: teamId={}, error={}", order.getGroupBuyTeamId(), e.getMessage());
            }
        }

        messageService.sendOrderMessage(order.getUserId(), "订单已取消", "您的订单已取消", 1);
    }

    private void releaseLockedCoupons(String orderNo) {
        if (orderNo == null || orderNo.isEmpty()) return;
        LambdaQueryWrapper<UserCoupon> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserCoupon::getLockOrderNo, orderNo);
        List<UserCoupon> lockedCoupons = userCouponMapper.selectList(wrapper);
        for (UserCoupon coupon : lockedCoupons) {
            coupon.setLockOrderNo(null);
            userCouponMapper.updateById(coupon);
            log.info("优惠券已释放: couponId={}, orderNo={}", coupon.getId(), orderNo);
        }
    }

    @Override
    @Transactional
    public void onPaySuccess(String orderNo, Integer payMethod, String payTradeNo) {
        Order order = getByOrderNo(orderNo);
        if (order == null) throw new BusinessException("订单不存在");
        if (order.getStatus() != 0) {
            log.warn("订单状态非待支付，不处理回调: orderNo={}, status={}", orderNo, order.getStatus());
            return;
        }

        boolean isParent = order.getParentOrderId() != null && order.getParentOrderId() == 0L
                && order.getOrderType() != null && order.getOrderType() == 1;

        if (isParent) {
            List<Order> subOrders = orderMapper.selectList(
                    new LambdaQueryWrapper<Order>().eq(Order::getParentOrderId, order.getId()));
            for (Order subOrder : subOrders) {
                if (subOrder.getStatus() == 0) {
                    processPaySuccess(subOrder, payMethod, payTradeNo);
                }
            }
        }

        processPaySuccess(order, payMethod, payTradeNo);
    }

    private void processPaySuccess(Order order, Integer payMethod, String payTradeNo) {
        order.setStatus(1);
        order.setPayTime(LocalDateTime.now());
        order.setPayMethod(payMethod);
        order.setPayTradeNo(payTradeNo);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        List<Long> usedCouponIds = new ArrayList<>();
        if (order.getCouponId() != null) {
            usedCouponIds.add(order.getCouponId());
        }
        if (order.getCouponIds() != null && !order.getCouponIds().isEmpty()) {
            try {
                String json = order.getCouponIds().replace("[", "").replace("]", "");
                for (String s : json.split(",")) {
                    s = s.trim();
                    if (!s.isEmpty()) usedCouponIds.add(Long.valueOf(s));
                }
            } catch (Exception e) {
                log.error("解析couponIds失败: {}", order.getCouponIds(), e);
            }
        }
        Set<Long> uniqueIds = new LinkedHashSet<>(usedCouponIds);
        for (Long cid : uniqueIds) {
            UserCoupon coupon = userCouponMapper.selectById(cid);
            if (coupon != null && coupon.getStatus() == 0) {
                coupon.setStatus(1);
                coupon.setUseTime(LocalDateTime.now());
                coupon.setOrderNo(order.getOrderNo());
                coupon.setLockOrderNo(null);
                userCouponMapper.updateById(coupon);
                log.info("优惠券已使用: couponId={}, orderNo={}", cid, order.getOrderNo());
            }
        }

        List<OrderItem> items = orderItemMapper.selectList(
                new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId()));
        for (OrderItem item : items) {
            callProductAddSales(item.getProductId(), item.getQuantity());
        }

        messageService.sendOrderMessage(order.getUserId(), "订单支付成功", "您的订单支付成功，商家正在备货中", 1);
    }

    @Override
    @com.shopping.order.annotation.Idempotent
    public void deliver(String orderNo, String expressCompany, String trackingNo) {
        Order order = getByOrderNo(orderNo);
        if (order == null) throw new BusinessException("订单不存在");
        if (order.getStatus() != 1) throw new BusinessException("只有已支付订单可以发货");
        order.setStatus(2);
        order.setDeliveryTime(LocalDateTime.now());
        order.setExpressCompany(expressCompany);
        order.setTrackingNo(trackingNo);
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        messageService.sendOrderMessage(order.getUserId(), "订单已发货", "您的订单已发货，请注意查收", 1);
    }

    @Override
    public void confirmReceive(String orderNo) {
        Order order = getByOrderNo(orderNo);
        if (order == null) throw new BusinessException("订单不存在");
        if (order.getStatus() != 2) throw new BusinessException("只有已发货订单可以确认收货");
        order.setStatus(3);
        order.setReceiveTime(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());
        orderMapper.updateById(order);

        messageService.sendOrderMessage(order.getUserId(), "订单已完成", "您的订单已完成，感谢您的购买", 1);
    }

    @Override
    public void deleteOrder(String orderNo, Long userId) {
        Order order = getByOrderNo(orderNo);
        if (order == null) throw new BusinessException("订单不存在");
        if (!order.getUserId().equals(userId)) throw new BusinessException("无权操作此订单");
        if (order.getStatus() != 3 && order.getStatus() != 4 && order.getStatus() != 6) {
            throw new BusinessException("当前订单状态不支持删除");
        }
        orderMapper.deleteById(order.getId());
    }

    @Override
    @Transactional
    public void batchDeleteOrders(List<String> orderNos, Long userId) {
        if (orderNos == null || orderNos.isEmpty()) return;
        for (String orderNo : orderNos) {
            try {
                deleteOrder(orderNo, userId);
            } catch (BusinessException e) {
                log.warn("批量删除跳过订单: orderNo={}, reason={}", orderNo, e.getMessage());
            }
        }
    }

    @Override
    public Map<String, Object> listUserOrders(Long userId, Integer status, Integer page, Integer size) {
        Page<Order> p = new Page<>(page, size);
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<Order>()
                .eq(Order::getUserId, userId)
                .and(w -> w.isNull(Order::getParentOrderId).or().eq(Order::getParentOrderId, 0L))
                .orderByDesc(Order::getCreatedAt);
        if (status != null) wrapper.eq(Order::getStatus, status);
        Page<Order> result = orderMapper.selectPage(p, wrapper);

        List<Order> orders = result.getRecords();
        List<OrderVO> voList = new ArrayList<>();
        if (!orders.isEmpty()) {
            List<Long> orderIds = orders.stream().map(Order::getId).collect(Collectors.toList());
            List<OrderItem> allItems = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OrderItem>().in(OrderItem::getOrderId, orderIds));
            Map<Long, List<OrderItem>> itemMap = allItems.stream()
                    .collect(Collectors.groupingBy(OrderItem::getOrderId));
            for (Order order : orders) {
                OrderVO vo = new OrderVO();
                vo.setOrder(order);
                vo.setItems(itemMap.get(order.getId()));
                voList.add(vo);
            }
        }

        for (OrderVO vo : voList) {
            ensureFullAddress(vo.getOrder());
        }
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", voList);
        return data;
    }

    @Override
    public Map<String, Object> listMerchantOrders(Long merchantId, Integer status, Integer page, Integer size) {
        // 管理员视角（merchantId=0）：查询全部订单
        if (merchantId == null || merchantId == 0) {
            Page<Order> p = new Page<>(page, size);
            LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<Order>()
                    .orderByDesc(Order::getCreatedAt);
            if (status != null) wrapper.eq(Order::getStatus, status);
            Page<Order> result = orderMapper.selectPage(p, wrapper);

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

        // 兼容旧数据：同时包含 merchant_id 直接匹配的订单
        LambdaQueryWrapper<Order> directWrapper = new LambdaQueryWrapper<Order>()
                .eq(Order::getMerchantId, merchantId);
        if (status != null) directWrapper.eq(Order::getStatus, status);
        List<Order> directOrders = orderMapper.selectList(directWrapper);
        for (Order o : directOrders) {
            orderIds.add(o.getId());
        }

        if (orderIds.isEmpty()) {
            Map<String, Object> data = new HashMap<>();
            data.put("total", 0);
            data.put("list", new ArrayList<>());
            return data;
        }

        Page<Order> p = new Page<>(page, size);
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<Order>()
                .in(Order::getId, orderIds)
                .orderByDesc(Order::getCreatedAt);
        if (status != null) wrapper.eq(Order::getStatus, status);
        Page<Order> result = orderMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return data;
    }

    @Override
    public Map<String, Object> listAllOrders(String orderNo, Integer status, Long userId, Long merchantId, Integer page, Integer size) {
        Page<Order> p = new Page<>(page, size);
        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<Order>()
                .orderByDesc(Order::getCreatedAt);
        if (orderNo != null && !orderNo.trim().isEmpty()) {
            wrapper.like(Order::getOrderNo, orderNo.trim());
        }
        if (status != null) {
            wrapper.eq(Order::getStatus, status);
        }
        if (userId != null) {
            wrapper.eq(Order::getUserId, userId);
        }
        if (merchantId != null) {
            wrapper.eq(Order::getMerchantId, merchantId);
        }
        Page<Order> result = orderMapper.selectPage(p, wrapper);

        List<Order> orders = result.getRecords();
        List<OrderVO> voList = new ArrayList<>();
        if (!orders.isEmpty()) {
            List<Long> orderIds = orders.stream().map(Order::getId).collect(Collectors.toList());
            List<OrderItem> allItems = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OrderItem>().in(OrderItem::getOrderId, orderIds));
            Map<Long, List<OrderItem>> itemMap = allItems.stream()
                    .collect(Collectors.groupingBy(OrderItem::getOrderId));
            for (Order order : orders) {
                OrderVO vo = new OrderVO();
                vo.setOrder(order);
                vo.setItems(itemMap.get(order.getId()));
                voList.add(vo);
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", voList);
        return data;
    }

    // ========== 工具方法 ==========

    private Order checkDuplicateOrder(OrderCreateRequest request) {
        if (request.getUserId() == null || request.getItems() == null || request.getItems().isEmpty()) {
            return null;
        }
        LocalDateTime tenSecondsAgo = LocalDateTime.now().minusSeconds(10);
        List<Order> recentOrders = orderMapper.selectList(
                new LambdaQueryWrapper<Order>()
                        .eq(Order::getUserId, request.getUserId())
                        .eq(Order::getStatus, 0)
                        .ge(Order::getCreatedAt, tenSecondsAgo)
                        .orderByDesc(Order::getCreatedAt)
                        .last("LIMIT 10")
        );
        if (recentOrders == null || recentOrders.isEmpty()) {
            return null;
        }
        for (Order order : recentOrders) {
            List<OrderItem> orderItems = orderItemMapper.selectList(
                    new LambdaQueryWrapper<OrderItem>().eq(OrderItem::getOrderId, order.getId())
            );
            if (orderItems == null || orderItems.isEmpty()) continue;
            if (isSameItems(request.getItems(), orderItems)) {
                return order;
            }
        }
        return null;
    }

    private boolean isSameItems(List<OrderItemRequest> requestItems, List<OrderItem> orderItems) {
        if (requestItems.size() != orderItems.size()) {
            return false;
        }
        Map<Long, Integer> requestMap = new HashMap<>();
        for (OrderItemRequest item : requestItems) {
            requestMap.merge(item.getProductId(), item.getQuantity(), Integer::sum);
        }
        Map<Long, Integer> orderMap = new HashMap<>();
        for (OrderItem item : orderItems) {
            orderMap.merge(item.getProductId(), item.getQuantity(), Integer::sum);
        }
        return requestMap.equals(orderMap);
    }

    private List<Long> getCouponProductIds(Long templateId) {
        if (templateId == null) return null;
        LambdaQueryWrapper<MerchantCouponParticipation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantCouponParticipation::getTemplateId, templateId)
               .eq(MerchantCouponParticipation::getStatus, 2)
               .isNotNull(MerchantCouponParticipation::getProductId);
        List<MerchantCouponParticipation> list = merchantCouponParticipationMapper.selectList(wrapper);
        if (list == null || list.isEmpty()) return null;
        return list.stream()
            .map(MerchantCouponParticipation::getProductId)
            .filter(Objects::nonNull)
            .collect(Collectors.toList());
    }

    private String generateOrderNo() {
        return "O" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + String.format("%04d", new Random().nextInt(10000));
    }

    private Address queryAddress(Long userId, Long addressId) {
        try {
            String url = "http://localhost:8081/address/get?userId=" + userId + "&id=" + addressId;
            ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
            Map body = resp.getBody();
            if (body == null || body.get("data") == null) return null;
            Map addrMap = (Map) body.get("data");
            Address a = new Address();
            a.setId(Long.valueOf(addrMap.get("id").toString()));
            a.setReceiverName((String) addrMap.get("name"));
            a.setReceiverPhone((String) addrMap.get("phone"));
            a.setProvince((String) addrMap.get("province"));
            a.setCity((String) addrMap.get("city"));
            a.setDistrict((String) addrMap.get("district"));
            a.setDetailAddress((String) addrMap.get("detail"));
            return a;
        } catch (Exception e) {
            log.error("查询地址失败", e);
            return null;
        }
    }

    private Product queryProduct(Long productId) {
        try {
            if (productClient != null) {
                try {
                    Result<Product> result = productClient.getById(productId);
                    if (result != null && result.getCode() != null && result.getCode() == 200 && result.getData() != null) {
                        return result.getData();
                    }
                } catch (Exception e) {
                    log.warn("Feign调用商品服务失败，降级使用RestTemplate: productId={}", productId, e);
                }
            }
            String url = productServiceUrl + "/product/detail/" + productId;
            ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
            Map body = resp.getBody();
            if (body == null || body.get("data") == null) return null;
            Map pMap = (Map) body.get("data");
            Product p = new Product();
            p.setId(Long.valueOf(pMap.get("id").toString()));
            p.setName((String) pMap.get("name"));
            p.setMerchantId(Long.valueOf(pMap.get("merchantId").toString()));
            p.setPrice(new BigDecimal(pMap.get("price").toString()));
            p.setStock((Integer) pMap.get("stock"));
            p.setStatus((Integer) pMap.get("status"));
            p.setImageUrl((String) pMap.get("imageUrl"));
            return p;
        } catch (Exception e) {
            log.error("查询商品失败", e);
            return null;
        }
    }

    private Boolean callProductDeductStock(Long productId, Integer quantity) {
        try {
            if (productClient != null) {
                try {
                    Result<Product> result = productClient.deductStock(productId, quantity);
                    if (result != null && result.getCode() != null && result.getCode() == 200) {
                        return true;
                    }
                } catch (Exception e) {
                    log.warn("Feign调用扣减库存失败，降级使用RestTemplate: productId={}", productId, e);
                }
            }
            String url = productServiceUrl + "/product/deductStock?productId=" + productId + "&quantity=" + quantity;
            ResponseEntity<Map> resp = restTemplate.postForEntity(url, null, Map.class);
            Map body = resp.getBody();
            return body != null && Integer.valueOf(200).equals(body.get("code"));
        } catch (Exception e) {
            log.error("扣减库存失败", e);
            return false;
        }
    }

    private void callProductAddStock(Long productId, Integer quantity) {
        try {
            if (productClient != null) {
                try {
                    productClient.addStock(productId, quantity);
                    return;
                } catch (Exception e) {
                    log.warn("Feign调用恢复库存失败，降级使用RestTemplate: productId={}", productId, e);
                }
            }
            String url = productServiceUrl + "/product/addStock?productId=" + productId + "&quantity=" + quantity;
            restTemplate.postForEntity(url, null, Map.class);
        } catch (Exception e) {
            log.error("恢复库存失败", e);
        }
    }

    private void callProductAddSales(Long productId, Integer quantity) {
        try {
            String url = "http://localhost:8082/product/addSales?productId=" + productId + "&quantity=" + quantity;
            restTemplate.postForEntity(url, null, Map.class);
        } catch (Exception e) {
            log.error("增加销量失败", e);
        }
    }

    private Long queryGroupTeamId(String teamNo) {
        try {
            String url = marketingServiceUrl + "/group/team/" + teamNo;
            ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
            Map body = resp.getBody();
            if (body == null || body.get("data") == null) return null;
            Map dataMap = (Map) body.get("data");
            Map teamMap = (Map) dataMap.get("team");
            if (teamMap == null || teamMap.get("id") == null) return null;
            return Long.valueOf(teamMap.get("id").toString());
        } catch (Exception e) {
            log.error("查询拼团团队失败: teamNo={}", teamNo, e);
            return null;
        }
    }
}
