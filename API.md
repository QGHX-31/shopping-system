# 接口文档（阶段2 - 商家模块）

> BaseURL：`http://localhost:8081`(user) / `8082`(product) / `8083`(marketing)
> 前端通过 Vite 代理统一访问 `/api/...`
> 统一返回：`{ code: 200, message: "成功", data: ... }`
> 鉴权：`Authorization: Bearer <token>`

---

## 1. 商家认证服务（端口 8082 - product-service）

### 1.1 商家登录
- `POST /merchant/login`
- Body：`{ username, password }`
- 响应：`{ token, merchant: {...} }`
- 测试账号：`merchant01` / `123456`

### 1.2 商家信息
- `GET /merchant/info?merchantId={id}`

### 1.3 商家登出
- `POST /merchant/logout`

---

## 2. 商品微服务（端口 8082）

### 2.1 商品基础

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/product/list?categoryId=&keyword=&page=&size=` | 商品列表 |
| GET | `/product/hot` | 热门商品（缓存30min） |
| GET | `/product/new` | 新品（缓存30min） |
| GET | `/product/detail/{id}` | 商品详情（缓存30min） |

### 2.2 商家商品管理

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/product/merchant/list?merchantId=&keyword=&status=&page=&size=` | 商家商品列表 |
| POST | `/product/merchant/create?merchantId=` | 创建商品 |
| PUT | `/product/merchant/update?merchantId=` | 更新商品 |
| PUT | `/product/merchant/status/{id}?merchantId=&status=` | 上下架 |

### 2.3 分类

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/category/list` | 全部分类 |
| GET | `/category/top` | 顶级分类 |

### 2.4 SKU库存

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/sku/list/{productId}` | 某商品SKU列表 |
| POST | `/sku/add` | 新增SKU |
| PUT | `/sku/update` | 更新SKU |
| DELETE | `/sku/delete/{id}` | 删除SKU |
| POST | `/sku/stock/adjust?skuId=&quantity=&remark=` | 库存调整（正数入库，负数出库） |

### 2.5 库存微服务内部 API（供营销服务RPC调用）

| 方法 | 路径 | 描述 |
|------|------|------|
| (内部) | `ProductSkuService#lockStock(skuId, quantity, refNo, type)` | 锁定库存（下单/秒杀） |
| (内部) | `ProductSkuService#releaseStock(skuId, quantity, refNo)` | 释放库存（取消/超时） |
| (内部) | `ProductSkuService#deductStock(skuId, quantity, refNo)` | 扣减库存（支付完成） |
| (内部) | `ProductSkuService#rollbackStock(skuId, quantity, refNo)` | 回滚库存（退款） |

### 2.6 数据看板

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/merchant/dashboard/summary?merchantId=` | 今日数据+商家信息+7日趋势 |
| GET | `/merchant/dashboard/sales-trend?merchantId=&days=` | 销售趋势数据 |

---

## 3. 营销微服务（端口 8083）

### 3.1 秒杀

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/seckill/activity/create` | 创建秒杀活动（携带商品列表） |
| GET | `/seckill/activity/merchant?merchantId=&page=&size=` | 商家秒杀活动列表 |
| GET | `/seckill/activity/active` | 用户端：进行中活动 |
| GET | `/seckill/activity/{id}` | 活动详情 |
| POST | `/seckill/place` (Header) | 秒杀下单（用户从token） |

**秒杀下单 Body**：
```json
{
  "activityId": 1,
  "productId": 1,
  "skuId": 1,
  "quantity": 1
}
```

**业务流程**：
1. 校验活动状态（start/end/status）
2. 校验每人限购（Redis 计数器）
3. 原子扣减秒杀库存（CAS SQL）
4. 写秒杀订单
5. Redis 更新限购计数
6. MQ 异步发 `SECKILL_PLACE` 消息

### 3.2 拼团

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/group/activity/create` | 创建拼团活动 |
| GET | `/group/activity/merchant?merchantId=&page=&size=` | 商家拼团活动列表 |
| GET | `/group/activity/active` | 用户端：进行中活动 |
| GET | `/group/activity/{id}` | 活动详情 |
| POST | `/group/team/open?activityId=` (Header) | 开团 |
| POST | `/group/team/join?teamNo=` (Header) | 参团 |
| GET | `/group/team/{teamNo}` | 团详情 |

**业务流程**：
- 开团：写团记录、团长入团、扣减活动库存、发 `GROUP_CREATED` 消息
- 参团：原子自增 `current_num`、检查是否成团（>=required_num 标记 1）、发 `GROUP_SUCCESS` 消息
- 定时任务（每分钟）：扫描过期团标记 2、回退库存、发 `GROUP_FAIL` 消息

### 3.3 优惠券

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/coupon/template/create` | 创建券模板 |
| GET | `/coupon/template/merchant?merchantId=&page=&size=` | 商家券模板列表 |
| GET | `/coupon/template/active` | 启用中的券 |
| POST | `/coupon/receive?templateId=` (Header) | 领取 |
| GET | `/coupon/mine?status=` (Header) | 我的券（status: 0未用/1已用/2过期） |
| GET | `/coupon/calc?userCouponId=&orderAmount=` | 计算优惠 |
| POST | `/coupon/use?userCouponId=&orderNo=` | 使用券 |

**券类型**：
- type=1 满减：`discount_amount` 元
- type=2 折扣：`discount_amount` 为 0~1（如 0.9=9折）
- type=3 固定金额：`discount_amount` 元

---

## 4. MQ 异步消息

### 4.1 Topic 清单

| Topic | 描述 | Producer | Consumer |
|-------|------|----------|----------|
| `seckill_start` | 秒杀活动开始 | marketing | product |
| `seckill_place` | 秒杀下单 | marketing | product/user |
| `group_created` | 拼团创建 | marketing | product |
| `group_success` | 拼团成团 | marketing | product/user |
| `group_fail` | 拼团失败 | marketing | product/user |
| `coupon_receive` | 券领取 | marketing | user |
| `coupon_use` | 券使用 | marketing | order |
| `stock_deduct` | 库存扣减 | product | product |
| `stock_rollback` | 库存回滚 | product | product |

### 4.2 消息结构
```java
class Message {
    String messageId;     // UUID
    String topic;         // 主题
    String tags;          // 标签
    String businessKey;   // 业务键
    Object body;          // 消息体
    LocalDateTime createTime;
    Integer retryCount;
}
```

### 4.3 可靠投递
- 发送前落 `mq_message_log`（status=0）
- 发送后更新 status=1
- 消费成功后 status=2
- 消费失败：最多重试 3 次，指数退避，最终 status=3
- 服务启动时扫描 status=0 的待发消息重新投递

---

## 5. 缓存策略

| Key 模式 | 内容 | TTL |
|---------|------|-----|
| `user:info:{id}` | 用户信息 | 30 min |
| `member:info:{id}` | 会员信息 | 30 min |
| `cart:list:{userId}` | 购物车 | 10 min |
| `favorite:list:{userId}` | 收藏 | 10 min |
| `product:detail:{id}` | 商品详情 | 30 min |
| `product:hot` | 热门商品 | 30 min |
| `product:new` | 新品 | 30 min |
| `category:all` | 全部分类 | 60 min |
| `category:top` | 顶级分类 | 60 min |
| `sku:detail:{id}` | SKU详情 | 10 min |
| `seckill:bought:{activityId}:{productId}:{userId}` | 每人限购计数 | 24 hour |

---

## 6. 错误码

| code | 含义 |
|------|------|
| 200 | 成功 |
| 400 | 业务校验失败 |
| 401 | 未登录/登录失效 |
| 500 | 系统异常 |

---

## 7. 前端路由

### C端（用户）
- `/seckill` 秒杀专区
- `/group` 拼团专区
- `/coupon` 领券中心

### B端（商家）
- `/merchant/login` 商家登录
- `/merchant/dashboard` 数据看板
- `/merchant/product` 商品管理
- `/merchant/sku` SKU库存
- `/merchant/marketing/seckill` 秒杀活动
- `/merchant/marketing/group` 拼团活动
- `/merchant/marketing/coupon` 优惠券管理
