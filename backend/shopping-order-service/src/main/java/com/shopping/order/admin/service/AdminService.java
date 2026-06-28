package com.shopping.order.admin.service;

import com.shopping.common.entity.Admin;
import com.shopping.order.admin.entity.Permission;

import java.util.List;
import java.util.Map;

public interface AdminService {
    /**
     * 管理员登录
     */
    Map<String, Object> login(String username, String password);

    /**
     * 获取当前管理员的权限码列表
     */
    List<String> getPermissionCodes(Long adminId);

    /**
     * 获取菜单树
     */
    List<Permission> getMenuTree(Long adminId);
}
