package com.shopping.user.config;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONReader;
import com.alibaba.fastjson2.JSONWriter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.RedisSerializer;
import org.springframework.data.redis.serializer.SerializationException;

import java.nio.charset.Charset;

@Configuration
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        template.setKeySerializer(RedisSerializer.string());
        template.setHashKeySerializer(RedisSerializer.string());
        template.setValueSerializer(new FastJson2RedisSerializer<>(Object.class));
        template.setHashValueSerializer(new FastJson2RedisSerializer<>(Object.class));
        template.afterPropertiesSet();
        return template;
    }

    public static class FastJson2RedisSerializer<T> implements RedisSerializer<T> {
        private final Class<T> clazz;

        public FastJson2RedisSerializer(Class<T> clazz) {
            this.clazz = clazz;
        }

        @Override
        public byte[] serialize(T t) throws SerializationException {
            if (t == null) {
                return new byte[0];
            }
            return JSON.toJSONString(t, JSONWriter.Feature.WriteClassName).getBytes(Charset.defaultCharset());
        }

        @Override
        @SuppressWarnings("unchecked")
        public T deserialize(byte[] bytes) throws SerializationException {
            if (bytes == null || bytes.length == 0) {
                return null;
            }
            String str = new String(bytes, Charset.defaultCharset());
            return JSON.parseObject(str, clazz, JSONReader.Feature.SupportAutoType);
        }
    }
}
