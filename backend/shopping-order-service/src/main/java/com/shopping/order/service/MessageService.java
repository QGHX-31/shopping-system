package com.shopping.order.service;

import java.util.Map;

public interface MessageService {

    void sendOrderMessage(Long userId, String title, String content, Integer type);

    void sendRefundMessage(Long userId, String title, String content);

    void sendExchangeMessage(Long userId, String title, String content);

    Map<String, Object> listUserMessages(Long userId, Integer type, Integer page, Integer size);

    void markAsRead(Long id, Long userId);

    void markAllAsRead(Long userId);

    Integer getUnreadCount(Long userId);
}
