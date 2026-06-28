package com.shopping.product.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.entity.ProductSku;
import com.shopping.common.entity.StockLog;
import com.shopping.common.mq.MqMessageSender;
import com.shopping.common.mq.MqTopic;
import com.shopping.common.utils.RedisUtil;
import com.shopping.product.mapper.SkuMapper;
import com.shopping.product.mapper.StockLogMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class SkuServiceImpl implements SkuService {

    @Resource
    private SkuMapper skuMapper;

    @Resource
    private StockLogMapper stockLogMapper;

    @Resource
    private RedisUtil redisUtil;

    @Resource
    private MqMessageSender mqMessageSender;

    private static final String STOCK_LOCK_PREFIX = "sku:lock:stock:";
    private static final String SKU_STOCK_PREFIX = "sku:stock:";

    @Override
    public List<ProductSku> listSkusByProductId(Long productId) {
        LambdaQueryWrapper<ProductSku> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ProductSku::getProductId, productId);
        return skuMapper.selectList(wrapper);
    }

    @Override
    @Transactional
    public boolean adjustStock(Long skuId, Integer count) {
        ProductSku sku = skuMapper.selectById(skuId);
        if (sku == null) {
            return false;
        }
        int newStock = sku.getStock() + count;
        if (newStock < 0) {
            return false;
        }
        sku.setStock(newStock);
        return skuMapper.updateById(sku) > 0;
    }

    @Override
    @Transactional
    public boolean lockStock(Long skuId, Integer count) {
        String lockKey = STOCK_LOCK_PREFIX + skuId;
        String stockKey = SKU_STOCK_PREFIX + skuId;

        ProductSku sku = skuMapper.selectById(skuId);
        if (sku == null || sku.getStock() < count) {
            return false;
        }

        Long currentLock = redisUtil.get(lockKey, Long.class);
        if (currentLock == null) {
            currentLock = 0L;
        }

        redisUtil.set(lockKey, currentLock + count);
        redisUtil.decrement(stockKey, count);

        ProductSku updateSku = new ProductSku();
        updateSku.setId(skuId);
        updateSku.setLockedStock(sku.getLockedStock() + count);
        skuMapper.updateById(updateSku);

        saveStockLog(skuId, 1, count, "lock");

        Map<String, Object> mqBody = new HashMap<>();
        mqBody.put("skuId", skuId);
        mqBody.put("productId", sku.getProductId());
        mqBody.put("count", count);
        mqBody.put("type", "lock");
        mqMessageSender.send(MqTopic.STOCK_DEDUCT, "stock", skuId + ":" + UUID.randomUUID(), mqBody);

        return true;
    }

    @Override
    @Transactional
    public boolean releaseStock(Long skuId, Integer count) {
        String lockKey = STOCK_LOCK_PREFIX + skuId;
        String stockKey = SKU_STOCK_PREFIX + skuId;

        Long currentLock = redisUtil.get(lockKey, Long.class);
        if (currentLock == null || currentLock < count) {
            return false;
        }

        redisUtil.set(lockKey, currentLock - count);
        redisUtil.increment(stockKey, count);

        ProductSku sku = skuMapper.selectById(skuId);
        if (sku != null) {
            ProductSku updateSku = new ProductSku();
            updateSku.setId(skuId);
            updateSku.setLockedStock(Math.max(0, sku.getLockedStock() - count));
            skuMapper.updateById(updateSku);
        }

        saveStockLog(skuId, 2, count, "release");
        return true;
    }

    @Override
    @Transactional
    public boolean deductStock(Long skuId, Integer count) {
        String lockKey = STOCK_LOCK_PREFIX + skuId;
        String stockKey = SKU_STOCK_PREFIX + skuId;

        Long currentLock = redisUtil.get(lockKey, Long.class);
        if (currentLock == null || currentLock < count) {
            return false;
        }

        redisUtil.set(lockKey, currentLock - count);

        ProductSku sku = skuMapper.selectById(skuId);
        if (sku != null) {
            ProductSku updateSku = new ProductSku();
            updateSku.setId(skuId);
            updateSku.setLockedStock(Math.max(0, sku.getLockedStock() - count));
            updateSku.setSalesCount(sku.getSalesCount() + count);
            skuMapper.updateById(updateSku);
        }

        saveStockLog(skuId, 3, count, "deduct");
        return true;
    }

    @Override
    @Transactional
    public boolean rollbackStock(Long skuId, Integer count) {
        String stockKey = SKU_STOCK_PREFIX + skuId;
        redisUtil.increment(stockKey, count);

        ProductSku sku = skuMapper.selectById(skuId);
        if (sku != null) {
            ProductSku updateSku = new ProductSku();
            updateSku.setId(skuId);
            updateSku.setSalesCount(Math.max(0, sku.getSalesCount() - count));
            skuMapper.updateById(updateSku);
        }

        saveStockLog(skuId, 4, count, "rollback");
        return true;
    }

    private void saveStockLog(Long skuId, Integer type, Integer quantity, String refNo) {
        StockLog stockLog = new StockLog();
        stockLog.setSkuId(skuId);
        stockLog.setType(type);
        stockLog.setQuantity(quantity);
        stockLog.setRefNo(refNo + ":" + UUID.randomUUID().toString());
        stockLogMapper.insert(stockLog);
    }
}
