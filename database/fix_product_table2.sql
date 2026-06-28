USE shopping_system;

-- 给 product 表添加缺失的字段
-- 忽略重复字段的错误
ALTER TABLE product ADD COLUMN brand VARCHAR(100) COMMENT '品牌' AFTER category_id;
ALTER TABLE product ADD COLUMN sales_count INT DEFAULT 0 COMMENT '销量' AFTER stock;
ALTER TABLE product ADD COLUMN detail_images VARCHAR(1000) COMMENT '详情图片，逗号分隔' AFTER image_url;
ALTER TABLE product ADD COLUMN sub_title VARCHAR(500) COMMENT '副标题' AFTER name;

SELECT 'product 表字段已添加';
