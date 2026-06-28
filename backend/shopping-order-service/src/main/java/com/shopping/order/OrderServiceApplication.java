package com.shopping.order;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 订单/支付/售后/运营后台微服务启动类
 * 端口: 8084
 */
@SpringBootApplication(scanBasePackages = {"com.shopping.order", "com.shopping.common"})
@MapperScan({"com.shopping.order.mapper", "com.shopping.order.admin.mapper"})
@EnableScheduling
@EnableDiscoveryClient
@EnableFeignClients
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}
