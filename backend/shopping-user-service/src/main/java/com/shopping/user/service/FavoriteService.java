package com.shopping.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.common.entity.Favorite;

import java.util.List;

public interface FavoriteService extends IService<Favorite> {
    List<Favorite> getFavoriteList(Long userId);
    void addFavorite(Long userId, Long productId);
    void removeFavorite(Long favoriteId);
    boolean isFavorite(Long userId, Long productId);
}
