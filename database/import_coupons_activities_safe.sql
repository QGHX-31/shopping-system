-- ============================================================
-- 优惠券和活动数据导入脚本（安全版）
-- ⚠️ 重要：本脚本使用 INSERT IGNORE，不会删除任何现有数据！
-- 执行顺序：先执行商家和商品数据，再执行本文件
-- ============================================================

USE shopping_system;

-- ============================================================
-- 一、平台优惠券（platform_coupon_template）
-- ============================================================

INSERT IGNORE INTO platform_coupon_template (id, name, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, description, status, created_at, updated_at) VALUES
(1, '满300减30优惠券', 1, 30.00, 300.00, 10000, 10000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), '全场满300元减30元，每人限领2张', 1, NOW(), NOW()),
(2, '满500减50优惠券', 1, 50.00, 500.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), '全场满500元减50元，每人限领1张', 1, NOW(), NOW()),
(3, '满1000减100优惠券', 1, 100.00, 1000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), '全场满1000元减100元，每人限领1张', 1, NOW(), NOW()),
(4, '新人专享50元券', 1, 50.00, 200.00, 50000, 50000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 90 DAY), '新用户专享，满200减50', 1, NOW(), NOW()),
(5, '全场9折优惠券', 2, 0.10, 100.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 15 DAY), '全场9折优惠，满100元可用', 1, NOW(), NOW()),
(6, 'VIP专属8折券', 2, 0.20, 500.00, 1000, 1000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 'VIP会员专属8折券，满500可用', 1, NOW(), NOW());

-- ============================================================
-- 二、店铺优惠券（coupon_template）
-- ============================================================

-- Apple店铺券 (merchant_id=1)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(1, 'Apple满500减50', 1, 1, 50.00, 500.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 'Apple官方旗舰店全店满500减50', 2, 2, 1, 0, NOW(), NOW()),
(2, 'Apple满3000减300', 1, 1, 300.00, 3000.00, 1000, 1000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 'Apple官方旗舰店满3000减300', 2, 2, 1, 0, NOW(), NOW()),
(3, 'iPhone专属500券', 1, 1, 500.00, 5000.00, 800, 800, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '仅iPhone系列手机可用', 3, 3, 1, 0, NOW(), NOW());

-- 优衣库店铺券 (merchant_id=2)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(4, '优衣库满199减20', 2, 1, 20.00, 199.00, 5000, 5000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '优衣库全店满199减20', 2, 2, 1, 0, NOW(), NOW()),
(5, '优衣库满399减50', 2, 1, 50.00, 399.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '优衣库全店满399减50', 2, 2, 1, 0, NOW(), NOW()),
(6, '新人首单立减15', 2, 1, 15.00, 99.00, 10000, 10000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1, '优衣库新用户首单立减15', 2, 2, 1, 1, NOW(), NOW());

-- 华为店铺券 (merchant_id=3)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(7, '华为满1000减100', 3, 1, 100.00, 1000.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '华为旗舰店满1000减100', 2, 2, 1, 0, NOW(), NOW()),
(8, '华为满3000减300', 3, 1, 300.00, 3000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '华为旗舰店满3000减300', 2, 2, 1, 0, NOW(), NOW()),
(9, 'Mate系列专属券', 3, 1, 200.00, 4000.00, 1500, 1500, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '仅Mate系列手机可用', 3, 3, 1, 0, NOW(), NOW());

-- 小米店铺券 (merchant_id=4)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(10, '小米满500减50', 4, 1, 50.00, 500.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '小米官方旗舰店全店满500减50', 2, 2, 1, 0, NOW(), NOW()),
(11, '小米满2000减200', 4, 1, 200.00, 2000.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '小米官方旗舰店全店满2000减200', 2, 2, 1, 0, NOW(), NOW()),
(12, '小米14系列专属300券', 4, 1, 300.00, 5000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '仅小米14系列手机可用', 3, 3, 1, 0, NOW(), NOW());

-- 名创优品店铺券 (merchant_id=5)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(13, '名创优品满59减10', 5, 1, 10.00, 59.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '名创优品全店满59减10', 2, 2, 1, 0, NOW(), NOW()),
(14, '名创优品满99减20', 5, 1, 20.00, 99.00, 8000, 8000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '名创优品全店满99减20', 2, 2, 1, 0, NOW(), NOW());

-- 三只松鼠店铺券 (merchant_id=6)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(15, '三只松鼠满69减10', 6, 1, 10.00, 69.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '三只松鼠全店满69减10', 2, 2, 1, 0, NOW(), NOW()),
(16, '三只松鼠满129减25', 6, 1, 25.00, 129.00, 6000, 6000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '三只松鼠全店满129减25', 2, 2, 1, 0, NOW(), NOW());

-- 完美日记店铺券 (merchant_id=7)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(17, '完美日记满99减15', 7, 1, 15.00, 99.00, 8000, 8000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '完美日记全店满99减15', 2, 2, 1, 0, NOW(), NOW()),
(18, '完美日记满199减40', 7, 1, 40.00, 199.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '完美日记全店满199减40', 2, 2, 1, 0, NOW(), NOW());

-- 李宁店铺券 (merchant_id=8)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(19, '李宁满299减30', 8, 1, 30.00, 299.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '李宁旗舰店满299减30', 2, 2, 1, 0, NOW(), NOW()),
(20, '李宁满599减80', 8, 1, 80.00, 599.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '李宁旗舰店满599减80', 2, 2, 1, 0, NOW(), NOW());

-- Nike店铺券 (merchant_id=9)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(21, 'Nike满500减50', 9, 1, 50.00, 500.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 'Nike旗舰店满500减50', 2, 2, 1, 0, NOW(), NOW()),
(22, 'Nike满1000减120', 9, 1, 120.00, 1000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 'Nike旗舰店满1000减120', 2, 2, 1, 0, NOW(), NOW());

-- 当当图书券 (merchant_id=10)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(23, '当当满99减10', 10, 1, 10.00, 99.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '当当图书满99减10', 2, 2, 1, 0, NOW(), NOW()),
(24, '当当满199减30', 10, 1, 30.00, 199.00, 5000, 5000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '当当图书满199减30', 2, 2, 1, 0, NOW(), NOW());

-- 孩子王券 (merchant_id=11)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(25, '孩子王满199减20', 11, 1, 20.00, 199.00, 8000, 8000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '孩子王满199减20', 2, 2, 1, 0, NOW(), NOW()),
(26, '孩子王满499减60', 11, 1, 60.00, 499.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '孩子王满499减60', 2, 2, 1, 0, NOW(), NOW());

-- 良品铺子券 (merchant_id=12)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(27, '良品铺子满59减10', 12, 1, 10.00, 59.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '良品铺子满59减10', 2, 2, 1, 0, NOW(), NOW()),
(28, '良品铺子满129减25', 12, 1, 25.00, 129.00, 5000, 5000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '良品铺子满129减25', 2, 2, 1, 0, NOW(), NOW());

-- 宜家家居券 (merchant_id=13)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(29, '宜家满299减30', 13, 1, 30.00, 299.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '宜家家居满299减30', 2, 2, 1, 0, NOW(), NOW()),
(30, '宜家满999减120', 13, 1, 120.00, 999.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '宜家家居满999减120', 2, 2, 1, 0, NOW(), NOW());

-- 安踏店铺券 (merchant_id=14)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(31, '安踏满299减40', 14, 1, 40.00, 299.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '安踏旗舰店满299减40', 2, 2, 1, 0, NOW(), NOW()),
(32, '安踏满599减90', 14, 1, 90.00, 599.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '安踏旗舰店满599减90', 2, 2, 1, 0, NOW(), NOW());

-- 兰蔻店铺券 (merchant_id=15)
INSERT IGNORE INTO coupon_template (id, name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
(33, '兰蔻满500减60', 15, 1, 60.00, 500.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '兰蔻旗舰店满500减60', 2, 2, 1, 0, NOW(), NOW()),
(34, '兰蔻满1000减150', 15, 1, 150.00, 1000.00, 1500, 1500, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '兰蔻旗舰店满1000减150', 2, 2, 1, 0, NOW(), NOW());

-- ============================================================
-- 三、平台秒杀活动模板（platform_seckill_template）
-- ============================================================

INSERT IGNORE INTO platform_seckill_template (id, name, start_time, end_time, discount_rate, max_discount_amount, description, status, created_at, updated_at) VALUES
(1, '618年中大促秒杀', DATE_ADD(NOW(), INTERVAL -1 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY), 0.70, 500.00, '618年中大促，精选商品限时秒杀，最高优惠500元', 1, NOW(), NOW()),
(2, '每日10点秒杀', DATE_ADD(NOW(), INTERVAL 1 HOUR), DATE_ADD(NOW(), INTERVAL 30 DAY), 0.80, 300.00, '每天10点准时开抢，限时秒杀不容错过', 1, NOW(), NOW()),
(3, '新品首发秒杀', DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 7 DAY), 0.75, 200.00, '新品首发限时秒杀，抢先体验新品', 1, NOW(), NOW());

-- ============================================================
-- 四、商家秒杀报名（merchant_seckill_participation）
-- ============================================================

INSERT IGNORE INTO merchant_seckill_participation (id, template_id, merchant_id, product_id, sku_id, seckill_price, original_price, total_stock, available_stock, limit_per_user, status, created_at, updated_at) VALUES
(1, 1, 1, 1, NULL, 6999.00, 9999.00, 50, 50, 1, 2, NOW(), NOW()),
(2, 1, 1, 2, NULL, 10499.00, 14999.00, 20, 20, 1, 2, NOW(), NOW()),
(3, 2, 1, 5, NULL, 1519.00, 1899.00, 100, 100, 2, 2, NOW(), NOW()),
(4, 3, 1, 7, NULL, 4199.00, 5999.00, 30, 30, 1, 2, NOW(), NOW()),
(5, 1, 3, 17, NULL, 6299.00, 8999.00, 40, 40, 1, 2, NOW(), NOW()),
(6, 2, 3, 20, NULL, 1039.00, 1299.00, 80, 80, 2, 2, NOW(), NOW()),
(7, 1, 4, 24, NULL, 4549.00, 6499.00, 60, 60, 1, 2, NOW(), NOW()),
(8, 2, 4, 26, NULL, 303.00, 379.00, 150, 150, 3, 2, NOW(), NOW()),
(9, 1, 9, 59, NULL, 909.00, 1299.00, 30, 30, 1, 2, NOW(), NOW()),
(10, 2, 9, 60, NULL, 639.00, 799.00, 100, 100, 2, 2, NOW(), NOW());

-- ============================================================
-- 五、平台拼团活动模板（platform_group_template）
-- ============================================================

INSERT IGNORE INTO platform_group_template (id, name, required_num, discount_rate, start_time, end_time, group_duration, description, status, created_at, updated_at) VALUES
(1, '3人成团享优惠', 3, 0.85, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 24, '3人成团即可享受85折优惠', 1, NOW(), NOW()),
(2, '5人超值拼团', 5, 0.75, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 48, '5人成团享受75折超值优惠', 1, NOW(), NOW()),
(3, '2人情侣拼团', 2, 0.90, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 12, '2人成团享受9折优惠，情侣专属', 1, NOW(), NOW());

-- ============================================================
-- 六、商家拼团报名（merchant_group_participation）
-- ============================================================

INSERT IGNORE INTO merchant_group_participation (id, template_id, merchant_id, product_id, sku_id, group_price, original_price, total_stock, available_stock, status, created_at, updated_at) VALUES
(1, 1, 1, 1, NULL, 8499.00, 9999.00, 100, 100, 2, NOW(), NOW()),
(2, 1, 1, 5, NULL, 1614.00, 1899.00, 200, 200, 2, NOW(), NOW()),
(3, 2, 1, 2, NULL, 11249.00, 14999.00, 30, 30, 2, NOW(), NOW()),
(4, 1, 3, 17, NULL, 7649.00, 8999.00, 80, 80, 2, NOW(), NOW()),
(5, 2, 3, 18, NULL, 7499.00, 9999.00, 20, 20, 2, NOW(), NOW()),
(6, 1, 4, 24, NULL, 5524.00, 6499.00, 120, 120, 2, NOW(), NOW()),
(7, 3, 2, 11, NULL, 224.00, 249.00, 500, 500, 2, NOW(), NOW()),
(8, 1, 8, 52, NULL, 509.00, 599.00, 150, 150, 2, NOW(), NOW()),
(9, 2, 9, 59, NULL, 974.00, 1299.00, 50, 50, 2, NOW(), NOW()),
(10, 3, 15, 103, NULL, 288.00, 320.00, 300, 300, 2, NOW(), NOW());

-- ============================================================
-- 七、商家优惠券报名（merchant_coupon_participation）
-- ============================================================

INSERT IGNORE INTO merchant_coupon_participation (id, template_id, merchant_id, product_id, status, created_at, updated_at) VALUES
(1, 1, 1, NULL, 2, NOW(), NOW()),
(2, 2, 1, NULL, 2, NOW(), NOW()),
(3, 3, 1, 1, 2, NOW(), NOW()),
(4, 3, 1, 2, 2, NOW(), NOW()),
(5, 4, 2, NULL, 2, NOW(), NOW()),
(6, 5, 2, NULL, 2, NOW(), NOW()),
(7, 7, 3, NULL, 2, NOW(), NOW()),
(8, 8, 3, NULL, 2, NOW(), NOW()),
(9, 10, 4, NULL, 2, NOW(), NOW()),
(10, 11, 4, NULL, 2, NOW(), NOW());

-- ============================================================
-- 八、验证数据导入
-- ============================================================

SELECT '===== 优惠券和活动数据导入完成 =====' AS '';
SELECT CONCAT('平台优惠券: ', COUNT(*)) FROM platform_coupon_template;
SELECT CONCAT('店铺优惠券: ', COUNT(*)) FROM coupon_template;
SELECT CONCAT('秒杀模板: ', COUNT(*)) FROM platform_seckill_template;
SELECT CONCAT('秒杀商品: ', COUNT(*)) FROM merchant_seckill_participation;
SELECT CONCAT('拼团模板: ', COUNT(*)) FROM platform_group_template;
SELECT CONCAT('拼团商品: ', COUNT(*)) FROM merchant_group_participation;
