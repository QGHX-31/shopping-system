CREATE DATABASE IF NOT EXISTS shopping_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE shopping_system;

CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `email` VARCHAR(100) UNIQUE COMMENT '邮箱',
    `phone` VARCHAR(20) UNIQUE COMMENT '手机号',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `avatar` VARCHAR(255) COMMENT '头像URL',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`),
    INDEX `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE IF NOT EXISTS `member` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '会员ID',
    `user_id` BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    `member_level` TINYINT DEFAULT 1 COMMENT '会员等级：1普通会员，2银卡会员，3金卡会员，4钻石会员',
    `total_points` INT DEFAULT 0 COMMENT '总积分',
    `available_points` INT DEFAULT 0 COMMENT '可用积分',
    `member_since` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '成为会员时间',
    `expire_time` DATETIME COMMENT '会员到期时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT `fk_member_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_member_level` (`member_level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员表';

CREATE TABLE IF NOT EXISTS `points_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '积分记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `points` INT NOT NULL COMMENT '积分变动数量',
    `type` TINYINT COMMENT '类型：1获取，2消费，3过期',
    `source` VARCHAR(100) COMMENT '来源描述',
    `order_no` VARCHAR(50) COMMENT '关联订单号',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT `fk_points_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分记录表';

CREATE TABLE IF NOT EXISTS `message` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `title` VARCHAR(100) NOT NULL COMMENT '消息标题',
    `content` TEXT COMMENT '消息内容',
    `type` TINYINT DEFAULT 1 COMMENT '类型：1系统消息，2订单消息，3促销消息',
    `is_read` TINYINT DEFAULT 0 COMMENT '是否已读：0未读，1已读',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT `fk_message_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_is_read` (`is_read`),
    INDEX `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

CREATE TABLE IF NOT EXISTS `category` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '分类ID',
    `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父分类ID',
    `sort_order` INT DEFAULT 0 COMMENT '排序号',
    `icon` VARCHAR(255) COMMENT '图标URL',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_parent_id` (`parent_id`),
    INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类表';

CREATE TABLE IF NOT EXISTS `product` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商品ID',
    `name` VARCHAR(200) NOT NULL COMMENT '商品名称',
    `category_id` BIGINT NOT NULL COMMENT '分类ID',
    `brand` VARCHAR(50) COMMENT '品牌',
    `price` DECIMAL(10,2) NOT NULL COMMENT '价格',
    `original_price` DECIMAL(10,2) COMMENT '原价',
    `stock` INT DEFAULT 0 COMMENT '库存',
    `sales_count` INT DEFAULT 0 COMMENT '销量',
    `description` TEXT COMMENT '商品描述',
    `image_url` VARCHAR(255) COMMENT '主图URL',
    `detail_images` TEXT COMMENT '详情图片JSON',
    `is_hot` TINYINT DEFAULT 0 COMMENT '是否热门：0否，1是',
    `is_new` TINYINT DEFAULT 0 COMMENT '是否新品：0否，1是',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0下架，1上架',
    `merchant_id` BIGINT COMMENT '商家ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `category`(`id`) ON DELETE CASCADE,
    INDEX `idx_category_id` (`category_id`),
    INDEX `idx_is_hot` (`is_hot`),
    INDEX `idx_is_new` (`is_new`),
    INDEX `idx_sales_count` (`sales_count`),
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品表';

CREATE TABLE IF NOT EXISTS `cart` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '购物车ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `selected` TINYINT DEFAULT 1 COMMENT '是否选中：0否，1是',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
    UNIQUE INDEX `idx_user_product` (`user_id`, `product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='购物车表';

CREATE TABLE IF NOT EXISTS `favorite` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '收藏ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_favorite_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
    UNIQUE INDEX `idx_user_product` (`user_id`, `product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

CREATE TABLE IF NOT EXISTS `address` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '地址ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `name` VARCHAR(50) NOT NULL COMMENT '收货人姓名',
    `phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `province` VARCHAR(50) COMMENT '省份',
    `city` VARCHAR(50) COMMENT '城市',
    `district` VARCHAR(50) COMMENT '区县',
    `detail` VARCHAR(200) COMMENT '详细地址',
    `is_default` TINYINT DEFAULT 0 COMMENT '是否默认：0否，1是',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT `fk_address_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_is_default` (`is_default`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收货地址表';

INSERT INTO category (id, name, parent_id, sort_order, icon, status, created_at, updated_at) VALUES
(1, '电子产品', 0, 1, '📱', 1, NOW(), NOW()),
(2, '服装鞋包', 0, 2, '👕', 1, NOW(), NOW()),
(3, '手机', 1, 1, '📱', 1, NOW(), NOW()),
(4, '电脑', 1, 2, '💻', 1, NOW(), NOW()),
(5, '男装', 2, 1, '👔', 1, NOW(), NOW());

INSERT INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(1, 'iPhone 15 Pro', 3, 'Apple', 7999.00, 8999.00, 100, 50, 'Apple iPhone 15 Pro 256GB 钛原色', 'https://picsum.photos/400/400?random=1', '[]', 1, 1, 1, 1, NOW(), NOW()),
(2, '华为 Mate 60 Pro', 3, '华为', 6999.00, 7999.00, 200, 100, '华为Mate60 Pro+ 1TB 砚黑色', 'https://picsum.photos/400/400?random=2', '[]', 1, 1, 1, 1, NOW(), NOW()),
(3, 'MacBook Pro M3', 4, 'Apple', 14999.00, 15999.00, 50, 20, 'Apple MacBook Pro 14英寸 M3 芯片', 'https://picsum.photos/400/400?random=3', '[]', 1, 0, 1, 1, NOW(), NOW()),
(4, '小米14 Ultra', 3, '小米', 6499.00, 6999.00, 150, 80, '小米14 Ultra 徕卡光学', 'https://picsum.photos/400/400?random=4', '[]', 1, 1, 1, 1, NOW(), NOW()),
(5, '戴尔 XPS 15', 4, '戴尔', 12999.00, 13999.00, 30, 10, '戴尔XPS15 9530 15.6英寸', 'https://picsum.photos/400/400?random=5', '[]', 0, 1, 1, 1, NOW(), NOW()),
(6, '男士休闲夹克', 5, 'UNIQLO', 299.00, 599.00, 500, 200, '春季新款男士休闲夹克外套', 'https://picsum.photos/400/400?random=6', '[]', 0, 1, 1, 2, NOW(), NOW()),
(7, 'iPad Pro 11', 4, 'Apple', 6799.00, 6999.00, 80, 30, 'iPad Pro 11英寸 2024款', 'https://picsum.photos/400/400?random=7', '[]', 1, 1, 1, 1, NOW(), NOW()),
(8, 'AirPods Pro 2', 3, 'Apple', 1899.00, 1999.00, 300, 150, 'Apple AirPods Pro 2 主动降噪', 'https://picsum.photos/400/400?random=8', '[]', 1, 0, 1, 1, NOW(), NOW());

-- 初始用户数据（user01/user02 密码：123456；test001 密码：test001）
INSERT INTO `user` (id, username, password, email, phone, nickname, status, created_at, updated_at) VALUES
(1, 'user01', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'user01@example.com', '13800000001', '用户小王', 1, NOW(), NOW()),
(2, 'user02', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'user02@example.com', '13800000002', '用户小李', 1, NOW(), NOW()),
(3, 'test001', '$2a$10$mBv0Wuy4VEA8FunOaZ.AQ.REoYAF2gu0fPXbQtfFXH3l7exa1eaMu', 'test001@example.com', '13800000003', '测试用户', 1, NOW(), NOW());

-- ============================================================
-- 阶段2：商家模块相关表（人员2）
-- ============================================================

-- 商家表
CREATE TABLE IF NOT EXISTS `merchant` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '商家ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '商家账号',
    `password` VARCHAR(100) NOT NULL COMMENT '密码(加密)',
    `shop_name` VARCHAR(100) NOT NULL COMMENT '店铺名称',
    `logo` VARCHAR(255) COMMENT '店铺Logo',
    `contact_name` VARCHAR(50) COMMENT '联系人姓名',
    `contact_phone` VARCHAR(20) COMMENT '联系电话',
    `email` VARCHAR(100) COMMENT '邮箱',
    `address` VARCHAR(255) COMMENT '商家地址',
    `business_license` VARCHAR(100) COMMENT '营业执照号',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用，2待审核',
    `level` TINYINT DEFAULT 1 COMMENT '商家等级：1普通，2银牌，3金牌，4钻石',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`),
    INDEX `idx_status` (`status`),
    INDEX `idx_shop_name` (`shop_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家表';

-- SKU库存表（多规格）
CREATE TABLE IF NOT EXISTS `product_sku` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'SKU ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `sku_code` VARCHAR(100) COMMENT 'SKU编码',
    `spec_values` VARCHAR(500) COMMENT '规格值JSON：[{name:"颜色",value:"红色"}]',
    `price` DECIMAL(10,2) NOT NULL COMMENT '销售价',
    `original_price` DECIMAL(10,2) COMMENT '原价',
    `stock` INT DEFAULT 0 COMMENT '库存',
    `locked_stock` INT DEFAULT 0 COMMENT '预占库存',
    `sales_count` INT DEFAULT 0 COMMENT '销量',
    `weight` DECIMAL(10,2) COMMENT '重量(kg)',
    `image` VARCHAR(255) COMMENT 'SKU图片',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_sku_product` FOREIGN KEY (`product_id`) REFERENCES `product`(`id`) ON DELETE CASCADE,
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_sku_code` (`sku_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU表';

-- 库存流水表
CREATE TABLE IF NOT EXISTS `stock_log` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '流水ID',
    `sku_id` BIGINT NOT NULL COMMENT 'SKU ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `merchant_id` BIGINT COMMENT '商家ID',
    `type` TINYINT NOT NULL COMMENT '类型：1入库，2出库，3锁定，4解锁，5扣减',
    `quantity` INT NOT NULL COMMENT '数量',
    `before_stock` INT NOT NULL COMMENT '操作前库存',
    `after_stock` INT NOT NULL COMMENT '操作后库存',
    `ref_no` VARCHAR(50) COMMENT '关联单号（订单/活动）',
    `remark` VARCHAR(255) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_sku_id` (`sku_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_type` (`type`),
    INDEX `idx_ref_no` (`ref_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存流水表';

-- 秒杀活动表
CREATE TABLE IF NOT EXISTS `seckill_activity` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '活动ID',
    `name` VARCHAR(200) NOT NULL COMMENT '活动名称',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0未开始，1进行中，2已结束，3已取消',
    `description` VARCHAR(500) COMMENT '活动描述',
    `banner` VARCHAR(255) COMMENT '活动banner',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀活动表';

-- 秒杀商品表
CREATE TABLE IF NOT EXISTS `seckill_product` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `activity_id` BIGINT NOT NULL COMMENT '活动ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id` BIGINT COMMENT 'SKU ID（NULL代表商品级秒杀）',
    `seckill_price` DECIMAL(10,2) NOT NULL COMMENT '秒杀价',
    `original_price` DECIMAL(10,2) NOT NULL COMMENT '原价',
    `total_stock` INT NOT NULL DEFAULT 0 COMMENT '秒杀总库存',
    `available_stock` INT NOT NULL DEFAULT 0 COMMENT '剩余库存',
    `limit_per_user` INT DEFAULT 1 COMMENT '每人限购数量',
    `sales_count` INT DEFAULT 0 COMMENT '已售数量',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_sp_activity` FOREIGN KEY (`activity_id`) REFERENCES `seckill_activity`(`id`) ON DELETE CASCADE,
    INDEX `idx_activity_id` (`activity_id`),
    INDEX `idx_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀商品表';

-- 秒杀订单表
CREATE TABLE IF NOT EXISTS `seckill_order` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    `order_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `activity_id` BIGINT NOT NULL COMMENT '活动ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id` BIGINT COMMENT 'SKU ID',
    `quantity` INT NOT NULL DEFAULT 1 COMMENT '数量',
    `seckill_price` DECIMAL(10,2) NOT NULL COMMENT '秒杀价',
    `total_amount` DECIMAL(10,2) NOT NULL COMMENT '订单总金额',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0待支付，1已支付，2已取消，3已退款',
    `pay_time` DATETIME COMMENT '支付时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_activity_id` (`activity_id`),
    INDEX `idx_order_no` (`order_no`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='秒杀订单表';

-- 拼团活动表
CREATE TABLE IF NOT EXISTS `group_buy_activity` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '活动ID',
    `name` VARCHAR(200) NOT NULL COMMENT '活动名称',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id` BIGINT COMMENT 'SKU ID',
    `group_price` DECIMAL(10,2) NOT NULL COMMENT '拼团价',
    `original_price` DECIMAL(10,2) NOT NULL COMMENT '原价',
    `required_num` INT NOT NULL DEFAULT 3 COMMENT '成团人数',
    `total_stock` INT NOT NULL DEFAULT 0 COMMENT '活动总库存',
    `available_stock` INT NOT NULL DEFAULT 0 COMMENT '剩余库存',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `group_duration` INT DEFAULT 24 COMMENT '成团时长(小时)',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `description` VARCHAR(500) COMMENT '活动描述',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团活动表';

-- 拼团团队表
CREATE TABLE IF NOT EXISTS `group_buy_team` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '团ID',
    `team_no` VARCHAR(50) NOT NULL UNIQUE COMMENT '团编号',
    `activity_id` BIGINT NOT NULL COMMENT '活动ID',
    `leader_id` BIGINT NOT NULL COMMENT '团长用户ID',
    `required_num` INT NOT NULL COMMENT '需要人数',
    `current_num` INT DEFAULT 1 COMMENT '当前人数',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0拼团中，1已成团，2已失败',
    `expire_time` DATETIME NOT NULL COMMENT '过期时间',
    `success_time` DATETIME COMMENT '成团时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_activity_id` (`activity_id`),
    INDEX `idx_leader_id` (`leader_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团团队表';

-- 拼团成员表
CREATE TABLE IF NOT EXISTS `group_buy_member` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `team_id` BIGINT NOT NULL COMMENT '团ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `order_no` VARCHAR(50) COMMENT '订单号',
    `is_leader` TINYINT DEFAULT 0 COMMENT '是否团长：0否，1是',
    `join_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_team_id` (`team_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='拼团成员表';

-- 优惠券模板表
CREATE TABLE IF NOT EXISTS `coupon_template` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `merchant_id` BIGINT COMMENT '商家ID（NULL为平台券）',
    `type` TINYINT NOT NULL COMMENT '类型：1满减，2折扣，3固定金额',
    `discount_amount` DECIMAL(10,2) COMMENT '优惠金额/折扣值',
    `min_amount` DECIMAL(10,2) DEFAULT 0 COMMENT '最低消费金额',
    `total_count` INT NOT NULL DEFAULT 0 COMMENT '发行总量',
    `remaining_count` INT NOT NULL DEFAULT 0 COMMENT '剩余数量',
    `per_user_limit` INT DEFAULT 1 COMMENT '每人限领数量',
    `start_time` DATETIME NOT NULL COMMENT '生效时间',
    `end_time` DATETIME NOT NULL COMMENT '过期时间',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `description` VARCHAR(500) COMMENT '使用说明',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`),
    INDEX `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券模板表';

-- 用户优惠券表
CREATE TABLE IF NOT EXISTS `user_coupon` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `template_id` BIGINT NOT NULL COMMENT '券模板ID',
    `coupon_code` VARCHAR(50) NOT NULL UNIQUE COMMENT '券码',
    `name` VARCHAR(100) COMMENT '券名称（冗余）',
    `type` TINYINT COMMENT '类型（冗余）',
    `discount_amount` DECIMAL(10,2) COMMENT '优惠金额',
    `min_amount` DECIMAL(10,2) DEFAULT 0 COMMENT '最低消费',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0未使用，1已使用，2已过期',
    `receive_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
    `use_time` DATETIME COMMENT '使用时间',
    `expire_time` DATETIME NOT NULL COMMENT '过期时间',
    `order_no` VARCHAR(50) COMMENT '使用订单号',
    `lock_order_no` VARCHAR(50) COMMENT '锁定订单号（未支付时占用）',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_coupon_code` (`coupon_code`),
    INDEX `idx_status` (`status`),
    INDEX `idx_expire_time` (`expire_time`),
    INDEX `idx_lock_order_no` (`lock_order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

-- 商家数据看板（每日统计）
CREATE TABLE IF NOT EXISTS `merchant_stats` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `order_count` INT DEFAULT 0 COMMENT '订单数',
    `order_amount` DECIMAL(12,2) DEFAULT 0 COMMENT '订单总金额',
    `product_views` INT DEFAULT 0 COMMENT '商品浏览量',
    `product_sales` INT DEFAULT 0 COMMENT '商品销量',
    `new_customers` INT DEFAULT 0 COMMENT '新增客户数',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX `idx_merchant_date` (`merchant_id`, `stat_date`),
    INDEX `idx_stat_date` (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家每日统计表';

-- MQ消息日志（用于MQ可靠投递追踪）
CREATE TABLE IF NOT EXISTS `mq_message_log` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `message_id` VARCHAR(64) NOT NULL UNIQUE COMMENT '消息唯一ID',
    `topic` VARCHAR(100) NOT NULL COMMENT '主题',
    `tags` VARCHAR(100) COMMENT '标签',
    `business_key` VARCHAR(100) COMMENT '业务键',
    `content` TEXT COMMENT '消息内容JSON',
    `status` TINYINT DEFAULT 0 COMMENT '状态：0待发送，1已发送，2消费成功，3消费失败',
    `retry_count` INT DEFAULT 0 COMMENT '重试次数',
    `error_msg` VARCHAR(500) COMMENT '错误信息',
    `send_time` DATETIME COMMENT '发送时间',
    `consume_time` DATETIME COMMENT '消费时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_topic` (`topic`),
    INDEX `idx_business_key` (`business_key`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='MQ消息日志表';

-- 初始商家数据（密码为 123456 的 BCrypt 哈希，BCryptPasswordEncoder.strength=10 生成）
INSERT INTO merchant (id, username, password, shop_name, contact_name, contact_phone, status, level, created_at, updated_at) VALUES
(1, 'merchant01', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'Apple官方旗舰店', '张三', '13800001111', 1, 4, NOW(), NOW()),
(2, 'merchant02', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '优衣库官方旗舰店', '李四', '13800002222', 1, 3, NOW(), NOW());

-- 初始SKU数据
INSERT INTO product_sku (product_id, merchant_id, sku_code, spec_values, price, original_price, stock, sales_count, status, created_at, updated_at) VALUES
(1, 1, 'IP15P-256-TI', '[{"name":"容量","value":"256GB"},{"name":"颜色","value":"钛原色"}]', 7999.00, 8999.00, 50, 30, 1, NOW(), NOW()),
(1, 1, 'IP15P-512-TI', '[{"name":"容量","value":"512GB"},{"name":"颜色","value":"钛原色"}]', 8999.00, 9999.00, 30, 10, 1, NOW(), NOW()),
(2, 1, 'MATE60-1T-BLK', '[{"name":"容量","value":"1TB"},{"name":"颜色","value":"砚黑色"}]', 6999.00, 7999.00, 100, 50, 1, NOW(), NOW()),
(6, 2, 'JKT-M-BLK-L', '[{"name":"尺码","value":"L"},{"name":"颜色","value":"黑色"}]', 299.00, 599.00, 200, 100, 1, NOW(), NOW());

-- 初始秒杀活动
INSERT INTO seckill_activity (id, name, merchant_id, start_time, end_time, status, description, created_at, updated_at) VALUES
(1, 'iPhone 15 Pro 限时秒杀', 1, DATE_SUB(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 23 HOUR), 1, 'iPhone 15 Pro 256GB 限时直降1000元', NOW(), NOW());

INSERT INTO seckill_product (activity_id, product_id, sku_id, seckill_price, original_price, total_stock, available_stock, limit_per_user, sales_count, created_at, updated_at) VALUES
(1, 1, 1, 6999.00, 7999.00, 100, 100, 1, 0, NOW(), NOW());

-- 初始拼团活动
INSERT INTO group_buy_activity (name, merchant_id, product_id, sku_id, group_price, original_price, required_num, total_stock, available_stock, start_time, end_time, group_duration, status, description, created_at, updated_at) VALUES
('华为Mate60 Pro 3人成团', 1, 2, 3, 5999.00, 6999.00, 3, 500, 500, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 24, 1, '3人成团享优惠', NOW(), NOW());

-- 初始优惠券模板
INSERT INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, created_at, updated_at) VALUES
('新人专享50元券', NULL, 1, 50.00, 200.00, 10000, 10000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '满200减50', NOW(), NOW()),
('Apple旗舰店满1000减100', 1, 1, 100.00, 1000.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '满1000减100', NOW(), NOW()),
('全场9折优惠券', NULL, 2, 0.90, 0.00, 10000, 10000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '全场9折优惠', NOW(), NOW());

-- 初始商家统计数据
INSERT INTO merchant_stats (merchant_id, stat_date, order_count, order_amount, product_views, product_sales, new_customers, created_at, updated_at) VALUES
(1, CURDATE(), 25, 187500.00, 1200, 30, 8, NOW(), NOW()),
(1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 32, 245600.00, 1450, 38, 12, NOW(), NOW()),
(1, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 28, 198700.00, 1320, 33, 9, NOW(), NOW()),
(2, CURDATE(), 18, 5680.00, 850, 50, 5, NOW(), NOW()),
(2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 22, 6920.00, 920, 62, 7, NOW(), NOW()),
(2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 19, 5980.00, 880, 55, 6, NOW(), NOW());