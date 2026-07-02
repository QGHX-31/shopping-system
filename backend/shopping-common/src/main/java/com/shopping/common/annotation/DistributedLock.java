package com.shopping.common.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.concurrent.TimeUnit;

/**
 * 分布式锁注解
 * 用于标注需要加分布式锁的方法
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface DistributedLock {
    
    /**
     * 锁的唯一标识，支持SpEL表达式
     * 例如: "'seckill:order:' + #activityId + ':' + #userId"
     */
    String key();
    
    /**
     * 获取锁的最大等待时间（秒）
     * 默认等待3秒
     */
    long waitTime() default 3;
    
    /**
     * 锁的自动释放时间（秒）
     * 默认10秒后自动释放
     */
    long leaseTime() default 10;
    
    /**
     * 时间单位
     * 默认秒
     */
    TimeUnit timeUnit() default TimeUnit.SECONDS;
}