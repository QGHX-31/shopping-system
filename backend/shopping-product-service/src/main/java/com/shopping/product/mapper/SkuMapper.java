package com.shopping.product.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.common.entity.ProductSku;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SkuMapper extends BaseMapper<ProductSku> {
}
