package com.shopping.user.controller;

import com.shopping.common.entity.Cart;
import com.shopping.common.utils.JwtUtil;
import com.shopping.common.utils.Result;
import com.shopping.user.service.CartService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/cart")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class CartController {
    @Resource
    private CartService cartService;
    @Resource
    private JwtUtil jwtUtil;

    @GetMapping("/list")
    public Result<List<Cart>> getCartList(HttpServletRequest request) {
        Long userId = getUserId(request);
        List<Cart> cartList = cartService.getCartList(userId);
        return Result.success(cartList);
    }

    @PostMapping("/add")
    public Result<Void> addToCart(HttpServletRequest request, @RequestBody Cart cart) {
        Long userId = getUserId(request);
        cartService.addToCart(userId, cart.getProductId(), cart.getSkuId(), cart.getQuantity());
        return Result.success();
    }

    @PutMapping("/update/{id}")
    public Result<Void> updateCart(@PathVariable Long id, @RequestBody Cart cart) {
        cartService.updateCart(id, cart.getQuantity());
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result<Void> deleteCart(@PathVariable Long id) {
        cartService.deleteCart(id);
        return Result.success();
    }

    @PostMapping("/batch-delete")
    public Result<Void> batchDelete(@RequestBody Map<String, Object> body) {
        List<Long> cartIds = (List<Long>) body.get("cartIds");
        cartService.batchDelete(cartIds);
        return Result.success();
    }

    @PostMapping("/select/{id}")
    public Result<Void> toggleSelect(@PathVariable Long id, @RequestBody Cart cart) {
        cartService.toggleSelect(id, cart.getSelected());
        return Result.success();
    }

    @PostMapping("/select/all")
    public Result<Void> toggleSelectAll(HttpServletRequest request, @RequestBody Cart cart) {
        Long userId = getUserId(request);
        cartService.toggleSelectAll(userId, cart.getSelected());
        return Result.success();
    }

    private Long getUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization").substring(7);
        return jwtUtil.getUserIdFromToken(token);
    }
}
