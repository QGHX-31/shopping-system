package com.shopping.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.common.entity.Member;
import com.shopping.common.entity.User;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.utils.RedisUtil;
import com.shopping.user.mapper.MemberMapper;
import com.shopping.user.mapper.UserMapper;
import com.shopping.user.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
    @Resource
    private UserMapper userMapper;
    @Resource
    private MemberMapper memberMapper;
    @Resource
    private RedisUtil redisUtil;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public User login(String username, String password) {
        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getUsername, username)
                .eq(User::getStatus, 1));
        if (user == null) {
            log.warn("登录失败，用户不存在或已禁用: username={}", username);
            return null;
        }
        boolean matches = passwordEncoder.matches(password, user.getPassword());
        if (!matches) {
            log.warn("登录失败，密码错误: username={}, 输入密码={}, 数据库哈希={}", username, password, user.getPassword());
            return null;
        }
        String key = "user:info:" + user.getId();
        redisUtil.set(key, user, 30, TimeUnit.MINUTES);
        ensureMemberExists(user.getId());
        log.info("登录成功: username={}, userId={}", username, user.getId());
        return user;
    }

    private void ensureMemberExists(Long userId) {
        try {
            Long count = memberMapper.selectCount(
                    new LambdaQueryWrapper<Member>().eq(Member::getUserId, userId));
            if (count == null || count == 0) {
                Member member = new Member();
                member.setUserId(userId);
                member.setMemberLevel(1);
                member.setTotalPoints(0);
                member.setAvailablePoints(0);
                member.setMemberSince(LocalDateTime.now());
                memberMapper.insert(member);
                log.info("自动补建会员记录: userId={}", userId);
            }
        } catch (Exception e) {
            log.warn("检查会员记录失败: userId={}", userId, e);
        }
    }

    @Override
    @Transactional
    public User register(String username, String password, String email, String phone) {
        if (userMapper.selectOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username)) != null) {
            throw new BusinessException("用户名已存在");
        }
        if (email != null && !email.isEmpty()) {
            Long count = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getEmail, email));
            if (count != null && count > 0) {
                throw new BusinessException("邮箱已被注册");
            }
        }
        if (phone != null && !phone.isEmpty()) {
            Long count = userMapper.selectCount(new LambdaQueryWrapper<User>().eq(User::getPhone, phone));
            if (count != null && count > 0) {
                throw new BusinessException("手机号已被注册");
            }
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setEmail(email != null && !email.isEmpty() ? email : null);
        user.setPhone(phone != null && !phone.isEmpty() ? phone : null);
        user.setNickname(username);
        user.setStatus(1);
        userMapper.insert(user);

        Member member = new Member();
        member.setUserId(user.getId());
        member.setMemberLevel(1);
        member.setTotalPoints(0);
        member.setAvailablePoints(0);
        member.setMemberSince(LocalDateTime.now());
        memberMapper.insert(member);

        return user;
    }

    @Override
    public User getUserInfo(Long userId) {
        String key = "user:info:" + userId;
        User user = redisUtil.get(key, User.class);
        if (user != null) {
            return user;
        }
        user = userMapper.selectById(userId);
        if (user != null) {
            redisUtil.set(key, user, 30, TimeUnit.MINUTES);
        }
        return user;
    }

    @Override
    @Transactional
    public User updateProfile(Long userId, String nickname, String email, String phone) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }
        if (nickname != null && !nickname.trim().isEmpty()) {
            if (nickname.trim().length() > 20) {
                throw new BusinessException("昵称不能超过20个字符");
            }
            user.setNickname(nickname.trim());
        }
        if (email != null) {
            String trimmedEmail = email.trim();
            if (!trimmedEmail.isEmpty()) {
                String emailReg = "^[\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+$";
                if (!trimmedEmail.matches(emailReg)) {
                    throw new BusinessException("邮箱格式不正确");
                }
            }
            user.setEmail(trimmedEmail.isEmpty() ? null : trimmedEmail);
        }
        if (phone != null) {
            String trimmedPhone = phone.trim();
            if (!trimmedPhone.isEmpty()) {
                String phoneReg = "^1[3-9]\\d{9}$";
                if (!trimmedPhone.matches(phoneReg)) {
                    throw new BusinessException("手机号格式不正确，请输入11位有效手机号");
                }
            }
            user.setPhone(trimmedPhone.isEmpty() ? null : trimmedPhone);
        }
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.updateById(user);
        String key = "user:info:" + userId;
        redisUtil.delete(key);
        return user;
    }

    @Override
    public Long getUserCount() {
        return userMapper.selectCount(new LambdaQueryWrapper<>());
    }

    @Override
    public Map<String, Object> listUsers(String keyword, Integer page, Integer size) {
        page = page == null || page < 1 ? 1 : page;
        size = size == null || size < 1 ? 10 : size;

        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(User::getCreatedAt);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> {
                w.like(User::getUsername, keyword);
                w.or().like(User::getNickname, keyword);
                w.or().like(User::getPhone, keyword);
            });
        }

        Page<User> userPage = new Page<>(page, size);
        Page<User> resultPage = userMapper.selectPage(userPage, wrapper);

        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", resultPage.getCurrent());
        result.put("size", resultPage.getSize());
        return result;
    }

    @Override
    public boolean updateUserStatus(Long id, Integer status) {
        User user = new User();
        user.setId(id);
        user.setStatus(status);
        return userMapper.updateById(user) > 0;
    }

    @Override
    public boolean resetUserPassword(Long id, String newPassword) {
        User user = userMapper.selectById(id);
        if (user == null) {
            log.warn("重置密码失败，用户不存在: id={}", id);
            return false;
        }
        String encoded = passwordEncoder.encode(newPassword);
        log.info("重置密码: id={}, username={}, 新密码={}, 哈希={}", id, user.getUsername(), newPassword, encoded);
        user.setPassword(encoded);
        int rows = userMapper.updateById(user);
        log.info("重置密码结果: id={}, 更新行数={}", id, rows);
        boolean matches = passwordEncoder.matches(newPassword, encoded);
        log.info("密码哈希验证: matches={}", matches);
        return rows > 0;
    }
}
