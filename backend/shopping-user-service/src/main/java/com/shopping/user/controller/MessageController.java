package com.shopping.user.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.Message;
import com.shopping.common.utils.JwtUtil;
import com.shopping.common.utils.Result;
import com.shopping.user.service.MessageService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/message")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class MessageController {
    @Resource
    private MessageService messageService;
    @Resource
    private JwtUtil jwtUtil;

    @GetMapping("/list")
    public Result<List<Message>> getMessages(HttpServletRequest request) {
        Long userId = getUserId(request);
        List<Message> messages = messageService.getMessages(userId);
        return Result.success(messages);
    }

    @GetMapping("/user/list")
    public Result<Map<String, Object>> userList(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "100") Integer size) {
        Page<Message> p = new Page<>(page, size);
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<Message>()
                .eq(Message::getUserId, userId)
                .orderByDesc(Message::getCreatedAt);
        Page<Message> result = messageService.page(p, wrapper);
        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("list", result.getRecords());
        return Result.success(data);
    }

    @PostMapping("/send")
    public Result<Void> sendMessage(HttpServletRequest request, @RequestBody Message message) {
        Long userId = getUserId(request);
        messageService.sendMessage(userId, message.getTitle(), message.getContent(), message.getType());
        return Result.success();
    }

    @PostMapping("/add")
    public Result<Void> addMessage(
            @RequestParam Long userId,
            @RequestParam String title,
            @RequestParam String content,
            @RequestParam(defaultValue = "1") Integer type) {
        messageService.sendMessage(userId, title, content, type);
        return Result.success();
    }

    @PostMapping("/read/{id}")
    public Result<Void> markAsRead(@PathVariable Long id) {
        messageService.markAsRead(id);
        return Result.success();
    }

    @PostMapping("/read")
    public Result<Void> markAsReadByParam(@RequestParam Long id, @RequestParam(required = false) Long userId) {
        messageService.markAsRead(id);
        return Result.success();
    }

    @PostMapping("/readAll")
    public Result<Void> markAllAsRead(@RequestParam Long userId) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<Message>()
                .eq(Message::getUserId, userId)
                .eq(Message::getIsRead, 0);
        List<Message> messages = messageService.list(wrapper);
        for (Message msg : messages) {
            msg.setIsRead(1);
        }
        if (!messages.isEmpty()) {
            messageService.updateBatchById(messages);
        }
        return Result.success();
    }

    @GetMapping("/unreadCount")
    public Result<Integer> getUnreadCount(@RequestParam Long userId,
                                          @RequestParam(required = false) Integer type) {
        LambdaQueryWrapper<Message> wrapper = new LambdaQueryWrapper<Message>()
                .eq(Message::getUserId, userId)
                .eq(Message::getIsRead, 0);
        if (type != null) {
            wrapper.eq(Message::getType, type);
        }
        long count = messageService.count(wrapper);
        return Result.success((int) count);
    }

    private Long getUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization");
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        return jwtUtil.getUserIdFromToken(token);
    }
}
