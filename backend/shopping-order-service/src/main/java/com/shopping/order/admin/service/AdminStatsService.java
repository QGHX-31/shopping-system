package com.shopping.order.admin.service;

import java.util.List;
import java.util.Map;

public interface AdminStatsService {

    Map<String, Object> getOverview();

    Map<String, Object> getSalesTrend(Integer days);

    Map<String, Object> getOrderStatusStats();

    List<Map<String, Object>> getHotProducts(Integer limit);

    Map<String, Object> getRealtimeStats();
}
