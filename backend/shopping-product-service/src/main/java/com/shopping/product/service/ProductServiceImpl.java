package com.shopping.product.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.Product;
import com.shopping.common.entity.ProductSku;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.utils.RedisUtil;
import com.shopping.product.mapper.ProductMapper;
import com.shopping.product.mapper.SkuMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class ProductServiceImpl implements ProductService {

    @Resource
    private ProductMapper productMapper;

    @Resource
    private SkuMapper skuMapper;

    @Resource
    private RedisUtil redisUtil;

    private static final String PRODUCT_CACHE_KEY = "product:detail:";
    private static final long CACHE_TTL_MINUTES = 30;

    @Override
    public Map<String, Object> listProducts(Long categoryId, String keyword, String sortBy, Double priceMin, Double priceMax, Integer page, Integer size) {
        page = page == null || page < 1 ? 1 : page;
        size = size == null || size < 1 ? 12 : size;

        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null && categoryId > 0) {
            wrapper.eq(Product::getCategoryId, categoryId);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(Product::getName, keyword);
        }
        if (priceMin != null) {
            wrapper.ge(Product::getPrice, priceMin);
        }
        if (priceMax != null) {
            wrapper.le(Product::getPrice, priceMax);
        }

        if ("price_asc".equals(sortBy)) {
            wrapper.orderByAsc(Product::getPrice);
        } else if ("price_desc".equals(sortBy)) {
            wrapper.orderByDesc(Product::getPrice);
        } else if ("sales".equals(sortBy)) {
            wrapper.orderByDesc(Product::getSalesCount);
        } else if ("hot".equals(sortBy)) {
            wrapper.eq(Product::getIsHot, 1)
                   .orderByDesc(Product::getSalesCount);
        } else if ("new".equals(sortBy)) {
            wrapper.eq(Product::getIsNew, 1)
                   .orderByDesc(Product::getCreatedAt);
        } else {
            wrapper.orderByDesc(Product::getCreatedAt);
        }

        IPage<Product> productPage = new Page<>(page, size);
        IPage<Product> resultPage = productMapper.selectPage(productPage, wrapper);

        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", resultPage.getCurrent());
        result.put("size", resultPage.getSize());
        return result;
    }

    @Override
    public Product getProductById(Long id) {
        return productMapper.selectById(id);
    }

    @Override
    @Transactional
    public Product createProduct(Product product) {
        productMapper.insert(product);
        return product;
    }

    @Override
    @Transactional
    public Product updateProduct(Product product) {
        productMapper.updateById(product);
        Product updated = productMapper.selectById(product.getId());
        if (updated != null) {
            redisUtil.delete(PRODUCT_CACHE_KEY + product.getId());
        }
        return updated;
    }

    @Override
    @Transactional
    public boolean updateProductStatus(Long id, Integer status) {
        Product product = new Product();
        product.setId(id);
        product.setStatus(status);
        boolean result = productMapper.updateById(product) > 0;
        if (result) {
            redisUtil.delete(PRODUCT_CACHE_KEY + id);
        }
        return result;
    }

    @Override
    public List<Product> getHotProducts() {
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Product::getIsHot, 1)
               .eq(Product::getStatus, 1)
               .orderByDesc(Product::getSalesCount)
               .last("LIMIT 8");
        return productMapper.selectList(wrapper);
    }

    @Override
    public List<Product> getNewProducts() {
        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Product::getIsNew, 1)
               .eq(Product::getStatus, 1)
               .orderByDesc(Product::getCreatedAt)
               .last("LIMIT 8");
        return productMapper.selectList(wrapper);
    }

    // ====== 订单服务远程调用（内部接口） ======

    @Override
    @Transactional
    public Product deductStock(Long productId, Integer quantity) {
        return deductStock(productId, null, quantity);
    }

    @Override
    @Transactional
    public Product deductStock(Long productId, Long skuId, Integer quantity) {
        if (productId == null || quantity == null || quantity <= 0) {
            throw new BusinessException("参数错误");
        }
        Product product = productMapper.selectById(productId);
        if (product == null) throw new BusinessException("商品不存在: " + productId);
        if (product.getStatus() != 1) throw new BusinessException("商品已下架");
        if (product.getStock() == null || product.getStock() < quantity) {
            throw new BusinessException(product.getName() + " 库存不足");
        }

        if (skuId != null) {
            ProductSku sku = skuMapper.selectById(skuId);
            if (sku == null) {
                throw new BusinessException("SKU不存在");
            }
            if (sku.getStock() == null || sku.getStock() < quantity) {
                throw new BusinessException(product.getName() + " 规格库存不足");
            }
            ProductSku updateSku = new ProductSku();
            updateSku.setId(skuId);
            updateSku.setStock(sku.getStock() - quantity);
            skuMapper.updateById(updateSku);
        }

        product.setStock(product.getStock() - quantity);
        productMapper.updateById(product);
        redisUtil.delete(PRODUCT_CACHE_KEY + productId);
        return productMapper.selectById(productId);
    }

    @Override
    @Transactional
    public Product addStock(Long productId, Integer quantity) {
        return addStock(productId, null, quantity);
    }

    @Override
    @Transactional
    public Product addStock(Long productId, Long skuId, Integer quantity) {
        if (productId == null || quantity == null || quantity <= 0) {
            throw new BusinessException("参数错误");
        }
        Product product = productMapper.selectById(productId);
        if (product == null) throw new BusinessException("商品不存在: " + productId);

        if (skuId != null) {
            ProductSku sku = skuMapper.selectById(skuId);
            if (sku != null) {
                ProductSku updateSku = new ProductSku();
                updateSku.setId(skuId);
                updateSku.setStock((sku.getStock() == null ? 0 : sku.getStock()) + quantity);
                skuMapper.updateById(updateSku);
            }
        }

        product.setStock((product.getStock() == null ? 0 : product.getStock()) + quantity);
        productMapper.updateById(product);
        redisUtil.delete(PRODUCT_CACHE_KEY + productId);
        return productMapper.selectById(productId);
    }

    @Override
    @Transactional
    public Product addSales(Long productId, Integer quantity) {
        if (productId == null || quantity == null || quantity <= 0) {
            throw new BusinessException("参数错误");
        }
        Product product = productMapper.selectById(productId);
        if (product == null) throw new BusinessException("商品不存在: " + productId);
        product.setSalesCount((product.getSalesCount() == null ? 0 : product.getSalesCount()) + quantity);
        productMapper.updateById(product);
        redisUtil.delete(PRODUCT_CACHE_KEY + productId);
        return productMapper.selectById(productId);
    }

    @Override
    public Long getProductCount() {
        return productMapper.selectCount(new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<com.shopping.common.entity.Product>()
                .eq(com.shopping.common.entity.Product::getStatus, 1));
    }

    @Override
    public Map<String, Object> listMerchantProducts(Long merchantId, Integer page, Integer size) {
        page = page == null || page < 1 ? 1 : page;
        size = size == null || size < 1 ? 10 : size;

        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        if (merchantId != null) {
            wrapper.eq(Product::getMerchantId, merchantId);
        }
        wrapper.orderByDesc(Product::getCreatedAt);

        IPage<Product> productPage = new Page<>(page, size);
        IPage<Product> resultPage = productMapper.selectPage(productPage, wrapper);

        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", resultPage.getCurrent());
        result.put("size", resultPage.getSize());
        return result;
    }

    @Override
    @Transactional
    public void updateProductTotalStock(Long productId) {
        if (productId == null) return;

        LambdaQueryWrapper<ProductSku> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ProductSku::getProductId, productId);
        wrapper.eq(ProductSku::getStatus, 1);
        List<ProductSku> skus = skuMapper.selectList(wrapper);

        int totalStock = 0;
        if (skus != null && !skus.isEmpty()) {
            for (ProductSku sku : skus) {
                totalStock += sku.getStock() == null ? 0 : sku.getStock();
            }
        }

        Product product = new Product();
        product.setId(productId);
        product.setStock(totalStock);
        productMapper.updateById(product);

        redisUtil.delete(PRODUCT_CACHE_KEY + productId);
    }
}
