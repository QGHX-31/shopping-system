package com.shopping.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.common.entity.Cart;
import com.shopping.common.utils.RedisUtil;
import com.shopping.user.mapper.CartMapper;
import com.shopping.user.service.CartService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Service
public class CartServiceImpl extends ServiceImpl<CartMapper, Cart> implements CartService {
    @Resource
    private CartMapper cartMapper;
    @Resource
    private RedisUtil redisUtil;

    @Override
    public List<Cart> getCartList(Long userId) {
        String key = "cart:list:" + userId;
        List<Cart> cartList = redisUtil.get(key, new com.alibaba.fastjson2.TypeReference<List<Cart>>() {});
        if (cartList != null) {
            return cartList;
        }
        cartList = cartMapper.selectList(new LambdaQueryWrapper<Cart>().eq(Cart::getUserId, userId));
        if (cartList != null && !cartList.isEmpty()) {
            redisUtil.set(key, cartList, 10, TimeUnit.MINUTES);
        }
        return cartList;
    }

    @Override
    public void addToCart(Long userId, Long productId, Long skuId, Integer quantity) {
        LambdaQueryWrapper<Cart> wrapper = new LambdaQueryWrapper<Cart>()
                .eq(Cart::getUserId, userId)
                .eq(Cart::getProductId, productId);
        if (skuId != null) {
            wrapper.eq(Cart::getSkuId, skuId);
        } else {
            wrapper.isNull(Cart::getSkuId);
        }
        Cart existing = cartMapper.selectOne(wrapper);
        if (existing != null) {
            existing.setQuantity(existing.getQuantity() + quantity);
            cartMapper.updateById(existing);
        } else {
            Cart cart = new Cart();
            cart.setUserId(userId);
            cart.setProductId(productId);
            cart.setSkuId(skuId);
            cart.setQuantity(quantity);
            cart.setSelected(1);
            cartMapper.insert(cart);
        }
        String key = "cart:list:" + userId;
        redisUtil.delete(key);
    }

    @Override
    public void updateCart(Long cartId, Integer quantity) {
        Cart cart = cartMapper.selectById(cartId);
        if (cart != null) {
            cart.setQuantity(quantity);
            cartMapper.updateById(cart);
            String key = "cart:list:" + cart.getUserId();
            redisUtil.delete(key);
        }
    }

    @Override
    public void deleteCart(Long cartId) {
        Cart cart = cartMapper.selectById(cartId);
        if (cart != null) {
            cartMapper.deleteById(cartId);
            String key = "cart:list:" + cart.getUserId();
            redisUtil.delete(key);
        }
    }

    @Override
    public void batchDelete(List<Long> cartIds) {
        if (cartIds == null || cartIds.isEmpty()) return;
        List<Cart> carts = cartMapper.selectBatchIds(cartIds);
        if (carts == null || carts.isEmpty()) return;
        cartMapper.deleteBatchIds(cartIds);
        Set<Long> userIds = carts.stream()
                .map(Cart::getUserId)
                .collect(java.util.stream.Collectors.toSet());
        for (Long userId : userIds) {
            String key = "cart:list:" + userId;
            redisUtil.delete(key);
        }
    }

    @Override
    public void toggleSelect(Long cartId, Integer selected) {
        Cart cart = cartMapper.selectById(cartId);
        if (cart != null) {
            cart.setSelected(selected);
            cartMapper.updateById(cart);
            String key = "cart:list:" + cart.getUserId();
            redisUtil.delete(key);
        }
    }

    @Override
    public void toggleSelectAll(Long userId, Integer selected) {
        List<Cart> cartList = cartMapper.selectList(new LambdaQueryWrapper<Cart>().eq(Cart::getUserId, userId));
        for (Cart cart : cartList) {
            cart.setSelected(selected);
            cartMapper.updateById(cart);
        }
        String key = "cart:list:" + userId;
        redisUtil.delete(key);
    }
}
