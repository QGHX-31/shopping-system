package com.shopping.product.controller;

import com.shopping.common.entity.Product;
import com.shopping.common.utils.Result;
import com.shopping.product.service.ProductService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Map;

@RestController
@RequestMapping("/product")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class ProductController {

    @Resource
    private ProductService productService;

    @GetMapping("/list")
    public Result<Map<String, Object>> listProducts(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false, defaultValue = "default") String sortBy,
            @RequestParam(required = false) Double priceMin,
            @RequestParam(required = false) Double priceMax,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "12") Integer size) {
        Map<String, Object> result = productService.listProducts(categoryId, keyword, sortBy, priceMin, priceMax, page, size);
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<Product> getProduct(@PathVariable Long id) {
        Product product = productService.getProductById(id);
        if (product == null) {
            return Result.error("Product not found");
        }
        return Result.success(product);
    }

    @PostMapping("/create")
    public Result<Product> createProduct(@RequestBody Product product) {
        Product created = productService.createProduct(product);
        return Result.success(created);
    }

    @PutMapping("/update")
    public Result<Product> updateProduct(@RequestBody Product product) {
        Product updated = productService.updateProduct(product);
        return Result.success(updated);
    }

    @PutMapping("/{id}/status")
    public Result<Boolean> updateProductStatus(
            @PathVariable Long id,
            @RequestParam Integer status) {
        boolean success = productService.updateProductStatus(id, status);
        return Result.success(success);
    }

    @GetMapping("/hot")
    public Result<java.util.List<Product>> getHotProducts() {
        return Result.success(productService.getHotProducts());
    }

    @GetMapping("/new")
    public Result<java.util.List<Product>> getNewProducts() {
        return Result.success(productService.getNewProducts());
    }

    // ====== 给订单服务用的内部接口 ======

    /** 订单服务用：根据 ID 查询商品（与 GET /{id} 等价，路径不同） */
    @GetMapping("/detail/{id}")
    public Result<Product> getProductDetail(@PathVariable Long id) {
        Product product = productService.getProductById(id);
        if (product == null) {
            return Result.error("Product not found");
        }
        return Result.success(product);
    }

    /** 订单服务用：扣减库存（库存不足会抛 BusinessException） */
    @PostMapping("/deductStock")
    public Result<Product> deductStock(@RequestParam Long productId,
                                       @RequestParam Integer quantity) {
        return Result.success(productService.deductStock(productId, quantity));
    }

    /** 订单服务用：恢复库存（取消订单时） */
    @PostMapping("/addStock")
    public Result<Product> addStock(@RequestParam Long productId,
                                     @RequestParam Integer quantity) {
        return Result.success(productService.addStock(productId, quantity));
    }

    /** 订单服务用：增加销量（支付成功回调时） */
    @PostMapping("/addSales")
    public Result<Product> addSales(@RequestParam Long productId,
                                    @RequestParam Integer quantity) {
        return Result.success(productService.addSales(productId, quantity));
    }

    @GetMapping("/count")
    public Result<Long> getProductCount() {
        return Result.success(productService.getProductCount());
    }

    @GetMapping("/merchant/list")
    public Result<Map<String, Object>> listMerchantProducts(
            @RequestParam Long merchantId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "100") Integer size) {
        Map<String, Object> result = productService.listMerchantProducts(merchantId, page, size);
        return Result.success(result);
    }
}
