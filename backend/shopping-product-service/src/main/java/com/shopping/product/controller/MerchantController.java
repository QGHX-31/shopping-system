package com.shopping.product.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.Merchant;
import com.shopping.common.entity.MerchantStats;
import com.shopping.common.entity.Product;
import com.shopping.common.utils.Result;
import com.shopping.product.service.MerchantService;
import com.shopping.product.service.ProductService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/merchant")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class MerchantController {

    @Resource
    private MerchantService merchantService;

    @Resource
    private ProductService productService;

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        Merchant merchant = merchantService.login(username, password);
        if (merchant == null) {
            return Result.error("Invalid username or password");
        }
        String token = UUID.randomUUID().toString().replace("-", "");
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("merchant", merchant);
        return Result.success(data);
    }

    @PostMapping("/register")
    public Result<Map<String, Object>> register(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        String shopName = params.get("shopName");
        String contactName = params.get("contactName");
        String contactPhone = params.get("contactPhone");
        String email = params.get("email");
        if (username == null || password == null || shopName == null) {
            return Result.error("账号、密码、店铺名称不能为空");
        }
        try {
            Merchant merchant = merchantService.register(username, password, shopName, contactName, contactPhone, email);
            String token = UUID.randomUUID().toString().replace("-", "");
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("merchant", merchant);
            return Result.success(data);
        } catch (RuntimeException e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/logout")
    public Result<Boolean> logout() {
        return Result.success(true);
    }

    @GetMapping("/list")
    public Result<Map<String, Object>> getMerchantList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status) {
        Map<String, Object> result = merchantService.getMerchantList(page, size, keyword, status);
        return Result.success(result);
    }

    @PutMapping("/{id}/status")
    public Result<Boolean> updateMerchantStatus(
            @PathVariable Long id,
            @RequestParam Integer status) {
        boolean success = merchantService.updateMerchantStatus(id, status);
        if (!success) {
            return Result.error("更新失败");
        }
        return Result.success(true);
    }

    @GetMapping("/{id}")
    public Result<Merchant> getMerchantDetail(@PathVariable Long id) {
        Merchant merchant = merchantService.getMerchantById(id);
        return Result.success(merchant);
    }

    @GetMapping("/stats/{merchantId}")
    public Result<MerchantStats> getMerchantStats(@PathVariable Long merchantId) {
        MerchantStats stats = merchantService.getMerchantStats(merchantId);
        return Result.success(stats);
    }

    @GetMapping("/product/list")
    public Result<Map<String, Object>> listMerchantProducts(
            @RequestParam Long merchantId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> result = merchantService.listMerchantProducts(merchantId, keyword, page, size);
        return Result.success(result);
    }

    @PutMapping("/product/{id}/status")
    public Result<Boolean> toggleProductStatus(
            @PathVariable Long id,
            @RequestBody(required = false) Map<String, Integer> body,
            @RequestParam(required = false) Integer status) {
        if (body != null && body.get("status") != null) {
            status = body.get("status");
        }
        if (status == null) {
            return Result.error("状态不能为空");
        }
        boolean success = merchantService.toggleProductStatus(id, status);
        return Result.success(success);
    }

    @PostMapping("/product/add")
    public Result<Product> addProduct(@RequestBody Product product) {
        if (product.getMerchantId() == null) {
            return Result.error("商家ID不能为空");
        }
        if (product.getName() == null || product.getName().isEmpty()) {
            return Result.error("商品名称不能为空");
        }
        if (product.getStatus() == null) {
            product.setStatus(1);
        }
        if (product.getImageUrl() == null) {
            product.setImageUrl("");
        }
        Product created = productService.createProduct(product);
        return Result.success(created);
    }

    @PutMapping("/product/{id}")
    public Result<Product> updateProduct(@PathVariable Long id, @RequestBody Product product) {
        product.setId(id);
        Product updated = productService.updateProduct(product);
        if (updated == null) {
            return Result.error("商品不存在");
        }
        return Result.success(updated);
    }

    @DeleteMapping("/product/{id}")
    public Result<Boolean> deleteProduct(@PathVariable Long id) {
        boolean success = merchantService.deleteProduct(id);
        return Result.success(success);
    }
}
