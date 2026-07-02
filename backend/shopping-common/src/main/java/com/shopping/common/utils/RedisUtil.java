package com.shopping.common.utils;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.TypeReference;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.nio.charset.StandardCharsets;
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

    /**
     * 原子扣减库存（使用Redis底层连接执行Lua脚本，保证原子性，防止超卖）
     * 
     * Lua脚本逻辑：
     * 1. 获取当前库存（直接操作Redis原始字节，绕过JSON序列化）
     * 2. 如果库存不存在，返回 -2
     * 3. 如果库存 < 扣减数量，返回 -1
     * 4. 否则扣减库存，返回扣减后的值
     * 
     * @param key 库存key
     * @param delta 扣减数量
     * @return 扣减后的库存（>=0），库存不足返回 -1，key不存在返回 -2
     */
    public Long atomicDecrement(String key, long delta) {
        String luaScript = 
            "local current = redis.call('GET', KEYS[1]) " +
            "if current == false or current == nil then " +
            "  return -2 " +
            "end " +
            "current = tonumber(current) " +
            "if current == nil then " +
            "  return -2 " +
            "end " +
            "if current < tonumber(ARGV[1]) then " +
            "  return -1 " +
            "end " +
            "return redis.call('DECRBY', KEYS[1], ARGV[1])";
        
        try {
            byte[] result = redisTemplate.execute((RedisCallback<byte[]>) connection -> 
                connection.scriptingCommands().eval(
                    luaScript.getBytes(StandardCharsets.UTF_8),
                    org.springframework.data.redis.connection.ReturnType.INTEGER,
                    1,
                    key.getBytes(StandardCharsets.UTF_8),
                    String.valueOf(delta).getBytes(StandardCharsets.UTF_8)
                )
            );
            if (result == null) {
                return -2L;
            }
            return Long.parseLong(new String(result, StandardCharsets.UTF_8));
        } catch (Exception e) {
            return -2L;
        }
    }

    /**
     * 原子扣减库存（严格模式，秒杀场景使用）
     * 与 atomicDecrement 行为一致，单独提供是为了语义清晰
     * 
     * @param key 库存key
     * @param delta 扣减数量
     * @return 扣减后的库存（>=0），库存不足返回 -1，key不存在返回 -2
     */
    public Long atomicDecrementStrict(String key, long delta) {
        return atomicDecrement(key, delta);
    }

    /**
     * 原子自增（用于补偿回滚）
     * 
     * @param key 库存key
     * @param delta 增加数量
     * @return 增加后的值
     */
    public Long atomicIncrement(String key, long delta) {
        return redisTemplate.opsForValue().increment(key, delta);
    }

    /**
     * 直接设置字符串值到Redis（绕过JSON序列化，用于Lua脚本操作）
     * 
     * @param key 键
     * @param value 字符串值
     */
    public void setRawString(String key, String value) {
        redisTemplate.execute((RedisCallback<Void>) connection -> {
            connection.stringCommands().set(
                key.getBytes(StandardCharsets.UTF_8),
                value.getBytes(StandardCharsets.UTF_8)
            );
            return null;
        });
    }

    /**
     * 直接获取字符串值（绕过JSON反序列化）
     * 
     * @param key 键
     * @return 字符串值，不存在返回 null
     */
    public String getRawString(String key) {
        byte[] result = redisTemplate.execute((RedisCallback<byte[]>) connection -> 
            connection.stringCommands().get(key.getBytes(StandardCharsets.UTF_8))
        );
        if (result == null) {
            return null;
        }
        return new String(result, StandardCharsets.UTF_8);
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