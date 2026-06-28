package com.shopping.order.aspect;

import com.alibaba.fastjson2.JSON;
import com.shopping.common.exception.BusinessException;
import com.shopping.common.utils.RedisUtil;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.DigestUtils;

import java.lang.reflect.Method;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeUnit;

@Slf4j
@Aspect
@Component
public class IdempotentAspect {

    private static final String IDEMPOTENT_KEY_PREFIX = "idempotent:";
    private static final long IDEMPOTENT_EXPIRE_SECONDS = 10;

    @Autowired(required = false)
    private RedisUtil redisUtil;

    @Around("@annotation(com.shopping.order.annotation.Idempotent)")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        if (redisUtil == null) {
            return joinPoint.proceed();
        }

        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        com.shopping.order.annotation.Idempotent idempotent = method.getAnnotation(com.shopping.order.annotation.Idempotent.class);

        String key = generateKey(joinPoint, method, idempotent);

        String cacheKey = IDEMPOTENT_KEY_PREFIX + key;

        try {
            if (redisUtil.exists(cacheKey)) {
                log.warn("检测到重复请求，方法: {}, key: {}", method.getName(), key);
                Object cachedResult = redisUtil.get(cacheKey + ":result", Object.class);
                if (cachedResult != null) {
                    return cachedResult;
                }
                throw new BusinessException("重复操作，请稍后再试");
            }

            redisUtil.set(cacheKey, "1", IDEMPOTENT_EXPIRE_SECONDS, TimeUnit.SECONDS);

            Object result = joinPoint.proceed();

            try {
                redisUtil.set(cacheKey + ":result", result, IDEMPOTENT_EXPIRE_SECONDS, TimeUnit.SECONDS);
            } catch (Exception e) {
                log.warn("缓存幂等结果失败", e);
            }

            return result;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            try {
                redisUtil.delete(cacheKey);
                redisUtil.delete(cacheKey + ":result");
            } catch (Exception ex) {
                log.warn("删除幂等key失败", ex);
            }
            throw e;
        }
    }

    private String generateKey(ProceedingJoinPoint joinPoint, Method method, com.shopping.order.annotation.Idempotent idempotent) {
        StringBuilder sb = new StringBuilder();
        sb.append(method.getDeclaringClass().getName()).append(".").append(method.getName());

        if (idempotent != null && idempotent.token() != null && !idempotent.token().isEmpty()) {
            sb.append(":").append(idempotent.token());
        }

        Object[] args = joinPoint.getArgs();
        if (args != null && args.length > 0) {
            try {
                String argsJson = JSON.toJSONString(args);
                String argsHash = DigestUtils.md5DigestAsHex(argsJson.getBytes(StandardCharsets.UTF_8));
                sb.append(":").append(argsHash);
            } catch (Exception e) {
                log.warn("生成参数哈希失败", e);
            }
        }

        return sb.toString();
    }
}
