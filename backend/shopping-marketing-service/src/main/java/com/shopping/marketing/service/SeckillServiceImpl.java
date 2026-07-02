package com.shopping.marketing.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.Product;
import com.shopping.common.entity.SeckillActivity;
import com.shopping.common.entity.SeckillOrder;
import com.shopping.common.entity.SeckillProduct;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.mq.MqMessageSender;
import com.shopping.common.mq.MqTopic;
import com.shopping.common.utils.RedisUtil;
import com.shopping.common.utils.Result;
import com.shopping.marketing.mapper.ProductMapper;
import com.shopping.marketing.mapper.SeckillActivityMapper;
import com.shopping.marketing.mapper.SeckillOrderMapper;
import com.shopping.marketing.mapper.SeckillProductMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class SeckillServiceImpl implements SeckillService {

    @Resource
    private SeckillActivityMapper seckillActivityMapper;
    
    @Resource
    private SeckillProductMapper seckillProductMapper;
    
    @Resource
    private SeckillOrderMapper seckillOrderMapper;
    
    @Resource
    private RedisUtil redisUtil;

    @Resource
    private MqMessageSender mqMessageSender;

    @Resource
    private ProductMapper productMapper;

    private static final String SECKILL_STOCK_KEY = "seckill:stock:";
    private static final String SECKILL_USER_LIMIT_KEY = "seckill:user:limit:";

    @Override
    public Map<String, Object> getActiveActivities() {
        LambdaQueryWrapper<SeckillActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SeckillActivity::getStatus, 1)
               .ge(SeckillActivity::getEndTime, LocalDateTime.now())
               .orderByAsc(SeckillActivity::getStartTime)
               .last("LIMIT 20");
        List<SeckillActivity> activities = seckillActivityMapper.selectList(wrapper);
        
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (SeckillActivity activity : activities) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", activity.getId());
            map.put("name", activity.getName());
            map.put("productId", activity.getProductId());
            map.put("seckillPrice", activity.getSeckillPrice());
            map.put("originalPrice", activity.getOriginalPrice());
            map.put("totalStock", activity.getTotalStock());
            map.put("availableStock", activity.getAvailableStock());
            map.put("startTime", activity.getStartTime());
            map.put("endTime", activity.getEndTime());
            map.put("status", activity.getStatus());
            
            if (activity.getProductId() != null) {
                Product product = productMapper.selectById(activity.getProductId());
                if (product != null) {
                    map.put("productName", product.getName());
                    map.put("imageUrl", product.getImageUrl());
                    map.put("salesCount", product.getSalesCount());
                } else {
                    map.put("productName", "未知商品");
                    map.put("imageUrl", "");
                }
            } else {
                map.put("productName", "未知商品");
                map.put("imageUrl", "");
            }
            
            resultList.add(map);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultList);
        result.put("total", resultList.size());
        return result;
    }

    @Override
    public Map<String, Object> getActivityList(Long merchantId, Integer status, Integer page, Integer size) {
        Page<SeckillActivity> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<SeckillActivity> wrapper = new LambdaQueryWrapper<>();
        if (merchantId != null) {
            wrapper.eq(SeckillActivity::getMerchantId, merchantId);
        }
        if (status != null) {
            wrapper.eq(SeckillActivity::getStatus, status);
        }
        wrapper.orderByDesc(SeckillActivity::getCreatedAt);
        
        Page<SeckillActivity> resultPage = seckillActivityMapper.selectPage(pageObj, wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    @Override
    public Map<String, Object> getActivityDetail(Long id) {
        SeckillActivity activity = seckillActivityMapper.selectById(id);
        if (activity == null) {
            return null;
        }
        
        LambdaQueryWrapper<SeckillProduct> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SeckillProduct::getActivityId, id);
        List<SeckillProduct> products = seckillProductMapper.selectList(wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("activity", activity);
        result.put("products", products);
        return result;
    }

    @Override
    @Transactional
    public SeckillActivity createActivity(SeckillActivity activity) {
        if (activity.getProductId() != null && activity.getSeckillPrice() != null) {
            Product product = productMapper.selectById(activity.getProductId());
            if (product != null && product.getPrice() != null) {
                if (activity.getSeckillPrice().compareTo(product.getPrice()) >= 0) {
                    throw new BusinessException("秒杀价必须低于商品售价（拼团价）");
                }
            }
        }
        activity.setStatus(1);
        activity.setCreatedAt(LocalDateTime.now());
        activity.setUpdatedAt(LocalDateTime.now());
        seckillActivityMapper.insert(activity);
        
        if (activity.getAvailableStock() != null) {
            String stockKey = SECKILL_STOCK_KEY + activity.getId();
            redisUtil.set(stockKey, activity.getAvailableStock());
        }
        
        return activity;
    }

    @Override
    @Transactional
    public SeckillActivity updateActivity(Long id, SeckillActivity activity) {
        SeckillActivity exist = seckillActivityMapper.selectById(id);
        if (exist == null) {
            return null;
        }
        if (activity.getSeckillPrice() != null) {
            Long productId = activity.getProductId() != null ? activity.getProductId() : exist.getProductId();
            if (productId != null) {
                Product product = productMapper.selectById(productId);
                if (product != null && product.getPrice() != null) {
                    if (activity.getSeckillPrice().compareTo(product.getPrice()) >= 0) {
                        throw new BusinessException("秒杀价必须低于商品售价（拼团价）");
                    }
                }
            }
        }
        if (activity.getName() != null) exist.setName(activity.getName());
        if (activity.getMerchantId() != null) exist.setMerchantId(activity.getMerchantId());
        if (activity.getProductId() != null) exist.setProductId(activity.getProductId());
        if (activity.getSkuId() != null) exist.setSkuId(activity.getSkuId());
        if (activity.getSeckillPrice() != null) exist.setSeckillPrice(activity.getSeckillPrice());
        if (activity.getOriginalPrice() != null) exist.setOriginalPrice(activity.getOriginalPrice());
        if (activity.getTotalStock() != null) exist.setTotalStock(activity.getTotalStock());
        if (activity.getAvailableStock() != null) exist.setAvailableStock(activity.getAvailableStock());
        if (activity.getStartTime() != null) exist.setStartTime(activity.getStartTime());
        if (activity.getEndTime() != null) exist.setEndTime(activity.getEndTime());
        if (activity.getDescription() != null) exist.setDescription(activity.getDescription());
        if (activity.getBanner() != null) exist.setBanner(activity.getBanner());
        exist.setUpdatedAt(LocalDateTime.now());
        seckillActivityMapper.updateById(exist);
        
        String stockKey = SECKILL_STOCK_KEY + id;
        redisUtil.set(stockKey, exist.getAvailableStock());
        
        return exist;
    }

    @Override
    @Transactional
    public boolean updateActivityStatus(Long id, Integer status) {
        SeckillActivity activity = seckillActivityMapper.selectById(id);
        if (activity == null) {
            return false;
        }
        activity.setStatus(status);
        activity.setUpdatedAt(LocalDateTime.now());
        seckillActivityMapper.updateById(activity);
        return true;
    }

    @Override
    @Transactional
    public boolean deleteActivity(Long id) {
        SeckillActivity activity = seckillActivityMapper.selectById(id);
        if (activity == null) {
            return false;
        }
        seckillActivityMapper.deleteById(id);
        
        String stockKey = SECKILL_STOCK_KEY + id;
        redisUtil.delete(stockKey);
        
        return true;
    }

    @Override
    @Transactional
    public SeckillProduct addProductToActivity(SeckillProduct product) {
        product.setCreatedAt(LocalDateTime.now());
        seckillProductMapper.insert(product);
        
        String stockKey = SECKILL_STOCK_KEY + product.getId();
        redisUtil.set(stockKey, product.getAvailableStock());
        
        return product;
    }

    @Override
    @Transactional
    @com.shopping.common.annotation.DistributedLock(key = "'seckill:order:' + #activityId + ':' + #userId", waitTime = 3, leaseTime = 10)
    public Map<String, Object> placeOrder(Long activityId, Long productId, Long skuId, Long userId, Integer quantity) {
        Map<String, Object> result = new HashMap<>();
        
        SeckillProduct product = seckillProductMapper.selectById(productId);
        if (product == null) {
            result.put("success", false);
            result.put("message", "Product not found");
            return result;
        }
        
        String stockKey = SECKILL_STOCK_KEY + productId;
        String userLimitKey = SECKILL_USER_LIMIT_KEY + productId + ":" + userId;
        
        // 确保Redis中有库存（使用纯字符串格式，让Lua脚本能正确处理）
        String stockStr = redisUtil.getRawString(stockKey);
        if (stockStr == null) {
            stockStr = String.valueOf(product.getAvailableStock());
            redisUtil.setRawString(stockKey, stockStr);
        }
        
        // 原子扣减库存（使用Lua脚本防止超卖）
        // 返回值：>=0 表示扣减成功，-1 表示库存不足，-2 表示key不存在
        Long newStock = redisUtil.atomicDecrementStrict(stockKey, quantity);
        if (newStock == -1L) {
            result.put("success", false);
            result.put("message", "Insufficient stock");
            return result;
        }
        if (newStock == -2L) {
            // 库存key不存在，重新设置后再试一次
            redisUtil.setRawString(stockKey, String.valueOf(product.getAvailableStock()));
            newStock = redisUtil.atomicDecrementStrict(stockKey, quantity);
            if (newStock == -1L || newStock == -2L) {
                result.put("success", false);
                result.put("message", "Insufficient stock");
                return result;
            }
        }
        
        try {
            // 用户限购校验
            Integer userLimit = product.getLimitPerUser();
            Long userBought = redisUtil.get(userLimitKey, Long.class);
            if (userBought == null) {
                LambdaQueryWrapper<SeckillOrder> orderWrapper = new LambdaQueryWrapper<>();
                orderWrapper.eq(SeckillOrder::getUserId, userId)
                           .eq(SeckillOrder::getProductId, productId);
                userBought = (long) seckillOrderMapper.selectCount(orderWrapper);
            }
            
            if (userBought + quantity > userLimit) {
                // 超过用户限购，回滚库存
                redisUtil.atomicIncrement(stockKey, quantity);
                result.put("success", false);
                result.put("message", "Purchase limit exceeded");
                return result;
            }
            
            redisUtil.increment(userLimitKey, quantity);
            
            SeckillOrder order = new SeckillOrder();
            order.setOrderNo("SK" + System.currentTimeMillis() + new Random().nextInt(1000));
            order.setUserId(userId);
            order.setActivityId(activityId);
            order.setProductId(productId);
            order.setSkuId(skuId);
            order.setQuantity(quantity);
            order.setSeckillPrice(product.getSeckillPrice());
            order.setTotalAmount(product.getSeckillPrice().multiply(new java.math.BigDecimal(quantity)));
            order.setStatus(0);
            order.setCreatedAt(LocalDateTime.now());
            seckillOrderMapper.insert(order);
            
            product.setAvailableStock(newStock.intValue());
            product.setSalesCount(product.getSalesCount() + quantity);
            seckillProductMapper.updateById(product);

            Map<String, Object> mqBody = new HashMap<>();
            mqBody.put("orderNo", order.getOrderNo());
            mqBody.put("userId", userId);
            mqBody.put("productId", productId);
            mqBody.put("skuId", skuId);
            mqBody.put("quantity", quantity);
            mqBody.put("activityId", activityId);
            mqBody.put("amount", order.getTotalAmount());
            mqMessageSender.send(MqTopic.SECKILL_PLACE, "seckill", order.getOrderNo(), mqBody);

            if (product.getAvailableStock() <= 0) {
                mqMessageSender.send(MqTopic.SECKILL_END, mqBody);
            }

            result.put("success", true);
            result.put("order", order);
            return result;
            
        } catch (Exception e) {
            // 业务异常，回滚库存
            redisUtil.atomicIncrement(stockKey, quantity);
            throw e;
        }
    }

    @Override
    public Map<String, Object> getUserOrders(Long userId, Integer page, Integer size) {
        Page<SeckillOrder> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<SeckillOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SeckillOrder::getUserId, userId)
               .orderByDesc(SeckillOrder::getCreatedAt);
        Page<SeckillOrder> resultPage = seckillOrderMapper.selectPage(pageObj, wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    @Override
    public Map<String, Object> getMerchantOrders(Long merchantId, Integer page, Integer size) {
        Page<SeckillOrder> pageObj = new Page<>(page, size);
        
        String sql = "SELECT so.*, sa.name as activity_name, sp.seckill_price, sp.original_price " +
                     "FROM seckill_order so " +
                     "LEFT JOIN seckill_activity sa ON so.activity_id = sa.id " +
                     "LEFT JOIN seckill_product sp ON so.product_id = sp.id " +
                     "WHERE sa.merchant_id = " + merchantId +
                     " ORDER BY so.created_at DESC";
        
        List<Map<String, Object>> list = seckillOrderMapper.selectMaps(new QueryWrapper<SeckillOrder>().apply(sql));
        long total = list.size();
        
        int start = (page - 1) * size;
        int end = Math.min(start + size, list.size());
        List<Map<String, Object>> pageList = start < list.size() ? list.subList(start, end) : new ArrayList<>();
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", pageList);
        result.put("total", total);
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    @Override
    @Transactional
    public boolean deliverOrder(Long orderId, String trackingNo) {
        SeckillOrder order = seckillOrderMapper.selectById(orderId);
        if (order == null || order.getStatus() != 1) {
            return false;
        }
        order.setStatus(2);
        order.setPayTime(LocalDateTime.now());
        seckillOrderMapper.updateById(order);
        return true;
    }
}
