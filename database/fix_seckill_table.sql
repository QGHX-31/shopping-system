ALTER TABLE `seckill_activity` ADD COLUMN `product_id` bigint DEFAULT NULL COMMENT '商品ID' AFTER `merchant_id`;
ALTER TABLE `seckill_activity` ADD COLUMN `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID' AFTER `product_id`;
ALTER TABLE `seckill_activity` ADD COLUMN `seckill_price` decimal(10,2) DEFAULT NULL COMMENT '秒杀价' AFTER `sku_id`;
ALTER TABLE `seckill_activity` ADD COLUMN `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价' AFTER `seckill_price`;
ALTER TABLE `seckill_activity` ADD COLUMN `total_stock` int DEFAULT NULL COMMENT '总库存' AFTER `original_price`;
ALTER TABLE `seckill_activity` ADD COLUMN `available_stock` int DEFAULT NULL COMMENT '剩余库存' AFTER `total_stock`;

ALTER TABLE `seckill_activity` ADD INDEX `idx_product_id` (`product_id`);
ALTER TABLE `seckill_activity` ADD INDEX `idx_merchant_id` (`merchant_id`);
