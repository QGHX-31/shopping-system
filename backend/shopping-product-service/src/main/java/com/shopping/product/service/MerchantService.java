package com.shopping.product.service;

import com.shopping.common.entity.Merchant;
import com.shopping.common.entity.MerchantStats;
import java.util.Map;

public interface MerchantService {
    Merchant login(String username, String password);
    Merchant register(String username, String password, String shopName, String contactName, String contactPhone, String email);
    Map<String, Object> getMerchantList(Integer page, Integer size, String keyword, Integer status);
    Merchant getMerchantById(Long id);
    boolean updateMerchantStatus(Long id, Integer status);
    MerchantStats getMerchantStats(Long merchantId);
    Map<String, Object> listMerchantProducts(Long merchantId, String keyword, Integer page, Integer size);
    boolean toggleProductStatus(Long productId, Integer status);
    boolean deleteProduct(Long productId);
}
