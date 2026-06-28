# 购物系统数据库设计文档

## 1. 需求分析

根据业务需求，系统需要支持以下核心功能：
- 用户注册、登录、个人信息管理
- 会员等级体系、积分管理
- 消息通知系统
- 商品分类、商品展示
- 购物车管理
- 商品收藏功能
- 收货地址管理

## 2. 数据库设计

### 2.1 数据库概述

| 项目 | 说明 |
|------|------|
| 数据库名称 | shopping_system |
| 字符集 | utf8mb4 |
| 排序规则 | utf8mb4_unicode_ci |
| 存储引擎 | InnoDB |

### 2.2 E-R图描述

#### 实体关系：

1. **用户(User)** 与 **会员(Member)**：一对一关系
   - 一个用户对应一个会员记录

2. **用户(User)** 与 **积分记录(PointsRecord)**：一对多关系
   - 一个用户可以有多条积分变动记录

3. **用户(User)** 与 **消息(Message)**：一对多关系
   - 一个用户可以有多条消息

4. **用户(User)** 与 **购物车(Cart)**：一对多关系
   - 一个用户可以有多件商品在购物车

5. **用户(User)** 与 **收藏(Favorite)**：一对多关系
   - 一个用户可以收藏多件商品

6. **用户(User)** 与 **收货地址(Address)**：一对多关系
   - 一个用户可以有多个收货地址

7. **分类(Category)** 与 **商品(Product)**：一对多关系
   - 一个分类下可以有多件商品

8. **商品(Product)** 与 **购物车(Cart)**：一对多关系
   - 一件商品可以被多个用户加入购物车

9. **商品(Product)** 与 **收藏(Favorite)**：一对多关系
   - 一件商品可以被多个用户收藏

### 2.3 表结构详情

#### 2.3.1 用户表 (user)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 用户ID |
| username | VARCHAR(50) | NOT NULL UNIQUE | 用户名 |
| password | VARCHAR(100) | NOT NULL | 密码(加密存储) |
| email | VARCHAR(100) | UNIQUE | 邮箱 |
| phone | VARCHAR(20) | UNIQUE | 手机号 |
| nickname | VARCHAR(50) | | 昵称 |
| avatar | VARCHAR(255) | | 头像URL |
| status | TINYINT | DEFAULT 1 | 状态：0禁用，1启用 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 2.3.2 会员表 (member)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 会员ID |
| user_id | BIGINT | NOT NULL UNIQUE | 用户ID |
| member_level | TINYINT | DEFAULT 1 | 会员等级：1普通，2银卡，3金卡，4钻石 |
| total_points | INT | DEFAULT 0 | 总积分 |
| available_points | INT | DEFAULT 0 | 可用积分 |
| member_since | DATETIME | DEFAULT CURRENT_TIMESTAMP | 成为会员时间 |
| expire_time | DATETIME | | 会员到期时间 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 2.3.3 积分记录表 (points_record)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 记录ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| points | INT | NOT NULL | 积分变动数量 |
| type | TINYINT | | 类型：1获取，2消费，3过期 |
| source | VARCHAR(100) | | 来源描述 |
| order_no | VARCHAR(50) | | 关联订单号 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

#### 2.3.4 消息表 (message)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 消息ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| title | VARCHAR(100) | NOT NULL | 消息标题 |
| content | TEXT | | 消息内容 |
| type | TINYINT | DEFAULT 1 | 类型：1系统，2订单，3促销 |
| is_read | TINYINT | DEFAULT 0 | 是否已读：0未读，1已读 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 2.3.5 商品分类表 (category)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 分类ID |
| name | VARCHAR(50) | NOT NULL | 分类名称 |
| parent_id | BIGINT | DEFAULT 0 | 父分类ID |
| sort_order | INT | DEFAULT 0 | 排序号 |
| icon | VARCHAR(255) | | 图标URL |
| status | TINYINT | DEFAULT 1 | 状态：0禁用，1启用 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 2.3.6 商品表 (product)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 商品ID |
| name | VARCHAR(200) | NOT NULL | 商品名称 |
| category_id | BIGINT | NOT NULL | 分类ID |
| brand | VARCHAR(50) | | 品牌 |
| price | DECIMAL(10,2) | NOT NULL | 价格 |
| original_price | DECIMAL(10,2) | | 原价 |
| stock | INT | DEFAULT 0 | 库存 |
| sales_count | INT | DEFAULT 0 | 销量 |
| description | TEXT | | 商品描述 |
| image_url | VARCHAR(255) | | 主图URL |
| detail_images | TEXT | | 详情图片JSON |
| is_hot | TINYINT | DEFAULT 0 | 是否热门 |
| is_new | TINYINT | DEFAULT 0 | 是否新品 |
| status | TINYINT | DEFAULT 1 | 状态：0下架，1上架 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 2.3.7 购物车表 (cart)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 购物车ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| product_id | BIGINT | NOT NULL | 商品ID |
| quantity | INT | DEFAULT 1 | 数量 |
| selected | TINYINT | DEFAULT 1 | 是否选中 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

#### 2.3.8 收藏表 (favorite)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 收藏ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| product_id | BIGINT | NOT NULL | 商品ID |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

#### 2.3.9 收货地址表 (address)

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY AUTO_INCREMENT | 地址ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| name | VARCHAR(50) | NOT NULL | 收货人姓名 |
| phone | VARCHAR(20) | NOT NULL | 收货人电话 |
| province | VARCHAR(50) | | 省份 |
| city | VARCHAR(50) | | 城市 |
| district | VARCHAR(50) | | 区县 |
| detail | VARCHAR(200) | | 详细地址 |
| is_default | TINYINT | DEFAULT 0 | 是否默认地址 |
| status | TINYINT | DEFAULT 1 | 状态：0禁用，1启用 |
| created_at | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

## 3. 索引优化策略

### 3.1 用户表索引
- `idx_username`: 加速用户名查询（登录验证）
- `idx_email`: 加速邮箱查询（找回密码）
- `idx_phone`: 加速手机号查询

### 3.2 会员表索引
- `idx_user_id`: 加速会员信息查询
- `idx_member_level`: 加速会员等级统计

### 3.3 积分记录表索引
- `idx_user_id`: 加速用户积分记录查询
- `idx_type`: 加速按类型筛选积分记录
- `idx_created_at`: 加速按时间范围查询

### 3.4 消息表索引
- `idx_user_id`: 加速用户消息查询
- `idx_is_read`: 加速未读消息统计
- `idx_type`: 加速按类型筛选消息

### 3.5 商品表索引
- `idx_category_id`: 加速分类商品查询
- `idx_is_hot`: 加速热门商品查询
- `idx_is_new`: 加速新品查询
- `idx_sales_count`: 加速销量排序

### 3.6 购物车表索引
- `idx_user_product`: 唯一性约束，防止重复添加

### 3.7 收藏表索引
- `idx_user_product`: 唯一性约束，防止重复收藏

### 3.8 地址表索引
- `idx_user_id`: 加速用户地址查询
- `idx_is_default`: 加速默认地址查询

## 4. 数据库连接池配置建议

### 4.1 连接池参数配置

| 参数 | 建议值 | 说明 |
|------|--------|------|
| maximum-pool-size | 20 | 最大连接数 |
| minimum-idle | 5 | 最小空闲连接数 |
| idle-timeout | 300000 | 空闲连接超时时间(5分钟) |
| connection-timeout | 30000 | 连接超时时间(30秒) |
| max-lifetime | 1800000 | 连接最大生命周期(30分钟) |

### 4.2 配置示例

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/shopping_system?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
    username: admin
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      idle-timeout: 300000
      connection-timeout: 30000
      max-lifetime: 1800000
```

## 5. 阶段2新增表（商家/SKU/营销/MQ）

### 5.1 商家表 (merchant)
- 主键：`id`
- 索引：`idx_username`、`idx_status`、`idx_shop_name`
- 字段：账号、密码、店铺名、联系人、状态、等级

### 5.2 商品SKU表 (product_sku)
- 主键：`id`
- 索引：`idx_product_id`、`idx_merchant_id`、`idx_sku_code`
- 字段：商品ID、商家ID、规格JSON、价格、库存、销量、图片
- 用途：多规格商品的库存管理

### 5.3 库存流水表 (stock_log)
- 主键：`id`
- 索引：`idx_sku_id`、`idx_product_id`、`idx_merchant_id`、`idx_type`、`idx_ref_no`
- 用途：所有库存变更的可追溯记录

### 5.4 秒杀相关表
- `seckill_activity`：秒杀活动主表，状态机为未开始/进行中/已结束/已取消
- `seckill_product`：秒杀商品表，关联活动和商品/SKU，含限购数量
- `seckill_order`：秒杀订单，状态为待支付/已支付/已取消/已退款

### 5.5 拼团相关表
- `group_buy_activity`：拼团活动表，含成团人数、成团时长
- `group_buy_team`：拼团团队表，状态为拼团中/已成团/已失败
- `group_buy_member`：拼团成员表，含团长标识

### 5.6 优惠券相关表
- `coupon_template`：券模板，类型分为满减/折扣/固定金额
- `user_coupon`：用户券，状态为未使用/已使用/已过期

### 5.7 商家数据看板
- `merchant_stats`：每日订单数、订单金额、浏览量、销量、新增客户

### 5.8 MQ消息日志
- `mq_message_log`：消息唯一ID、主题、标签、业务键、状态机、重试次数