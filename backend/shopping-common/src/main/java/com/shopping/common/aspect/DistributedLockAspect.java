package com.shopping.common.aspect;

import com.shopping.common.annotation.DistributedLock;
import com.shopping.common.exception.BusinessException;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.expression.spel.support.StandardEvaluationContext;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;

/**
 * 分布式锁切面
 * 
 * 注意：使用 @Order(Ordered.LOWEST_PRECEDENCE - 1) 确保分布式锁切面优先级高于事务切面
 * 这样可以保证：先加锁 -> 开启事务 -> 执行业务 -> 提交事务 -> 释放锁
 * 避免"锁释放了但事务还没提交"的竞态条件
 */
@Slf4j
@Aspect
@Component
@Order(Ordered.LOWEST_PRECEDENCE - 1)
public class DistributedLockAspect {

    @Resource
    private RedissonClient redissonClient;

    private final ExpressionParser parser = new SpelExpressionParser();

    @Around("@annotation(distributedLock)")
    public Object around(ProceedingJoinPoint joinPoint, DistributedLock distributedLock) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Object[] args = joinPoint.getArgs();
        
        // 解析SpEL表达式生成锁的key
        String lockKey = parseLockKey(distributedLock.key(), method, args);
        
        RLock lock = redissonClient.getLock(lockKey);
        boolean locked = false;
        
        try {
            // 尝试获取锁
            locked = lock.tryLock(distributedLock.waitTime(), distributedLock.leaseTime(), distributedLock.timeUnit());
            
            if (!locked) {
                log.warn("获取分布式锁失败: lockKey={}, method={}", lockKey, method.getName());
                throw new BusinessException("操作过于频繁，请稍后再试");
            }
            
            log.info("获取分布式锁成功: lockKey={}, method={}", lockKey, method.getName());
            
            // 执行业务方法
            return joinPoint.proceed();
            
        } finally {
            // 释放锁（只有当前线程持有锁时才释放）
            if (locked && lock.isHeldByCurrentThread()) {
                lock.unlock();
                log.info("释放分布式锁成功: lockKey={}, method={}", lockKey, method.getName());
            }
        }
    }

    /**
     * 解析SpEL表达式生成锁的key
     * 
     * @param spelExpression SpEL表达式，如 "'seckill:order:' + #activityId + ':' + #userId"
     * @param method 方法对象
     * @param args 方法参数值
     * @return 解析后的锁key
     */
    private String parseLockKey(String spelExpression, Method method, Object[] args) {
        StandardEvaluationContext context = new StandardEvaluationContext();
        
        // 获取方法参数名和值，设置到SpEL上下文中
        Parameter[] parameters = method.getParameters();
        for (int i = 0; i < parameters.length && i < args.length; i++) {
            String paramName = parameters[i].getName();
            Object paramValue = args[i];
            context.setVariable(paramName, paramValue);
        }
        
        // 解析SpEL表达式
        return parser.parseExpression(spelExpression).getValue(context, String.class);
    }
}