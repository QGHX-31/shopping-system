package com.shopping.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.common.entity.Message;
import com.shopping.user.mapper.MessageMapper;
import com.shopping.user.service.MessageService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class MessageServiceImpl extends ServiceImpl<MessageMapper, Message> implements MessageService {
    @Resource
    private MessageMapper messageMapper;

    @Override
    public List<Message> getMessages(Long userId) {
        return messageMapper.selectList(new LambdaQueryWrapper<Message>()
                .eq(Message::getUserId, userId)
                .orderByDesc(Message::getCreatedAt));
    }

    @Override
    public void sendMessage(Long userId, String title, String content, Integer type) {
        Message message = new Message();
        message.setUserId(userId);
        message.setTitle(title);
        message.setContent(content);
        message.setType(type);
        message.setIsRead(0);
        message.setCreatedAt(LocalDateTime.now());
        messageMapper.insert(message);
    }

    @Override
    public void markAsRead(Long messageId) {
        Message message = messageMapper.selectById(messageId);
        if (message != null) {
            message.setIsRead(1);
            messageMapper.updateById(message);
        }
    }
}
