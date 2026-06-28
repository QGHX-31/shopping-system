package com.shopping.common.mq;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.common.entity.MqMessageLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MqMessageLogMapper extends BaseMapper<MqMessageLog> {
}
