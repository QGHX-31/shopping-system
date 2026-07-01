package com.shopping.order.service.impl;

import com.shopping.order.service.MessageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
public class MessageServiceImpl implements MessageService {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${shopping.user-service-url:http://localhost:8081}")
    private String userServiceUrl;

    @Override
    public void sendOrderMessage(Long userId, String title, String content, Integer type) {
        sendMessage(userId, title, content, type != null ? type : 1);
    }

    @Override
    public void sendRefundMessage(Long userId, String title, String content) {
        sendMessage(userId, title, content, 2);
    }

    @Override
    public void sendExchangeMessage(Long userId, String title, String content) {
        sendMessage(userId, title, content, 3);
    }

    private void sendMessage(Long userId, String title, String content, Integer type) {
        if (userId == null) {
            return;
        }
        try {
            String url = userServiceUrl + "/message/add";
            Map<String, Object> params = new HashMap<>();
            params.put("userId", userId);
            params.put("title", title);
            params.put("content", content);
            params.put("type", type);
            ResponseEntity<Map> resp = restTemplate.postForEntity(url, params, Map.class);
            Map body = resp.getBody();
            if (body != null && Integer.valueOf(200).equals(body.get("code"))) {
                log.info("消息发送成功: userId={}, title={}", userId, title);
            } else {
                log.warn("消息发送失败: userId={}, title={}, response={}", userId, title, body);
            }
        } catch (Exception e) {
            log.error("消息发送异常，降级处理: userId={}, title={}", userId, title, e);
        }
    }

    @Override
    public Map<String, Object> listUserMessages(Long userId, Integer type, Integer page, Integer size) {
        try {
            String url = userServiceUrl + "/message/list?userId=" + userId;
            if (type != null) {
                url += "&type=" + type;
            }
            url += "&page=" + (page != null ? page : 1);
            url += "&size=" + (size != null ? size : 10);
            ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
            Map body = resp.getBody();
            if (body != null && Integer.valueOf(200).equals(body.get("code"))) {
                return (Map<String, Object>) body.get("data");
            }
        } catch (Exception e) {
            log.error("查询用户消息列表失败: userId={}", userId, e);
        }
        Map<String, Object> result = new HashMap<>();
        result.put("total", 0);
        result.put("list", new java.util.ArrayList<>());
        return result;
    }

    @Override
    public void markAsRead(Long id, Long userId) {
        try {
            String url = userServiceUrl + "/message/read?id=" + id + "&userId=" + userId;
            restTemplate.postForEntity(url, null, Map.class);
        } catch (Exception e) {
            log.error("标记消息已读失败: id={}, userId={}", id, userId, e);
        }
    }

    @Override
    public void markAllAsRead(Long userId) {
        try {
            String url = userServiceUrl + "/message/readAll?userId=" + userId;
            restTemplate.postForEntity(url, null, Map.class);
        } catch (Exception e) {
            log.error("全部标记已读失败: userId={}", userId, e);
        }
    }

    @Override
    public Integer getUnreadCount(Long userId) {
        try {
            String url = userServiceUrl + "/message/unreadCount?userId=" + userId;
            ResponseEntity<Map> resp = restTemplate.getForEntity(url, Map.class);
            Map body = resp.getBody();
            if (body != null && Integer.valueOf(200).equals(body.get("code"))) {
                Object data = body.get("data");
                if (data != null) {
                    return Integer.valueOf(data.toString());
                }
            }
        } catch (Exception e) {
            log.error("获取未读消息数量失败: userId={}", userId, e);
        }
        return 0;
    }
}
