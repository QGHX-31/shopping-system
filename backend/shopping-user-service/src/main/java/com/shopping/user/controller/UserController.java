package com.shopping.user.controller;

import com.shopping.common.entity.User;
import com.shopping.common.utils.JwtUtil;
import com.shopping.common.utils.Result;
import com.shopping.user.service.UserService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class UserController {
    @Resource
    private UserService userService;
    @Resource
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        User user = userService.login(username, password);
        if (user != null) {
            String token = jwtUtil.generateToken(user.getId(), user.getUsername());
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            return Result.success(data);
        }
        return Result.error("Login failed");
    }

    @PostMapping("/register")
    public Result<User> register(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        String email = params.get("email");
        String phone = params.get("phone");
        User user = userService.register(username, password, email, phone);
        if (user != null) {
            return Result.success(user);
        }
        return Result.error("Register failed");
    }

    @GetMapping("/info")
    public Result<User> getUserInfo(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            Long userId = jwtUtil.getUserIdFromToken(token);
            User user = userService.getUserInfo(userId);
            if (user != null) {
                return Result.success(user);
            }
        }
        return Result.error("Unauthorized");
    }

    @PutMapping("/profile")
    public Result<User> updateProfile(HttpServletRequest request,
                                       @RequestBody Map<String, String> params) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            Long userId = jwtUtil.getUserIdFromToken(token);
            String nickname = params.get("nickname");
            String email = params.get("email");
            String phone = params.get("phone");
            User user = userService.updateProfile(userId, nickname, email, phone);
            if (user != null) {
                return Result.success(user);
            }
        }
        return Result.error("更新失败");
    }

    @PostMapping("/logout")
    public Result<Void> logout() {
        return Result.success();
    }

    @GetMapping("/count")
    public Result<Long> getUserCount() {
        return Result.success(userService.getUserCount());
    }

    @GetMapping("/list")
    public Result<Map<String, Object>> listUsers(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        Map<String, Object> result = userService.listUsers(keyword, page, size);
        return Result.success(result);
    }

    @PutMapping("/{id}/status")
    public Result<Boolean> updateUserStatus(
            @PathVariable Long id,
            @RequestParam Integer status) {
        boolean success = userService.updateUserStatus(id, status);
        if (!success) {
            return Result.error("更新失败");
        }
        return Result.success(true);
    }

    @PutMapping("/{id}/reset-password")
    public Result<Boolean> resetUserPassword(
            @PathVariable Long id,
            @RequestParam(defaultValue = "123456") String newPassword) {
        boolean success = userService.resetUserPassword(id, newPassword);
        if (!success) {
            return Result.error("重置失败");
        }
        return Result.success(true);
    }
}
