package com.shopping.order.service;

import java.util.List;
import java.util.Map;

public interface MerchantDashboardService {

    Map<String, Object> getDashboardData(Long merchantId);

    Map<String, Object> getSalesTrend(Long merchantId, Integer days);

    List<Map<String, Object>> getOrderStatusDistribution(Long merchantId);

    List<Map<String, Object>> getTopProducts(Long merchantId, Integer limit);
}
