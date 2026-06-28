package com.shopping.order.service;

import com.shopping.order.entity.OrderLogisticsTrack;

import java.util.List;

public interface OrderLogisticsTrackService {

    List<OrderLogisticsTrack> getByOrderId(Long orderId);

    void addLogisticsTrack(Long orderId, String expressCompany, String trackingNo, String status, String location, String description);
}
