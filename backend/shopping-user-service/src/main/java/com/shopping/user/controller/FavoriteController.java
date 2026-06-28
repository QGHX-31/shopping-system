package com.shopping.user.controller;

import com.shopping.common.entity.Favorite;
import com.shopping.common.utils.JwtUtil;
import com.shopping.common.utils.Result;
import com.shopping.user.service.FavoriteService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/favorite")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class FavoriteController {
    @Resource
    private FavoriteService favoriteService;
    @Resource
    private JwtUtil jwtUtil;

    @GetMapping("/list")
    public Result<List<Favorite>> getFavoriteList(HttpServletRequest request) {
        Long userId = getUserId(request);
        List<Favorite> favoriteList = favoriteService.getFavoriteList(userId);
        return Result.success(favoriteList);
    }

    @PostMapping("/add")
    public Result<Void> addFavorite(HttpServletRequest request, @RequestBody Favorite favorite) {
        Long userId = getUserId(request);
        favoriteService.addFavorite(userId, favorite.getProductId());
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result<Void> removeFavorite(@PathVariable Long id) {
        favoriteService.removeFavorite(id);
        return Result.success();
    }

    @GetMapping("/check")
    public Result<Map<String, Boolean>> checkFavorite(HttpServletRequest request, @RequestParam Long productId) {
        Long userId = getUserId(request);
        boolean isFavorite = favoriteService.isFavorite(userId, productId);
        Map<String, Boolean> result = new HashMap<>();
        result.put("isFavorite", isFavorite);
        return Result.success(result);
    }

    private Long getUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization").substring(7);
        return jwtUtil.getUserIdFromToken(token);
    }
}
