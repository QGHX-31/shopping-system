package com.shopping.user.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.common.entity.Favorite;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface FavoriteMapper extends BaseMapper<Favorite> {
}
