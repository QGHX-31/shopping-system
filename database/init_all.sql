-- ============================================================
-- 购物系统 - 完整数据库初始化脚本（阶段3最终版）
-- 数据库：shopping_system
-- 字符集：utf8mb4
-- 说明：本文件包含所有表结构 + 初始数据
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS shopping_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE shopping_system;

-- 禁用外键检查，确保 DROP TABLE 不会因外键约束失败
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 第一部分：用户/会员/商品/分类/购物车/收藏/消息/地址
-- （来自 schema.sql 的核心表）
-- ============================================================

-- 用户表
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username`   VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password`   VARCHAR(100) NOT NULL COMMENT '密码',
    `email`      VARCHAR(100) UNIQUE COMMENT '邮箱',
    `phone`      VARCHAR(20) UNIQUE COMMENT '手机号',
    `nickname`   VARCHAR(50) COMMENT '昵称',
    `avatar`     VARCHAR(255) COMMENT '头像URL',
    `status`     TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`),
    INDEX `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 会员表
DROP TABLE IF EXISTS `member`;
CREATE TABLE `member` (
    `id`             BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会员ID',
    `user_id`        BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    `member_level`   TINYINT DEFAULT 1 COMMENT '会员等级：1普通会员，2银卡会员，3金卡会员，4钻石会员',
    `total_points`   INT DEFAULT 0 COMMENT '总积分',
    `available_points` INT DEFAULT 0 COMMENT '可用积分',
    `member_since`   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '成为会员时间',
    `expire_time`    DATETIME COMMENT '会员到期时间',
    `created_at`     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_member_level` (`member_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

-- 积分记录表
DROP TABLE IF EXISTS `points_record`;
CREATE TABLE `points_record` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '积分记录ID',
    `user_id`    BIGINT NOT NULL COMMENT '用户ID',
    `points`     INT NOT NULL COMMENT '积分变动数量',
    `type`       TINYINT COMMENT '类型：1获取，2消费，3过期',
    `source`     VARCHAR(100) COMMENT '来源描述',
    `order_no`   VARCHAR(50) COMMENT '关联订单号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分记录表';

-- 消息表
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    `user_id`    BIGINT NOT NULL COMMENT '用户ID',
    `title`      VARCHAR(200) NOT NULL COMMENT '消息标题',
    `content`    TEXT COMMENT '消息内容',
    `type`       TINYINT DEFAULT 1 COMMENT '类型：1订单通知 2退款通知 3活动通知 4系统通知',
    `is_read`    TINYINT DEFAULT 0 COMMENT '是否已读：0未读 1已读',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_is_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- 收货地址表
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
    `id`           BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '地址ID',
    `user_id`      BIGINT NOT NULL COMMENT '用户ID',
    `name`         VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    `phone`        VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `province`     VARCHAR(50) COMMENT '省份',
    `city`         VARCHAR(50) COMMENT '城市',
    `district`     VARCHAR(50) COMMENT '区县',
    `detail`       VARCHAR(200) COMMENT '详细地址',
    `is_default`   TINYINT DEFAULT 0 COMMENT '是否默认：0否，1是',
    `status`       TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at`   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_is_default` (`is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

-- 商品分类表
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    `name`       VARCHAR(50) NOT NULL COMMENT '分类名称',
    `parent_id`  BIGINT DEFAULT 0 COMMENT '父分类ID，0为顶级',
    `sort_order` INT DEFAULT 0 COMMENT '排序号',
    `icon`       VARCHAR(50) COMMENT '图标',
    `status`     TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_parent_id` (`parent_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

-- 商家表
DROP TABLE IF EXISTS `merchant`;
CREATE TABLE `merchant` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商家ID',
    `username`        VARCHAR(50) UNIQUE COMMENT '商家用户名',
    `password`        VARCHAR(100) COMMENT '密码（BCrypt）',
    `user_id`         BIGINT COMMENT '关联用户ID',
    `shop_name`       VARCHAR(100) NOT NULL COMMENT '店铺名称',
    `logo`            VARCHAR(255) COMMENT '店铺Logo',
    `contact_name`    VARCHAR(50) COMMENT '联系人姓名',
    `contact_phone`   VARCHAR(20) COMMENT '联系电话',
    `email`           VARCHAR(100) COMMENT '联系邮箱',
    `address`         VARCHAR(255) COMMENT '店铺地址',
    `business_license` VARCHAR(255) COMMENT '营业执照',
    `status`          TINYINT DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已拒绝 3已禁用',
    `level`           INT DEFAULT 1 COMMENT '等级',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家表';

-- 商品表
DROP TABLE IF EXISTS `product`;
CREATE TABLE `product` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `category_id` BIGINT COMMENT '分类ID',
    `name`        VARCHAR(200) NOT NULL COMMENT '商品名称',
    `sub_title`   VARCHAR(500) COMMENT '副标题',
    `brand`       VARCHAR(100) COMMENT '品牌',
    `image_url`   VARCHAR(255) COMMENT '主图URL',
    `detail_images` VARCHAR(1000) COMMENT '详情图片，逗号分隔',
    `price`       DECIMAL(10,2) NOT NULL COMMENT '售价',
    `original_price` DECIMAL(10,2) COMMENT '原价',
    `stock`       INT NOT NULL DEFAULT 0 COMMENT '库存',
    `sales_count` INT DEFAULT 0 COMMENT '销量',
    `description` TEXT COMMENT '商品详情',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0下架 1上架 2售罄',
    `is_hot`      TINYINT DEFAULT 0 COMMENT '是否热销：0否 1是',
    `is_new`      TINYINT DEFAULT 0 COMMENT '是否新品：0否 1是',
    `sort_order`  INT DEFAULT 0 COMMENT '排序号',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_category_id` (`category_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_sales_count` (`sales_count`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

-- 商品SKU表
DROP TABLE IF EXISTS `product_sku`;
CREATE TABLE `product_sku` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'SKU ID',
    `product_id`  BIGINT NOT NULL COMMENT '商品ID',
    `spec_values` VARCHAR(255) COMMENT '规格值，JSON格式',
    `price`       DECIMAL(10,2) NOT NULL COMMENT 'SKU价格',
    `stock`       INT NOT NULL DEFAULT 0 COMMENT '库存',
    `image`       VARCHAR(255) COMMENT 'SKU图片',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU表';

-- 购物车表
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '购物车ID',
    `user_id`    BIGINT NOT NULL COMMENT '用户ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`     BIGINT COMMENT 'SKU ID',
    `merchant_id` BIGINT COMMENT '商家ID',
    `quantity`   INT NOT NULL DEFAULT 1 COMMENT '数量',
    `selected`   TINYINT DEFAULT 1 COMMENT '是否选中：0否 1是',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_user_product_sku` (`user_id`, `product_id`, `sku_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

-- 收藏表
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
    `user_id`    BIGINT NOT NULL COMMENT '用户ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY `uk_user_product` (`user_id`, `product_id`),
    INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- ============================================================
-- 第二部分：优惠券/营销活动
-- ============================================================

-- 平台优惠券模板表
DROP TABLE IF EXISTS `platform_coupon_template`;
CREATE TABLE `platform_coupon_template` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name`             VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `type`             TINYINT NOT NULL COMMENT '类型：1满减券 2折扣券',
    `discount_amount`  DECIMAL(10,2) COMMENT '优惠金额（满减券）',
    `min_amount`       DECIMAL(10,2) DEFAULT 0 COMMENT '最低使用金额',
    `total_count`      INT DEFAULT 0 COMMENT '发放总量',
    `remaining_count`  INT DEFAULT 0 COMMENT '剩余数量',
    `per_user_limit`   INT DEFAULT 1 COMMENT '每人限领数量',
    `start_time`       DATETIME COMMENT '领取开始时间',
    `end_time`         DATETIME COMMENT '领取结束时间',
    `description`      VARCHAR(500) COMMENT '使用说明',
    `status`           TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台优惠券模板表';

-- 店铺优惠券模板表
DROP TABLE IF EXISTS `coupon_template`;
CREATE TABLE `coupon_template` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name`             VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `merchant_id`      BIGINT NOT NULL COMMENT '商家ID',
    `type`             TINYINT NOT NULL COMMENT '类型：1满减券 2折扣券',
    `discount_amount`  DECIMAL(10,2) COMMENT '优惠金额（满减券）',
    `min_amount`       DECIMAL(10,2) DEFAULT 0 COMMENT '最低使用金额',
    `total_count`      INT DEFAULT 0 COMMENT '发放总量',
    `remaining_count`  INT DEFAULT 0 COMMENT '剩余数量',
    `per_user_limit`   INT DEFAULT 1 COMMENT '每人限领数量',
    `start_time`       DATETIME COMMENT '领取开始时间',
    `end_time`         DATETIME COMMENT '领取结束时间',
    `status`           TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `description`      VARCHAR(500) COMMENT '使用说明',
    `scope_type`       TINYINT DEFAULT 2 COMMENT '适用范围：1全场 2指定商品 3指定分类',
    `scope_ids`        VARCHAR(500) COMMENT '适用范围ID，逗号分隔',
    `coupon_level`     TINYINT DEFAULT 2 COMMENT '优惠券层级：1平台券 2店铺券',
    `mutually_exclusive` TINYINT DEFAULT 1 COMMENT '是否互斥：0否 1是',
    `user_type`        TINYINT DEFAULT 0 COMMENT '用户类型：0全部用户 1新用户 2会员',
    `member_level`     INT COMMENT '会员等级（user_type=2时生效）',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_coupon_level` (`coupon_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='店铺优惠券模板表';

-- 用户优惠券表
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `user_id`          BIGINT NOT NULL COMMENT '用户ID',
    `template_id`      BIGINT NOT NULL COMMENT '模板ID',
    `coupon_code`      VARCHAR(50) COMMENT '优惠券码',
    `name`             VARCHAR(100) NOT NULL COMMENT '优惠券名称（快照）',
    `type`             TINYINT NOT NULL COMMENT '类型',
    `discount_amount`  DECIMAL(10,2) COMMENT '优惠金额',
    `min_amount`       DECIMAL(10,2) DEFAULT 0 COMMENT '最低使用金额',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0未使用 1已使用 2已过期',
    `receive_time`     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
    `use_time`         DATETIME COMMENT '使用时间',
    `expire_time`      DATETIME COMMENT '过期时间',
    `order_no`         VARCHAR(50) COMMENT '使用订单号',
    `lock_order_no`    VARCHAR(50) COMMENT '锁定订单号',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- ============================================================
-- 第三部分：活动/拼团/秒杀
-- ============================================================

-- 平台秒杀活动模板
DROP TABLE IF EXISTS `platform_seckill_template`;
CREATE TABLE `platform_seckill_template` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name`             VARCHAR(200) NOT NULL COMMENT '活动名称',
    `start_time`       DATETIME NOT NULL COMMENT '开始时间',
    `end_time`         DATETIME NOT NULL COMMENT '结束时间',
    `discount_rate`    DECIMAL(5,2) DEFAULT NULL COMMENT '折扣比例(如0.8表示8折)',
    `max_discount_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '最大优惠金额',
    `description`      VARCHAR(500) COMMENT '活动描述',
    `banner`           VARCHAR(255) COMMENT '活动banner',
    `status`           TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台秒杀活动模板表';

-- 商家秒杀活动参与
DROP TABLE IF EXISTS `merchant_seckill_participation`;
CREATE TABLE `merchant_seckill_participation` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '参与ID',
    `template_id`      BIGINT NOT NULL COMMENT '活动模板ID',
    `merchant_id`      BIGINT NOT NULL COMMENT '商家ID',
    `product_id`       BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`           BIGINT COMMENT 'SKU ID',
    `seckill_price`    DECIMAL(10,2) NOT NULL COMMENT '秒杀价',
    `original_price`   DECIMAL(10,2) COMMENT '原价',
    `total_stock`      INT DEFAULT 0 COMMENT '总库存',
    `available_stock`  INT DEFAULT 0 COMMENT '可用库存',
    `limit_per_user`   INT DEFAULT 1 COMMENT '每人限购数量',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已拒绝',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家秒杀参与表';

-- 秒杀订单表
DROP TABLE IF EXISTS `seckill_order`;
CREATE TABLE `seckill_order` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `seckill_id`       BIGINT NOT NULL COMMENT '秒杀参与ID',
    `user_id`          BIGINT NOT NULL COMMENT '用户ID',
    `order_id`         BIGINT COMMENT '订单ID',
    `product_id`       BIGINT NOT NULL COMMENT '商品ID',
    `quantity`         INT NOT NULL DEFAULT 1 COMMENT '数量',
    `seckill_price`    DECIMAL(10,2) NOT NULL COMMENT '秒杀价',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0待支付 1已支付 2已取消',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_seckill_id` (`seckill_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀订单表';

-- 平台拼团活动模板
DROP TABLE IF EXISTS `platform_group_template`;
CREATE TABLE `platform_group_template` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name`             VARCHAR(200) NOT NULL COMMENT '活动名称',
    `required_num`     INT NOT NULL DEFAULT 3 COMMENT '成团人数',
    `discount_rate`    DECIMAL(5,2) COMMENT '折扣比例',
    `start_time`       DATETIME NOT NULL COMMENT '开始时间',
    `end_time`         DATETIME NOT NULL COMMENT '结束时间',
    `group_duration`   INT DEFAULT 24 COMMENT '成团有效期(小时)',
    `description`      VARCHAR(500) COMMENT '活动描述',
    `banner`           VARCHAR(255) COMMENT '活动banner',
    `status`           TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台拼团活动模板表';

-- 商家拼团参与表
DROP TABLE IF EXISTS `merchant_group_participation`;
CREATE TABLE `merchant_group_participation` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '参与ID',
    `template_id`      BIGINT NOT NULL COMMENT '活动模板ID',
    `merchant_id`      BIGINT NOT NULL COMMENT '商家ID',
    `product_id`       BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`           BIGINT COMMENT 'SKU ID',
    `group_price`      DECIMAL(10,2) NOT NULL COMMENT '拼团价',
    `original_price`   DECIMAL(10,2) COMMENT '原价',
    `total_stock`      INT DEFAULT 0 COMMENT '总库存',
    `available_stock`  INT DEFAULT 0 COMMENT '可用库存',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已拒绝',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家拼团参与表';

-- 商家优惠券参与表
DROP TABLE IF EXISTS `merchant_coupon_participation`;
CREATE TABLE `merchant_coupon_participation` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '参与ID',
    `template_id`      BIGINT NOT NULL COMMENT '活动模板ID',
    `merchant_id`      BIGINT NOT NULL COMMENT '商家ID',
    `product_id`       BIGINT NOT NULL COMMENT '商品ID',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0待审核 1已通过 2已拒绝',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家优惠券参与表';

-- 团购活动表
DROP TABLE IF EXISTS `group_buy_activity`;
CREATE TABLE `group_buy_activity` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '活动ID',
    `name`             VARCHAR(200) NOT NULL COMMENT '活动名称',
    `merchant_id`      BIGINT NOT NULL COMMENT '商家ID',
    `product_id`       BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`           BIGINT COMMENT 'SKU ID',
    `group_price`      DECIMAL(10,2) NOT NULL COMMENT '拼团价',
    `original_price`   DECIMAL(10,2) COMMENT '原价',
    `required_num`     INT NOT NULL DEFAULT 3 COMMENT '成团人数',
    `total_stock`      INT DEFAULT 0 COMMENT '总库存',
    `available_stock`  INT DEFAULT 0 COMMENT '可用库存',
    `start_time`       DATETIME COMMENT '开始时间',
    `end_time`         DATETIME COMMENT '结束时间',
    `group_duration`   INT DEFAULT 24 COMMENT '成团有效期(小时)',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0未开始 1进行中 2已结束 3已取消',
    `description`      VARCHAR(500) COMMENT '活动描述',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='团购活动表';

-- 拼团团队表
DROP TABLE IF EXISTS `group_buy_team`;
CREATE TABLE `group_buy_team` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '团队ID',
    `activity_id`      BIGINT NOT NULL COMMENT '活动ID',
    `product_id`       BIGINT NOT NULL COMMENT '商品ID',
    `leader_id`        BIGINT NOT NULL COMMENT '团长用户ID',
    `group_size`       INT NOT NULL DEFAULT 3 COMMENT '成团人数',
    `current_size`     INT DEFAULT 1 COMMENT '当前人数',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0进行中 1成团成功 2成团失败',
    `expire_time`      DATETIME COMMENT '过期时间',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_activity_id` (`activity_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团团队表';

-- 拼团成员表
DROP TABLE IF EXISTS `group_buy_member`;
CREATE TABLE `group_buy_member` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '成员ID',
    `team_id`          BIGINT NOT NULL COMMENT '团队ID',
    `user_id`          BIGINT NOT NULL COMMENT '用户ID',
    `order_id`         BIGINT COMMENT '订单ID',
    `is_leader`        TINYINT DEFAULT 0 COMMENT '是否团长：0否 1是',
    `join_time`        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    `status`           TINYINT DEFAULT 0 COMMENT '状态：0待支付 1已支付 2已退出',
    INDEX `idx_team_id` (`team_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团成员表';

-- ============================================================
-- 第四部分：订单/支付/退款（人员3核心）
-- ============================================================

-- 订单主表
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
    `id`                BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    `parent_order_id`   BIGINT DEFAULT 0 COMMENT '父订单ID，0表示主订单/普通订单',
    `order_type`        TINYINT DEFAULT 1 COMMENT '订单类型：1普通订单 2拼团订单 3秒杀订单',
    `order_no`          VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    `user_id`           BIGINT NOT NULL COMMENT '用户ID',
    `merchant_id`       BIGINT NOT NULL COMMENT '商家ID',
    `total_amount`      DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '订单总金额（商品合计）',
    `freight_amount`    DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '运费',
    `discount_amount`   DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额',
    `pay_amount`        DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '实付金额',
    `coupon_id`         BIGINT COMMENT '使用的优惠券ID（user_coupon.id）',
    `coupon_ids`        VARCHAR(255) COMMENT '使用的优惠券ID列表，JSON格式如[1,2]',
    `status`            TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待支付 1已支付/待发货 2已发货 3已完成 4已取消 5退款中 6已退款 7已过期',
    `group_buy_team_id` BIGINT COMMENT '拼单团队ID',
    `group_buy_time`    DATETIME COMMENT '拼单时间',
    `address_id`        BIGINT COMMENT '收货地址ID',
    `receiver_name`     VARCHAR(50) COMMENT '收货人',
    `receiver_phone`    VARCHAR(20) COMMENT '收货人手机号',
    `receiver_address`  VARCHAR(255) COMMENT '收货地址',
    `pay_method`        TINYINT COMMENT '支付方式：1微信 2支付宝 3余额',
    `pay_trade_no`      VARCHAR(64) COMMENT '支付流水号',
    `pay_time`          DATETIME COMMENT '支付时间',
    `delivery_time`     DATETIME COMMENT '发货时间',
    `express_company`   VARCHAR(50) COMMENT '快递公司',
    `tracking_no`       VARCHAR(64) COMMENT '物流单号',
    `receive_time`      DATETIME COMMENT '确认收货时间',
    `cancel_time`       DATETIME COMMENT '取消时间',
    `cancel_reason`     VARCHAR(255) COMMENT '取消原因',
    `remark`            VARCHAR(255) COMMENT '订单备注',
    `created_at`        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_coupon_id` (`coupon_id`),
    INDEX `idx_group_buy_team_id` (`group_buy_team_id`),
    INDEX `idx_parent_order_id` (`parent_order_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- 订单明细表
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '明细ID',
    `order_id`        BIGINT NOT NULL COMMENT '订单ID',
    `product_id`      BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`          BIGINT COMMENT 'SKU ID',
    `merchant_id`     BIGINT COMMENT '商家ID',
    `product_name`    VARCHAR(200) NOT NULL COMMENT '商品名称（快照）',
    `product_image`   VARCHAR(255) COMMENT '商品图片（快照）',
    `spec_values`     VARCHAR(255) COMMENT '规格值（快照）',
    `price`           DECIMAL(10,2) NOT NULL COMMENT '单价（快照）',
    `quantity`        INT NOT NULL COMMENT '数量',
    `subtotal`        DECIMAL(10,2) NOT NULL COMMENT '小计',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- 支付记录表
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '支付ID',
    `order_id`        BIGINT NOT NULL COMMENT '订单ID',
    `order_no`        VARCHAR(50) NOT NULL COMMENT '订单号',
    `user_id`         BIGINT NOT NULL COMMENT '用户ID',
    `pay_method`      TINYINT NOT NULL COMMENT '支付方式：1微信 2支付宝 3余额',
    `pay_amount`      DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    `pay_trade_no`    VARCHAR(64) COMMENT '支付平台流水号',
    `status`          TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待支付 1支付成功 2支付失败 3已退款',
    `pay_time`        DATETIME COMMENT '支付成功时间',
    `callback_time`   DATETIME COMMENT '回调时间',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_order_id` (`order_id`),
    INDEX `idx_order_no` (`order_no`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';

-- 退款记录表
DROP TABLE IF EXISTS `refund`;
CREATE TABLE `refund` (
    `id`                    BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '退款ID',
    `refund_no`             VARCHAR(50) NOT NULL UNIQUE COMMENT '退款单号',
    `order_id`              BIGINT NOT NULL COMMENT '订单ID',
    `user_id`               BIGINT NOT NULL COMMENT '用户ID',
    `refund_amount`         DECIMAL(10,2) NOT NULL COMMENT '退款金额',
    `refund_reason`         VARCHAR(500) COMMENT '退款原因',
    `voucher_images`        VARCHAR(1000) DEFAULT NULL COMMENT '凭证图片，逗号分隔',
    `refund_type`           TINYINT NOT NULL COMMENT '类型：1仅退款 2退货退款',
    `status`                TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待审核 1待退货 2已拒绝 3已完成 4已取消 5退货中',
    `merchant_remark`       VARCHAR(500) COMMENT '商家备注/拒绝原因',
    `admin_remark`          VARCHAR(500) COMMENT '平台备注',
    `return_logistics_company` VARCHAR(100) DEFAULT NULL COMMENT '退货物流公司',
    `return_tracking_no`    VARCHAR(100) DEFAULT NULL COMMENT '退货物流单号',
    `return_ship_time`      DATETIME DEFAULT NULL COMMENT '退货发货时间',
    `return_receive_time`   DATETIME DEFAULT NULL COMMENT '商家确认收货时间',
    `apply_time`            DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    `audit_time`            DATETIME COMMENT '审核时间',
    `refund_time`           DATETIME COMMENT '退款完成时间',
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款记录表';

-- 订单物流轨迹表
DROP TABLE IF EXISTS `order_logistics_track`;
CREATE TABLE `order_logistics_track` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `order_id`        BIGINT NOT NULL COMMENT '订单ID',
    `express_company` VARCHAR(50) COMMENT '快递公司',
    `tracking_no`     VARCHAR(50) COMMENT '物流单号',
    `status`          VARCHAR(50) COMMENT '物流状态',
    `location`        VARCHAR(200) COMMENT '当前位置',
    `description`     VARCHAR(500) COMMENT '描述',
    `track_time`      DATETIME COMMENT '轨迹时间',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单物流轨迹表';

-- 订单评价表
DROP TABLE IF EXISTS `order_review`;
CREATE TABLE `order_review` (
    `id`             BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评价ID',
    `order_id`       BIGINT NOT NULL COMMENT '订单ID',
    `order_item_id`  BIGINT COMMENT '订单明细ID',
    `user_id`        BIGINT NOT NULL COMMENT '用户ID',
    `product_id`     BIGINT NOT NULL COMMENT '商品ID',
    `merchant_id`    BIGINT NOT NULL COMMENT '商家ID',
    `rating`         TINYINT NOT NULL DEFAULT 5 COMMENT '评分：1-5星',
    `content`        VARCHAR(1000) COMMENT '评价内容',
    `images`         VARCHAR(1000) COMMENT '晒图图片，逗号分隔',
    `is_anonymous`   TINYINT DEFAULT 0 COMMENT '是否匿名：0否 1是',
    `merchant_reply` VARCHAR(500) COMMENT '商家回复',
    `reply_time`     DATETIME COMMENT '回复时间',
    `status`         TINYINT DEFAULT 1 COMMENT '状态：0隐藏 1显示',
    `created_at`     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单评价表';

-- ============================================================
-- 第五部分：RBAC 权限（运营后台）
-- ============================================================

-- 管理员表
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '管理员ID',
    `username`        VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password`        VARCHAR(100) NOT NULL COMMENT '密码（BCrypt）',
    `real_name`       VARCHAR(50) COMMENT '真实姓名',
    `email`           VARCHAR(100) COMMENT '邮箱',
    `phone`           VARCHAR(20) COMMENT '手机号',
    `avatar`          VARCHAR(255) COMMENT '头像URL',
    `status`          TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `is_super`        TINYINT DEFAULT 0 COMMENT '是否超级管理员：0否 1是',
    `last_login_time` DATETIME COMMENT '最近登录时间',
    `last_login_ip`   VARCHAR(50) COMMENT '最近登录IP',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台管理员表';

-- 角色表
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    `name`        VARCHAR(50) NOT NULL COMMENT '角色名',
    `code`        VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    `description` VARCHAR(255) COMMENT '描述',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 权限（菜单）表
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    `parent_id`   BIGINT DEFAULT 0 COMMENT '父级ID，0为顶级',
    `name`        VARCHAR(50) NOT NULL COMMENT '权限名称',
    `code`        VARCHAR(100) NOT NULL COMMENT '权限编码（如 order:list）',
    `type`        TINYINT NOT NULL DEFAULT 1 COMMENT '类型：1菜单 2按钮 3接口',
    `path`        VARCHAR(255) COMMENT '前端路由路径',
    `component`   VARCHAR(255) COMMENT '前端组件路径',
    `icon`        VARCHAR(50) COMMENT '图标',
    `sort_order`  INT DEFAULT 0 COMMENT '排序号',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_parent_id` (`parent_id`),
    INDEX `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限（菜单）表';

-- 管理员-角色关联表
DROP TABLE IF EXISTS `admin_role`;
CREATE TABLE `admin_role` (
    `admin_id` BIGINT NOT NULL COMMENT '管理员ID',
    `role_id`  BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (`admin_id`, `role_id`),
    INDEX `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员-角色关联表';

-- 角色-权限关联表
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission` (
    `role_id`       BIGINT NOT NULL COMMENT '角色ID',
    `permission_id` BIGINT NOT NULL COMMENT '权限ID',
    PRIMARY KEY (`role_id`, `permission_id`),
    INDEX `idx_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色-权限关联表';

-- ============================================================
-- 第六部分：系统辅助表
-- ============================================================

-- 操作日志表
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
    `id`            BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    `module`        VARCHAR(50) COMMENT '模块：order/refund/product等',
    `operation`     VARCHAR(100) COMMENT '操作名称',
    `business_id`   BIGINT COMMENT '业务ID',
    `operator_type` TINYINT COMMENT '操作人类型：1用户 2商家 3管理员',
    `operator_id`   BIGINT COMMENT '操作人ID',
    `operator_name` VARCHAR(100) COMMENT '操作人名称',
    `ip`            VARCHAR(50) COMMENT 'IP地址',
    `request_params` TEXT COMMENT '请求参数',
    `result`        TEXT COMMENT '操作结果',
    `status`        TINYINT DEFAULT 1 COMMENT '状态：0失败 1成功',
    `error_msg`     VARCHAR(500) COMMENT '错误信息',
    `cost_time`     BIGINT COMMENT '耗时(ms)',
    `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_module` (`module`),
    INDEX `idx_business_id` (`business_id`),
    INDEX `idx_operator` (`operator_type`, `operator_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- 运费模板表
DROP TABLE IF EXISTS `freight_template`;
CREATE TABLE `freight_template` (
    `id`           BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `merchant_id`  BIGINT NOT NULL COMMENT '商家ID',
    `name`         VARCHAR(100) NOT NULL COMMENT '模板名称',
    `free_amount`  DECIMAL(10,2) DEFAULT NULL COMMENT '满多少包邮，NULL表示不包邮',
    `base_freight` DECIMAL(10,2) DEFAULT 0 COMMENT '基础运费',
    `status`       TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运费模板表';

-- 库存变动日志表
DROP TABLE IF EXISTS `stock_log`;
CREATE TABLE `stock_log` (
    `id`         BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`     BIGINT COMMENT 'SKU ID',
    `type`       TINYINT NOT NULL COMMENT '类型：1入库 2出库 3扣减 4恢复',
    `quantity`   INT NOT NULL COMMENT '变动数量',
    `before_stock` INT COMMENT '变动前库存',
    `after_stock`  INT COMMENT '变动后库存',
    `order_no`   VARCHAR(50) COMMENT '关联订单号',
    `operator`   VARCHAR(100) COMMENT '操作人',
    `remark`     VARCHAR(500) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存变动日志表';

-- 商家统计表
DROP TABLE IF EXISTS `merchant_stats`;
CREATE TABLE `merchant_stats` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `merchant_id`     BIGINT NOT NULL UNIQUE COMMENT '商家ID',
    `total_orders`    INT DEFAULT 0 COMMENT '总订单数',
    `total_sales`     DECIMAL(15,2) DEFAULT 0 COMMENT '总销售额',
    `today_orders`    INT DEFAULT 0 COMMENT '今日订单数',
    `today_sales`     DECIMAL(15,2) DEFAULT 0 COMMENT '今日销售额',
    `product_count`   INT DEFAULT 0 COMMENT '商品数量',
    `updated_at`      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家统计表';

-- ============================================================
-- 初始数据
-- ============================================================

-- 超级管理员账号（密码 123456）
INSERT INTO `admin` (`username`, `password`, `real_name`, `email`, `is_super`, `status`)
VALUES ('admin', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',
        '超级管理员', 'admin@shopping.com', 1, 1);

-- 普通运营账号（密码 123456）
INSERT INTO `admin` (`username`, `password`, `real_name`, `email`, `is_super`, `status`)
VALUES ('operator', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',
        '运营员', 'operator@shopping.com', 0, 1);

-- 角色
INSERT INTO `role` (`name`, `code`, `description`) VALUES
('超级管理员', 'SUPER_ADMIN', '拥有系统全部权限'),
('运营',       'OPERATOR',    '负责日常运营管理'),
('客服',       'CS',          '处理订单售后');

-- 菜单/权限
INSERT INTO `permission` (`id`, `parent_id`, `name`, `code`, `type`, `path`, `component`, `icon`, `sort_order`) VALUES
-- 顶级
(1,  0, '工作台',    'dashboard',   1, '/dashboard',  'Dashboard',  'DataLine',  1),
(2,  0, '订单管理',  'order',       1, '/order',      'OrderList',  'Document',  2),
(3,  0, '退款管理',  'refund',      1, '/refund',     'RefundList', 'Refund',    3),
(4,  0, '商品管理',  'product',     1, '/product',    'ProductList','Goods',     4),
(5,  0, '商家管理',  'merchant',    1, '/merchant',   'MerchantList','Shop',     5),
(6,  0, '活动配置',  'activity',    1, '/activity',   'ActivityList','Promotion',6),
(7,  0, '优惠券',    'coupon',      1, '/coupon',     'CouponList', 'Discount',  7),
(8,  0, '系统管理',  'system',      1, '/system',     'AdminList',  'Setting',   8);

-- 子菜单
INSERT INTO `permission` (`parent_id`, `name`, `code`, `type`, `path`, `component`, `icon`, `sort_order`) VALUES
(2, '订单列表',    'order:list',    1, '/order/list',    'OrderList',    '', 1),
(3, '退款列表',    'refund:list',   1, '/refund/list',   'RefundList',   '', 1),
(4, '商品列表',    'product:list',  1, '/product/list',  'ProductList',  '', 1),
(5, '商家列表',    'merchant:list', 1, '/merchant/list', 'MerchantList', '', 1),
(6, '活动列表',    'activity:list', 1, '/activity/list', 'ActivityList', '', 1),
(7, '优惠券列表',  'coupon:list',   1, '/coupon/list',   'CouponList',   '', 1),
(8, '管理员管理',  'admin:list',    1, '/system/admin',  'AdminList',    '', 1),
(8, '角色管理',    'role:list',     1, '/system/role',   'RoleList',     '', 2),
(8, '权限管理',    'permission:list',1,'/system/permission','PermissionList','', 3);

-- 管理员-角色关联
INSERT INTO `admin_role` (`admin_id`, `role_id`) VALUES (1, 1), (2, 2);

-- 默认运费模板
INSERT INTO `freight_template` (`merchant_id`, `name`, `free_amount`, `base_freight`, `status`) VALUES
(1, '默认运费模板', 99.00, 8.00, 1),
(2, '默认运费模板', 99.00, 10.00, 1);

-- ============================================================
-- 完成！
-- ============================================================
SET FOREIGN_KEY_CHECKS = 1;
SELECT '数据库初始化完成！共 35 张表。' AS result;
