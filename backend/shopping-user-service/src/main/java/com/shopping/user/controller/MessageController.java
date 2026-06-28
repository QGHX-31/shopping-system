package com.shopping.user.controller;

import com.shopping.common.entity.Message;
import com.shopping.common.utils.JwtUtil;
import com.shopping.common.utils.Result;
import com.shopping.user.service.MessageService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

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

    @PostMapping("/send")
    public Result<Void> sendMessage(HttpServletRequest request, @RequestBody Message message) {
        Long userId = getUserId(request);
        messageService.sendMessage(userId, message.getTitle(), message.getContent(), message.getType());
        return Result.success();
    }

    @PostMapping("/read/{id}")
    public Result<Void> markAsRead(@PathVariable Long id) {
        messageService.markAsRead(id);
        return Result.success();
    }

    private Long getUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization").substring(7);
        return jwtUtil.getUserIdFromToken(token);
    }
}
