package com.shopping.product.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.ProductSku;
import com.shopping.common.utils.Result;
import com.shopping.product.mapper.SkuMapper;
import com.shopping.product.service.ProductService;
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

    @Resource
    private ProductService productService;

    @GetMapping("/list")
    public Result<List<ProductSku>> listSkus(@RequestParam Long productId) {
        List<ProductSku> skus = skuService.listSkusByProductId(productId);
        return Result.success(skus);
    }

    @GetMapping("/list/all")
    public Result<Map<String, Object>> listAllSkus(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) Long merchantId,
            @RequestParam(required = false) Long productId) {
        Page<ProductSku> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<ProductSku> wrapper = new LambdaQueryWrapper<>();
        if (merchantId != null) {
            wrapper.eq(ProductSku::getMerchantId, merchantId);
        }
        if (productId != null) {
            wrapper.eq(ProductSku::getProductId, productId);
        }
        wrapper.orderByDesc(ProductSku::getId);
        Page<ProductSku> result = skuMapper.selectPage(pageObj, wrapper);
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
        if (success) {
            ProductSku sku = skuMapper.selectById(id);
            if (sku != null) {
                productService.updateProductTotalStock(sku.getProductId());
            }
        }
        return Result.success(success);
    }

    @PostMapping("/add")
    public Result<Long> addSku(@RequestBody ProductSku sku) {
        skuMapper.insert(sku);
        if (sku.getProductId() != null) {
            productService.updateProductTotalStock(sku.getProductId());
        }
        return Result.success(sku.getId());
    }

    @PutMapping("/{id}")
    public Result<Boolean> updateSku(@PathVariable Long id, @RequestBody ProductSku sku) {
        sku.setId(id);
        skuMapper.updateById(sku);
        ProductSku dbSku = skuMapper.selectById(id);
        if (dbSku != null && dbSku.getProductId() != null) {
            productService.updateProductTotalStock(dbSku.getProductId());
        }
        return Result.success(true);
    }

    @DeleteMapping("/{id}")
    public Result<Boolean> deleteSku(@PathVariable Long id) {
        ProductSku sku = skuMapper.selectById(id);
        Long productId = sku != null ? sku.getProductId() : null;
        skuMapper.deleteById(id);
        if (productId != null) {
            productService.updateProductTotalStock(productId);
        }
        return Result.success(true);
    }
}
