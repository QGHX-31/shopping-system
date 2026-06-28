package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.exception.BusinessException;
import com.shopping.order.entity.Order;
import com.shopping.order.entity.OrderLogisticsTrack;
import com.shopping.order.mapper.OrderLogisticsTrackMapper;
import com.shopping.order.mapper.OrderMapper;
import com.shopping.order.service.OrderLogisticsTrackService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class OrderLogisticsTrackServiceImpl implements OrderLogisticsTrackService {

    @Autowired
    private OrderLogisticsTrackMapper orderLogisticsTrackMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Override
    public List<OrderLogisticsTrack> getByOrderId(Long orderId) {
        if (orderId == null) {
            throw new BusinessException("订单ID不能为空");
        }
        LambdaQueryWrapper<OrderLogisticsTrack> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OrderLogisticsTrack::getOrderId, orderId)
                .orderByDesc(OrderLogisticsTrack::getTrackTime);
        return orderLogisticsTrackMapper.selectList(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addLogisticsTrack(Long orderId, String expressCompany, String trackingNo, String status, String location, String description) {
        if (orderId == null) {
            throw new BusinessException("订单ID不能为空");
        }
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }

        OrderLogisticsTrack track = new OrderLogisticsTrack();
        track.setOrderId(orderId);
        track.setExpressCompany(expressCompany);
        track.setTrackingNo(trackingNo);
        track.setStatus(status != null ? Integer.parseInt(status) : null);
        track.setLocation(location);
        track.setDescription(description);
        track.setTrackTime(LocalDateTime.now());
        track.setCreatedAt(LocalDateTime.now());
        orderLogisticsTrackMapper.insert(track);

        log.info("添加物流轨迹成功: orderId={}, expressCompany={}, trackingNo={}", orderId, expressCompany, trackingNo);
    }
}
