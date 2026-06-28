package com.shopping.order.admin.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.entity.Admin;
import com.shopping.order.admin.entity.Permission;
import com.shopping.order.admin.mapper.AdminMapper;
import com.shopping.order.admin.mapper.AdminRoleMapper;
import com.shopping.order.admin.mapper.PermissionMapper;
import com.shopping.order.admin.mapper.RolePermissionMapper;
import com.shopping.order.admin.service.AdminService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class AdminServiceImpl implements AdminService {

    @Autowired private AdminMapper adminMapper;
    @Autowired private PermissionMapper permissionMapper;
    @Autowired private AdminRoleMapper adminRoleMapper;
    @Autowired private RolePermissionMapper rolePermissionMapper;

    @Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @Override
    public Map<String, Object> login(String username, String password) {
        Admin admin = adminMapper.selectOne(
                new LambdaQueryWrapper<Admin>().eq(Admin::getUsername, username));
        if (admin == null) throw new BusinessException("管理员账号不存在");
        if (admin.getStatus() != 1) throw new BusinessException("账号已被禁用");
        if (!passwordEncoder.matches(password, admin.getPassword())) {
            throw new BusinessException("密码错误");
        }

        // 更新最后登录时间
        admin.setLastLoginTime(LocalDateTime.now());
        adminMapper.updateById(admin);

        // 生成 token（简化：UUID）
        String token = UUID.randomUUID().toString().replace("-", "");

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("admin", admin);
        return data;
    }

    @Override
    public List<String> getPermissionCodes(Long adminId) {
        List<Long> roleIds = adminRoleMapper.selectRoleIdsByAdminId(adminId);
        if (roleIds.isEmpty()) return Collections.emptyList();
        List<Long> permissionIds = new ArrayList<>();
        for (Long roleId : roleIds) {
            // 简化：直接通过 role 表关联，这里跳过中间表
        }
        // 简化：admin 1（超级管理员）拥有所有权限
        Admin admin = adminMapper.selectById(adminId);
        if (admin != null && "admin".equals(admin.getUsername())) {
            return permissionMapper.selectList(null).stream()
                    .map(Permission::getCode).collect(Collectors.toList());
        }
        return Collections.emptyList();
    }

    @Override
    public List<Permission> getMenuTree(Long adminId) {
        List<Permission> all = permissionMapper.selectList(
                new LambdaQueryWrapper<Permission>().orderByAsc(Permission::getSortOrder));
        // 简化：返回所有菜单（实际项目应按角色过滤）
        return all;
    }
}
