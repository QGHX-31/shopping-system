package com.shopping.order.admin.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.admin.entity.Permission;
import com.shopping.order.admin.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired private AdminService adminService;

    /**
     * 管理员登录
     * POST /admin/login
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> params) {
        try {
            return Result.success(adminService.login(params.get("username"), params.get("password")));
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取菜单树
     */
    @GetMapping("/menus")
    public Result<List<Permission>> menus(@RequestParam Long adminId) {
        return Result.success(adminService.getMenuTree(adminId));
    }

    /**
     * 获取权限码
     */
    @GetMapping("/permissions")
    public Result<List<String>> permissions(@RequestParam Long adminId) {
        return Result.success(adminService.getPermissionCodes(adminId));
    }
}
