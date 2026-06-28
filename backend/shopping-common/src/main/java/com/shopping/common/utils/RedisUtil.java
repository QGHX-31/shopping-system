package com.shopping.common.utils;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

@Component
public class RedisUtil {
    @Resource
    private RedisTemplate<String, Object> redisTemplate;

    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    public <T> T get(String key, Class<T> clazz) {
        Object value = redisTemplate.opsForValue().get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof String) {
            return JSON.parseObject((String) value, clazz);
        }
        return JSON.parseObject(JSON.toJSONString(value), clazz);
    }

    public <T> T get(String key, TypeReference<T> typeReference) {
        Object value = redisTemplate.opsForValue().get(key);
        if (value == null) {
            return null;
        }
        if (value instanceof String) {
            return JSON.parseObject((String) value, typeReference);
        }
        return JSON.parseObject(JSON.toJSONString(value), typeReference);
    }

    public boolean exists(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    public void delete(String key) {
        redisTemplate.delete(key);
    }

    public void delete(Set<String> keys) {
        redisTemplate.delete(keys);
    }

    public void expire(String key, long timeout, TimeUnit unit) {
        redisTemplate.expire(key, timeout, unit);
    }

    public long getExpire(String key) {
        return redisTemplate.getExpire(key, TimeUnit.SECONDS);
    }

    public Long increment(String key) {
        return redisTemplate.opsForValue().increment(key);
    }

    public Long increment(String key, long delta) {
        return redisTemplate.opsForValue().increment(key, delta);
    }

    public Long decrement(String key) {
        return redisTemplate.opsForValue().decrement(key);
    }

    public Long decrement(String key, long delta) {
        return redisTemplate.opsForValue().decrement(key, delta);
    }

    public void hashSet(String key, String hashKey, Object value) {
        redisTemplate.opsForHash().put(key, hashKey, value);
    }

    public Object hashGet(String key, String hashKey) {
        return redisTemplate.opsForHash().get(key, hashKey);
    }

    public void hashDelete(String key, Object... hashKeys) {
        redisTemplate.opsForHash().delete(key, hashKeys);
    }

    public boolean hashExists(String key, String hashKey) {
        return redisTemplate.opsForHash().hasKey(key, hashKey);
    }

    public <T> T hashGet(String key, String hashKey, Class<T> clazz) {
        Object value = redisTemplate.opsForHash().get(key, hashKey);
        if (value == null) {
            return null;
        }
        if (value instanceof String) {
            return JSON.parseObject((String) value, clazz);
        }
        return JSON.parseObject(JSON.toJSONString(value), clazz);
    }

    public void listPush(String key, Object value) {
        redisTemplate.opsForList().rightPush(key, value);
    }

    public Object listPop(String key) {
        return redisTemplate.opsForList().leftPop(key);
    }

    public List<Object> listRange(String key, long start, long end) {
        return redisTemplate.opsForList().range(key, start, end);
    }

    public long listSize(String key) {
        return redisTemplate.opsForList().size(key);
    }

    public void listRemove(String key, long count, Object value) {
        redisTemplate.opsForList().remove(key, count, value);
    }

    public void setAdd(String key, Object... values) {
        redisTemplate.opsForSet().add(key, values);
    }

    public Set<Object> setMembers(String key) {
        return redisTemplate.opsForSet().members(key);
    }

    public boolean setIsMember(String key, Object value) {
        return Boolean.TRUE.equals(redisTemplate.opsForSet().isMember(key, value));
    }

    public void setRemove(String key, Object... values) {
        redisTemplate.opsForSet().remove(key, values);
    }

    public long setSize(String key) {
        return redisTemplate.opsForSet().size(key);
    }

    public void zSetAdd(String key, Object value, double score) {
        redisTemplate.opsForZSet().add(key, value, score);
    }

    public Set<Object> zSetRange(String key, long start, long end) {
        return redisTemplate.opsForZSet().range(key, start, end);
    }

    public void zSetRemove(String key, Object... values) {
        redisTemplate.opsForZSet().remove(key, values);
    }

    public long zSetSize(String key) {
        return redisTemplate.opsForZSet().size(key);
    }

    public Double zSetScore(String key, Object value) {
        return redisTemplate.opsForZSet().score(key, value);
    }
}