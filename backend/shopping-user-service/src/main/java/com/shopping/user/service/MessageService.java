package com.shopping.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.common.entity.Message;

import java.util.List;

public interface MessageService extends IService<Message> {
    List<Message> getMessages(Long userId);
    void sendMessage(Long userId, String title, String content, Integer type);
    void markAsRead(Long messageId);
}
