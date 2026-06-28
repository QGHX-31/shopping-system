-- ============================================================
-- 平台活动模板表（管理员创建活动模板）
-- ============================================================

-- 平台秒杀活动模板
CREATE TABLE IF NOT EXISTS `platform_seckill_template` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name` VARCHAR(200) NOT NULL COMMENT '活动名称',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `discount_rate` DECIMAL(5,2) DEFAULT NULL COMMENT '折扣比例(如0.8表示8折)',
    `max_discount_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '最大优惠金额',
    `description` VARCHAR(500) COMMENT '活动描述',
    `banner` VARCHAR(255) COMMENT '活动banner',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`),
    INDEX `idx_end_time` (`end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台秒杀活动模板表';

-- 平台优惠券模板（平台级）
CREATE TABLE IF NOT EXISTS `platform_coupon_template` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `type` TINYINT NOT NULL COMMENT '类型：1满减，2折扣',
    `discount_amount` DECIMAL(10,2) NOT NULL COMMENT '优惠金额',
    `min_amount` DECIMAL(10,2) DEFAULT 0 COMMENT '最低消费金额',
    `total_count` INT NOT NULL DEFAULT 0 COMMENT '发行总量',
    `remaining_count` INT NOT NULL DEFAULT 0 COMMENT '剩余数量',
    `per_user_limit` INT DEFAULT 1 COMMENT '每人限领数量',
    `start_time` DATETIME NOT NULL COMMENT '生效时间',
    `end_time` DATETIME NOT NULL COMMENT '过期时间',
    `description` VARCHAR(500) COMMENT '使用说明',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_type` (`type`),
    INDEX `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台优惠券模板表';

-- 平台拼团活动模板
CREATE TABLE IF NOT EXISTS `platform_group_template` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `name` VARCHAR(200) NOT NULL COMMENT '活动名称',
    `required_num` INT NOT NULL DEFAULT 3 COMMENT '成团人数',
    `discount_rate` DECIMAL(5,2) DEFAULT 0.85 COMMENT '拼团折扣比例',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `group_duration` INT DEFAULT 24 COMMENT '成团时长(小时)',
    `description` VARCHAR(500) COMMENT '活动描述',
    `banner` VARCHAR(255) COMMENT '活动banner',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台拼团活动模板表';

-- ============================================================
-- 商家报名表（商家选择商品参加平台活动）
-- ============================================================

-- 商家秒杀报名
CREATE TABLE IF NOT EXISTS `merchant_seckill_participation` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报名ID',
    `template_id` BIGINT NOT NULL COMMENT '秒杀模板ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id` BIGINT COMMENT 'SKU ID',
    `seckill_price` DECIMAL(10,2) NOT NULL COMMENT '秒杀价',
    `original_price` DECIMAL(10,2) NOT NULL COMMENT '原价',
    `total_stock` INT NOT NULL DEFAULT 0 COMMENT '秒杀库存',
    `available_stock` INT NOT NULL DEFAULT 0 COMMENT '剩余库存',
    `limit_per_user` INT DEFAULT 1 COMMENT '每人限购',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0拒绝，1待审核，2已通过',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家秒杀报名表';

-- 商家优惠券报名（商家选择哪些商品可用该优惠券）
CREATE TABLE IF NOT EXISTS `merchant_coupon_participation` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报名ID',
    `template_id` BIGINT NOT NULL COMMENT '优惠券模板ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `product_id` BIGINT DEFAULT NULL COMMENT '商品ID（NULL表示全店可用）',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0拒绝，1待审核，2已通过',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家优惠券报名表';

-- 商家拼团报名
CREATE TABLE IF NOT EXISTS `merchant_group_participation` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '报名ID',
    `template_id` BIGINT NOT NULL COMMENT '拼团模板ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `product_id` BIGINT NOT NULL COMMENT '商品ID',
    `sku_id` BIGINT COMMENT 'SKU ID',
    `group_price` DECIMAL(10,2) NOT NULL COMMENT '拼团价',
    `original_price` DECIMAL(10,2) NOT NULL COMMENT '原价',
    `total_stock` INT NOT NULL DEFAULT 0 COMMENT '拼团库存',
    `available_stock` INT NOT NULL DEFAULT 0 COMMENT '剩余库存',
    `status` TINYINT DEFAULT 1 COMMENT '状态：0拒绝，1待审核，2已通过',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_template_id` (`template_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商家拼团报名表';

-- ============================================================
-- 示例活动数据（管理员创建）
-- ============================================================

-- 平台秒杀活动模板示例
INSERT INTO platform_seckill_template (name, start_time, end_time, discount_rate, max_discount_amount, description, status, created_at, updated_at) VALUES
('618年中大促秒杀', DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY), 0.70, 500.00, '618年中大促，精选商品限时秒杀，最高优惠500元', 1, NOW(), NOW()),
('每日10点秒杀', DATE_ADD(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 30 DAY), 0.80, 300.00, '每天10点准时开抢，限时秒杀不容错过', 1, NOW(), NOW()),
('新品首发秒杀', DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 7 DAY), 0.75, 200.00, '新品首发限时秒杀，抢先体验新品', 1, NOW(), NOW());

-- 平台优惠券模板示例
INSERT INTO platform_coupon_template (name, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, description, status, created_at, updated_at) VALUES
('满300减30优惠券', 1, 30.00, 300.00, 10000, 10000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), '全场满300元减30元，每人限领2张', 1, NOW(), NOW()),
('满500减50优惠券', 1, 50.00, 500.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), '全场满500元减50元，每人限领1张', 1, NOW(), NOW()),
('满1000减100优惠券', 1, 100.00, 1000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), '全场满1000元减100元，每人限领1张', 1, NOW(), NOW()),
('新人专享50元券', 1, 50.00, 200.00, 50000, 50000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 90 DAY), '新用户专享，满200减50', 1, NOW(), NOW()),
('全场9折优惠券', 2, 0.10, 100.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), '全场9折优惠，满100元可用', 1, NOW(), NOW()),
('VIP专属8折券', 2, 0.20, 500.00, 1000, 1000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'VIP会员专属8折券，满500可用', 1, NOW(), NOW());

-- 平台拼团活动模板示例
INSERT INTO platform_group_template (name, required_num, discount_rate, start_time, end_time, group_duration, description, status, created_at, updated_at) VALUES
('3人成团享优惠', 3, 0.85, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 24, '3人成团即可享受85折优惠', 1, NOW(), NOW()),
('5人超值拼团', 5, 0.75, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 48, '5人成团享受75折超值优惠', 1, NOW(), NOW()),
('2人情侣拼团', 2, 0.90, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 12, '2人成团享受9折优惠，情侣专属', 1, NOW(), NOW());

-- ============================================================
-- 示例商家报名数据（商家选择商品参加活动）
-- ============================================================

-- 商家秒杀报名示例
INSERT INTO merchant_seckill_participation (template_id, merchant_id, product_id, sku_id, seckill_price, original_price, total_stock, available_stock, limit_per_user, status, created_at, updated_at) VALUES
(1, 1, 1, 1, 5599.00, 7999.00, 50, 50, 1, 2, NOW(), NOW()),  -- iPhone 15 Pro 参加618秒杀
(1, 1, 3, NULL, 10499.00, 14999.00, 20, 20, 1, 2, NOW(), NOW()),  -- MacBook Pro 参加618秒杀
(2, 1, 8, NULL, 1519.00, 1899.00, 100, 100, 2, 2, NOW(), NOW()),  -- AirPods Pro 2 参加每日秒杀
(3, 1, 7, NULL, 5099.00, 6799.00, 30, 30, 1, 2, NOW(), NOW());  -- iPad Pro 参加新品秒杀

-- 商家优惠券报名示例（商家选择哪些商品可用优惠券）
INSERT INTO merchant_coupon_participation (template_id, merchant_id, product_id, status, created_at, updated_at) VALUES
(1, 1, NULL, 2, NOW(), NOW()),  -- 商家1全店可用满300减30
(2, 1, NULL, 2, NOW(), NOW()),  -- 商家1全店可用满500减50
(3, 1, 1, 2, NOW(), NOW()),    -- 商家1的iPhone可用满1000减100
(3, 1, 3, 2, NOW(), NOW()),    -- 商家1的MacBook可用满1000减100
(1, 2, 6, 2, NOW(), NOW()),    -- 商家2的夹克可用满300减30
(5, 1, NULL, 2, NOW(), NOW()), -- 商家1全店可用9折券
(6, 1, 1, 2, NOW(), NOW()),    -- 商家1的iPhone可用VIP8折券
(6, 1, 3, 2, NOW(), NOW());    -- 商家1的MacBook可用VIP8折券

-- 商家拼团报名示例
INSERT INTO merchant_group_participation (template_id, merchant_id, product_id, sku_id, group_price, original_price, total_stock, available_stock, status, created_at, updated_at) VALUES
(1, 1, 2, 3, 5949.00, 6999.00, 100, 100, 2, NOW(), NOW()),  -- 华为Mate60 参加3人拼团
(1, 1, 8, NULL, 1614.00, 1899.00, 200, 200, 2, NOW(), NOW()),  -- AirPods 参加3人拼团
(2, 1, 1, 1, 5999.00, 7999.00, 30, 30, 2, NOW(), NOW()),  -- iPhone 参加5人拼团
(2, 1, 3, NULL, 11249.00, 14999.00, 15, 15, 2, NOW(), NOW()),  -- MacBook 参加5人拼团
(3, 2, 6, NULL, 269.00, 299.00, 500, 500, 2, NOW(), NOW());  -- 夹克参加2人拼团