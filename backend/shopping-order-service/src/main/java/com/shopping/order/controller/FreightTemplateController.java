package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.entity.FreightTemplate;
import com.shopping.order.service.FreightTemplateService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/order/freight")
public class FreightTemplateController {

    @Autowired
    private FreightTemplateService freightTemplateService;

    @GetMapping("/detail")
    public Result<FreightTemplate> detail(@RequestParam Long merchantId) {
        try {
            FreightTemplate template = freightTemplateService.getByMerchantId(merchantId);
            return Result.success(template);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/save")
    public Result<Void> save(@RequestBody FreightTemplate template) {
        try {
            freightTemplateService.saveOrUpdate(template);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/calculate")
    public Result<BigDecimal> calculate(@RequestBody Map<String, Object> body) {
        try {
            Long merchantId = Long.valueOf(String.valueOf(body.get("merchantId")));
            BigDecimal orderAmount = new BigDecimal(String.valueOf(body.get("orderAmount")));
            String province = (String) body.get("province");
            BigDecimal freight = freightTemplateService.calculateFreight(merchantId, orderAmount, province);
            return Result.success(freight);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
