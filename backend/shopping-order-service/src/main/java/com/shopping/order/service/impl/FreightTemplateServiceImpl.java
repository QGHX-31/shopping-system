package com.shopping.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.exception.BusinessException;
import com.shopping.order.entity.FreightTemplate;
import com.shopping.order.mapper.FreightTemplateMapper;
import com.shopping.order.service.FreightTemplateService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Slf4j
@Service
public class FreightTemplateServiceImpl implements FreightTemplateService {

    @Autowired
    private FreightTemplateMapper freightTemplateMapper;

    @Override
    public FreightTemplate getByMerchantId(Long merchantId) {
        if (merchantId == null) {
            throw new BusinessException("商家ID不能为空");
        }
        LambdaQueryWrapper<FreightTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(FreightTemplate::getMerchantId, merchantId)
                .eq(FreightTemplate::getStatus, 1);
        return freightTemplateMapper.selectOne(wrapper);
    }

    @Override
    public BigDecimal calculateFreight(Long merchantId, BigDecimal orderAmount, String province) {
        if (merchantId == null || orderAmount == null) {
            throw new BusinessException("参数不完整");
        }

        FreightTemplate template = getByMerchantId(merchantId);
        if (template == null) {
            BigDecimal defaultFreight = orderAmount.compareTo(new BigDecimal("99")) >= 0
                    ? BigDecimal.ZERO : new BigDecimal("10.00");
            log.info("商家未设置运费模板，使用默认运费: merchantId={}, orderAmount={}, freight={}", merchantId, orderAmount, defaultFreight);
            return defaultFreight;
        }

        BigDecimal freeAmount = template.getFreeAmount() != null ? template.getFreeAmount() : BigDecimal.ZERO;
        BigDecimal baseFreight = template.getFirstFee() != null ? template.getFirstFee() : new BigDecimal("10.00");

        if (freeAmount.compareTo(BigDecimal.ZERO) > 0 && orderAmount.compareTo(freeAmount) >= 0) {
            log.info("订单金额达到包邮条件，免运费: merchantId={}, orderAmount={}, freeAmount={}", merchantId, orderAmount, freeAmount);
            return BigDecimal.ZERO;
        }

        log.info("计算运费: merchantId={}, orderAmount={}, freight={}", merchantId, orderAmount, baseFreight);
        return baseFreight;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void saveOrUpdate(FreightTemplate template) {
        if (template == null || template.getMerchantId() == null) {
            throw new BusinessException("参数不完整");
        }

        FreightTemplate existing = getByMerchantId(template.getMerchantId());
        if (existing != null) {
            template.setId(existing.getId());
            template.setUpdatedAt(LocalDateTime.now());
            freightTemplateMapper.updateById(template);
            log.info("更新运费模板成功: merchantId={}", template.getMerchantId());
        } else {
            template.setStatus(1);
            template.setCreatedAt(LocalDateTime.now());
            template.setUpdatedAt(LocalDateTime.now());
            freightTemplateMapper.insert(template);
            log.info("新增运费模板成功: merchantId={}", template.getMerchantId());
        }
    }
}
