package com.shopping.product.service;

import com.shopping.common.entity.ProductSku;
import java.util.List;

public interface SkuService {
    List<ProductSku> listSkusByProductId(Long productId);
    boolean adjustStock(Long skuId, Integer count);
    boolean lockStock(Long skuId, Integer count);
    boolean releaseStock(Long skuId, Integer count);
    boolean deductStock(Long skuId, Integer count);
    boolean rollbackStock(Long skuId, Integer count);
}
