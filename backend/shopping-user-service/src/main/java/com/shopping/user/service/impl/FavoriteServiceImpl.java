package com.shopping.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.common.entity.Favorite;
import com.shopping.common.utils.RedisUtil;
import com.shopping.user.mapper.FavoriteMapper;
import com.shopping.user.service.FavoriteService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {
    @Resource
    private FavoriteMapper favoriteMapper;
    @Resource
    private RedisUtil redisUtil;

    @Override
    public List<Favorite> getFavoriteList(Long userId) {
        String key = "favorite:list:" + userId;
        List<Favorite> favoriteList = redisUtil.get(key, new com.alibaba.fastjson2.TypeReference<List<Favorite>>() {});
        if (favoriteList != null) {
            return favoriteList;
        }
        favoriteList = favoriteMapper.selectList(new LambdaQueryWrapper<Favorite>().eq(Favorite::getUserId, userId));
        if (favoriteList != null && !favoriteList.isEmpty()) {
            redisUtil.set(key, favoriteList, 10, TimeUnit.MINUTES);
        }
        return favoriteList;
    }

    @Override
    public void addFavorite(Long userId, Long productId) {
        if (!isFavorite(userId, productId)) {
            Favorite favorite = new Favorite();
            favorite.setUserId(userId);
            favorite.setProductId(productId);
            favoriteMapper.insert(favorite);
            String key = "favorite:list:" + userId;
            redisUtil.delete(key);
        }
    }

    @Override
    public void removeFavorite(Long favoriteId) {
        Favorite favorite = favoriteMapper.selectById(favoriteId);
        if (favorite != null) {
            favoriteMapper.deleteById(favoriteId);
            String key = "favorite:list:" + favorite.getUserId();
            redisUtil.delete(key);
        }
    }

    @Override
    public boolean isFavorite(Long userId, Long productId) {
        Favorite favorite = favoriteMapper.selectOne(new LambdaQueryWrapper<Favorite>()
                .eq(Favorite::getUserId, userId)
                .eq(Favorite::getProductId, productId));
        return favorite != null;
    }
}
