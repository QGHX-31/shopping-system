package com.shopping.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.common.entity.Cart;

import java.util.List;

public interface CartService extends IService<Cart> {
    List<Cart> getCartList(Long userId);
    void addToCart(Long userId, Long productId, Integer quantity);
    void updateCart(Long cartId, Integer quantity);
    void deleteCart(Long cartId);
    void batchDelete(List<Long> cartIds);
    void toggleSelect(Long cartId, Integer selected);
    void toggleSelectAll(Long userId, Integer selected);
}
