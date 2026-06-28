package com.shopping.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.common.entity.User;

public interface UserService extends IService<User> {
    User login(String username, String password);
    User register(String username, String password, String email, String phone);
    User getUserInfo(Long userId);
    User updateProfile(Long userId, String nickname, String email, String phone);
    Long getUserCount();
    java.util.Map<String, Object> listUsers(String keyword, Integer page, Integer size);
    boolean updateUserStatus(Long id, Integer status);
    boolean resetUserPassword(Long id, String newPassword);
}
