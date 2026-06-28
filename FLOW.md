# 购物系统 - 活动业务流程图 & 接口文档

## 一、活动业务流程图

### 1. 秒杀业务流程

```
用户进入秒杀页
   ↓
查询活动状态 (Redis缓存)
   ↓
点击"立即抢购"
   ↓
限流校验 (用户限购检查)
   ↓
Redis 原子扣减库存 (DECR)
   ↓
库存 < 0 ?
   ├─ 是 → 回滚库存 → 返回"已售罄"
   └─ 否 → 继续
   ↓
生成秒杀订单
   ↓
更新 DB 库存
   ↓
发送 MQ: SECKILL_PLACE (异步通知订单服务、库存服务)
   ↓
返回下单结果
   ↓
若库存为 0 → 发送 MQ: SECKILL_END (活动结束)
```

### 2. 拼团业务流程

```
用户发起拼团
   ↓
校验活动状态
   ↓
Redis 扣减库存
   ↓
创建拼团 Team
   ↓
发送 MQ: GROUP_CREATED
   ↓
其他用户加入拼团
   ↓
更新 Team.currentNum
   ↓
当前人数 >= 所需人数 ?
   ├─ 是 → Team.status = 1 (成功) → 发送 MQ: GROUP_SUCCESS
   └─ 否 → 等待
   ↓
定时任务 (每分钟) 检查过期 Team
   ↓
过期且未成团 → Team.status = 2 (失败) → 库存回滚
```

### 3. 优惠券业务流程

```
用户领取优惠券
   ↓
校验优惠券状态 (active)
   ↓
校验用户领取限制
   ↓
原子扣减剩余数量 (Redis DECR)
   ↓
数量 < 0 ?
   ├─ 是 → 回滚 → 返回"已领完"
   └─ 否 → 写入 user_coupon
   ↓
用户下单
   ↓
选择优惠券
   ↓
校验使用门槛 (订单金额 >= minAmount)
   ↓
校验有效期
   ↓
抵扣金额
   ↓
更新优惠券状态 (used)
```

### 4. 库存扣减流程

```
下单
   ↓
锁定库存 (Redis + DB)
   ↓
发送 MQ: STOCK_DEDUCT
   ↓
支付
   ↓
扣减真实库存 (DB)
   ↓
发送 MQ: STOCK_CONFIRM
   ↓
若支付超时 (15分钟)
   ↓
定时任务扫描
   ↓
回滚锁定库存
   ↓
发送 MQ: STOCK_ROLLBACK
```

## 二、MQ 消息主题

| Topic | 说明 | 生产者 | 消费者 |
|-------|------|--------|--------|
| SECKILL_PLACE | 秒杀下单通知 | marketing-service | order-service, product-service |
| SECKILL_END | 秒杀活动结束 | marketing-service | frontend, product-service |
| GROUP_CREATED | 拼团创建 | marketing-service | notification-service |
| GROUP_SUCCESS | 拼团成功 | marketing-service | order-service, user-service |
| GROUP_FAILED | 拼团失败 | marketing-service | order-service |
| COUPON_GRAB | 优惠券领取 | marketing-service | user-service |
| STOCK_DEDUCT | 库存扣减 | product-service | order-service, marketing-service |
| STOCK_ROLLBACK | 库存回滚 | product-service | product-service |
| ORDER_CREATED | 订单创建 | order-service | user-service, product-service |
| ORDER_PAID | 订单支付 | order-service | product-service, marketing-service |

## 三、商家后台 API 文档

### 1. 商家登录

```
POST /api/merchant/login
Content-Type: application/json

Request:
{
  "username": "merchant001",
  "password": "123456"
}

Response:
{
  "code": 200,
  "data": {
    "id": 1,
    "username": "merchant001",
    "name": "XX旗舰店"
  }
}
```

### 2. 数据看板

```
GET /api/merchant/stats/{merchantId}

Response:
{
  "code": 200,
  "data": {
    "productCount": 50,
    "totalSales": 1000,
    "totalRevenue": 500000.00,
    "orderCount": 800
  }
}
```

### 3. 商品管理

```
GET /api/merchant/product/list
参数: merchantId, keyword, page, size

PUT /api/merchant/product/{id}/status
参数: status (0/1)
```

### 4. SKU库存管理

```
GET /api/sku/list/all
分页查询所有SKU

PUT /api/sku/{id}/stock
参数: count (正数入库，负数出库)
```

### 5. 营销活动

```
GET /api/seckill/list    - 秒杀活动列表
GET /api/group/list      - 拼团活动列表
GET /api/coupon/list     - 优惠券列表
```

## 四、前端商家后台页面

| 路径 | 功能 |
|------|------|
| `/merchant/login` | 商家登录 |
| `/merchant/dashboard` | 数据看板（商品总数、销量、销售额、订单数） |
| `/merchant/products` | 商品管理（搜索、上下架） |
| `/merchant/skus` | SKU库存管理（调整库存） |
| `/merchant/marketing` | 营销活动（秒杀/拼团/优惠券） |

## 五、缓存策略

| 数据 | 缓存Key | TTL | 失效时机 |
|------|---------|-----|----------|
| 商品详情 | `product:detail:{id}` | 30分钟 | 更新/上下架 |
| 秒杀库存 | `seckill:stock:{productId}` | 活动期间 | 活动结束 |
| 用户限购 | `seckill:user:limit:{userId}:{activityId}` | 活动期间 | 活动结束 |
| 拼团库存 | `group:stock:{activityId}` | 活动期间 | 活动结束 |
| 库存锁定 | `sku:lock:stock:{skuId}` | 15分钟 | 支付成功/超时 |

## 六、商家后台登录测试账号

数据库中需要初始化一个商家账号（建议直接 SQL 插入）：

```sql
INSERT INTO merchant (id, username, password, name, status) 
VALUES (1, 'merchant001', '123456', 'XX旗舰店', 1);
```

访问 `http://localhost:3003/merchant/login` 用上述账号登录。
