package com.shopping.order.service;

import com.shopping.order.entity.FreightTemplate;

import java.math.BigDecimal;

public interface FreightTemplateService {

    FreightTemplate getByMerchantId(Long merchantId);

    BigDecimal calculateFreight(Long merchantId, BigDecimal orderAmount, String province);

    void saveOrUpdate(FreightTemplate template);
}
