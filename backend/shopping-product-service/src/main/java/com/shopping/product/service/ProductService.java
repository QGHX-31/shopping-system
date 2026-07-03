package com.shopping.product.service;

import com.shopping.common.entity.Product;
import java.util.Map;

public interface ProductService {
    Map<String, Object> listProducts(Long categoryId, String keyword, String sortBy, Double priceMin, Double priceMax, Integer page, Integer size);
    Product getProductById(Long id);
    Product createProduct(Product product);
    Product updateProduct(Product product);
    boolean updateProductStatus(Long id, Integer status);
    java.util.List<Product> getHotProducts();
    java.util.List<Product> getNewProducts();

    // ====== 订单服务远程调用（内部接口） ======
    /** 扣减库存（库存不足抛 BusinessException），返回最新商品 */
    Product deductStock(Long productId, Integer quantity);
    /** 扣减SKU库存（skuId为空时只扣总库存） */
    Product deductStock(Long productId, Long skuId, Integer quantity);
    /** 恢复库存（取消订单时用） */
    Product addStock(Long productId, Integer quantity);
    /** 恢复SKU库存（skuId为空时只恢复总库存） */
    Product addStock(Long productId, Long skuId, Integer quantity);
    /** 增加销量（支付成功回调时用） */
    Product addSales(Long productId, Integer quantity);

    Long getProductCount();

    Map<String, Object> listMerchantProducts(Long merchantId, Integer page, Integer size);

    void updateProductTotalStock(Long productId);
}
