-- ============================================================
-- 优惠券修复脚本（合并版）
-- 功能：
--   1. 清理 coupon_template 重复模板
--   2. 修正券名与实际类型/金额/折扣不符
--   3. 清理 user_coupon 重复用户券
--   4. 修正单品券适用范围（scope_type + scope_ids）
--   5. 添加唯一索引防止以后再出现重复
-- 执行顺序：从上到下依次执行，可重复执行
-- ============================================================

USE shopping_system;

-- ============================================================
-- 第一部分：清理 coupon_template 中的重复模板
-- ============================================================

-- 先查询有哪些重复（可跳过，仅用于确认）
SELECT merchant_id, name, type, discount_amount, min_amount, coupon_level, COUNT(*) AS 重复数量
FROM coupon_template
GROUP BY merchant_id, name, type, discount_amount, min_amount, coupon_level
HAVING COUNT(*) > 1
ORDER BY merchant_id, name;

-- 删除重复模板，保留 id 最大的那一条
CREATE TEMPORARY TABLE temp_keep_ids AS
SELECT MAX(id) AS keep_id
FROM coupon_template
GROUP BY merchant_id, name, type, discount_amount, min_amount, coupon_level;

DELETE FROM coupon_template
WHERE id NOT IN (SELECT keep_id FROM temp_keep_ids);

DROP TEMPORARY TABLE temp_keep_ids;

-- ============================================================
-- 第二部分：修正券名与实际不符的问题
-- ============================================================

-- 2.1 修正折扣券名称中的折扣数字（如"8折券"实际是9.5折）
--     用 REGEXP_REPLACE 替换名称中"数字折"的部分
UPDATE coupon_template
SET name = REGEXP_REPLACE(
    name,
    '[0-9]+(\\.[0-9]+)?折',
    CONCAT(
        IF(
            ROUND(discount_amount * 10, 1) = FLOOR(ROUND(discount_amount * 10, 1)),
            CAST(FLOOR(ROUND(discount_amount * 10, 1)) AS CHAR),
            CAST(ROUND(discount_amount * 10, 1) AS CHAR)
        ),
        '折'
    )
)
WHERE type = 2
  AND name REGEXP '[0-9]+(\\.[0-9]+)?折';

-- 2.2 修正名称写的是折扣但实际是满减的券（type=1但名称含"折"）
UPDATE coupon_template
SET name = CONCAT('满', CAST(min_amount AS DECIMAL(10,0)), '减', CAST(discount_amount AS DECIMAL(10,0)), '元券')
WHERE type = 1 AND name LIKE '%折%';

-- 2.3 修正"全场9折优惠券"如果实际是满减的情况
UPDATE coupon_template
SET name = CONCAT('满', CAST(min_amount AS DECIMAL(10,0)), '减', CAST(discount_amount AS DECIMAL(10,0)), '优惠券')
WHERE type = 1 AND name = '全场9折优惠券';

-- ============================================================
-- 第三部分：清理 user_coupon 中的重复券
-- ============================================================

-- 先查询有哪些重复（可跳过）
SELECT user_id, template_id, status, COUNT(*) AS 重复数量
FROM user_coupon
WHERE status = 0
GROUP BY user_id, template_id, status
HAVING COUNT(*) > 1;

-- 删除重复的未使用券，保留 expire_time 最晚的
CREATE TEMPORARY TABLE temp_user_keep AS
SELECT MAX(id) AS keep_id
FROM user_coupon
WHERE status = 0
GROUP BY user_id, template_id;

DELETE FROM user_coupon
WHERE status = 0
  AND id NOT IN (SELECT keep_id FROM temp_user_keep);

DROP TEMPORARY TABLE temp_user_keep;

-- 删除模板已经不存在的幽灵用户券
DELETE uc FROM user_coupon uc
LEFT JOIN coupon_template ct ON uc.template_id = ct.id
WHERE ct.id IS NULL;

-- 同步用户券的名称（如果模板名称改了）
UPDATE user_coupon uc
INNER JOIN coupon_template ct ON uc.template_id = ct.id
SET uc.name = ct.name
WHERE uc.name != ct.name;

-- ============================================================
-- 第四部分：修正单品券适用范围
-- ============================================================

-- 查看当前单品券
SELECT id, name, merchant_id, scope_type, scope_ids, coupon_level
FROM coupon_template
WHERE coupon_level = 3 OR scope_type = 3
ORDER BY id;

-- iPhone 15 Pro专属券 —— 只适用于 iPhone 15 Pro（id=1）
UPDATE coupon_template
SET scope_type = 3,
    scope_ids = '[1]',
    coupon_level = 3
WHERE name LIKE '%iPhone 15 Pro%' AND coupon_level = 3;

-- Mate 60系列专属券 —— 只适用于 华为 Mate 60 Pro+（id=9）
UPDATE coupon_template
SET scope_type = 3,
    scope_ids = '[9]',
    coupon_level = 3
WHERE name LIKE '%Mate 60%' AND coupon_level = 3;

-- 小米14系列专属券 —— 只适用于 小米14 Ultra（id=23）
UPDATE coupon_template
SET scope_type = 3,
    scope_ids = '[23]',
    coupon_level = 3
WHERE name LIKE '%小米14%' AND coupon_level = 3;

-- ============================================================
-- 第五部分：添加唯一索引，防止以后再出现重复模板
-- ============================================================

-- 安全删除旧索引（如果不存在会报错，忽略即可）
-- ALTER TABLE coupon_template DROP INDEX uk_merchant_name_type_amount;

-- 添加唯一索引
ALTER TABLE coupon_template
  ADD UNIQUE KEY uk_merchant_name_type_amount (merchant_id, name, type, discount_amount, min_amount, coupon_level);

-- ============================================================
-- 验证结果
-- ============================================================

SELECT '=== 平台券模板 ===' AS '';
SELECT id, name,
  CASE type WHEN 1 THEN CONCAT('满', CAST(min_amount AS DECIMAL(10,0)), '减', CAST(discount_amount AS DECIMAL(10,0)))
            WHEN 2 THEN CONCAT(ROUND(discount_amount * 10, 1), '折') END AS 实际内容,
  coupon_level AS 层级
FROM coupon_template
WHERE merchant_id IS NULL
ORDER BY type, id;

SELECT '=== 店铺券数量（按店铺） ===' AS '';
SELECT merchant_id, COUNT(*) AS 券数量
FROM coupon_template
WHERE merchant_id IS NOT NULL
GROUP BY merchant_id
ORDER BY merchant_id;

SELECT '=== 单品券列表 ===' AS '';
SELECT id, name, merchant_id, scope_type, scope_ids, coupon_level
FROM coupon_template
WHERE coupon_level = 3
ORDER BY id;

SELECT '优惠券修复完成，请刷新前端页面查看' AS result;
