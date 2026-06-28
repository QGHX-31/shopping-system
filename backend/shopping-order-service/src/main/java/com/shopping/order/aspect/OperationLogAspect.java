package com.shopping.order.aspect;

import com.shopping.order.entity.OperationLog;
import com.shopping.order.mapper.OperationLogMapper;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.lang.reflect.Method;
import java.time.LocalDateTime;

@Slf4j
@Aspect
@Component
public class OperationLogAspect {

    private final OperationLogMapper operationLogMapper;

    public OperationLogAspect(OperationLogMapper operationLogMapper) {
        this.operationLogMapper = operationLogMapper;
    }

    @Around("@annotation(com.shopping.order.annotation.OperationLog)")
    public Object around(ProceedingJoinPoint joinPoint) throws Throwable {
        long startTime = System.currentTimeMillis();
        OperationLog operationLog = new OperationLog();
        try {
            MethodSignature signature = (MethodSignature) joinPoint.getSignature();
            Method method = signature.getMethod();
            com.shopping.order.annotation.OperationLog operationLogAnnotation = method.getAnnotation(com.shopping.order.annotation.OperationLog.class);

            operationLog.setOperation(operationLogAnnotation.value());
            operationLog.setMethod(joinPoint.getTarget().getClass().getName() + "." + method.getName());

            Object[] args = joinPoint.getArgs();
            if (args != null && args.length > 0) {
                StringBuilder params = new StringBuilder();
                for (Object arg : args) {
                    if (arg != null) {
                        params.append(arg.toString()).append(",");
                    }
                }
                if (params.length() > 0) {
                    params.deleteCharAt(params.length() - 1);
                }
                operationLog.setParams(params.toString());
            }

            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest request = attributes.getRequest();
                operationLog.setIp(request.getRemoteAddr());
            }

            operationLog.setCreatedAt(LocalDateTime.now());

            Object result = joinPoint.proceed();

            operationLog.setStatus(1);
            return result;
        } catch (Throwable e) {
            operationLog.setStatus(0);
            operationLog.setErrorMsg(e.getMessage());
            throw e;
        } finally {
            long costTime = (int) (System.currentTimeMillis() - startTime);
            operationLog.setCostTime((int) costTime);
            try {
                operationLogMapper.insert(operationLog);
            } catch (Exception ex) {
                log.error("保存操作日志失败", ex);
            }
        }
    }
}
