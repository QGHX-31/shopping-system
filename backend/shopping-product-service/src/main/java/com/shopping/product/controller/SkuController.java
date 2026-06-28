package com.shopping.product.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.ProductSku;
import com.shopping.common.utils.Result;
import com.shopping.product.mapper.SkuMapper;
import com.shopping.product.service.SkuService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/sku")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class SkuController {

    @Resource
    private SkuService skuService;

    @Resource
    private SkuMapper skuMapper;

    @GetMapping("/list")
    public Result<List<ProductSku>> listSkus(@RequestParam Long productId) {
        List<ProductSku> skus = skuService.listSkusByProductId(productId);
        return Result.success(skus);
    }

    @GetMapping("/list/all")
    public Result<Map<String, Object>> listAllSkus(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size) {
        Page<ProductSku> pageObj = new Page<>(page, size);
        Page<ProductSku> result = skuMapper.selectPage(pageObj, new LambdaQueryWrapper<>());
        Map<String, Object> data = new HashMap<>();
        data.put("list", result.getRecords());
        data.put("total", result.getTotal());
        data.put("page", page);
        data.put("size", size);
        return Result.success(data);
    }

    @PutMapping("/{id}/stock")
    public Result<Boolean> adjustStock(
            @PathVariable Long id,
            @RequestParam Integer count) {
        boolean success = skuService.adjustStock(id, count);
        return Result.success(success);
    }

    @PostMapping("/add")
    public Result<Long> addSku(@RequestBody ProductSku sku) {
        skuMapper.insert(sku);
        return Result.success(sku.getId());
    }

    @PutMapping("/{id}")
    public Result<Boolean> updateSku(@PathVariable Long id, @RequestBody ProductSku sku) {
        sku.setId(id);
        skuMapper.updateById(sku);
        return Result.success(true);
    }

    @DeleteMapping("/{id}")
    public Result<Boolean> deleteSku(@PathVariable Long id) {
        skuMapper.deleteById(id);
        return Result.success(true);
    }
}
