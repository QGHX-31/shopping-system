USE shopping_system;

-- 给 product 表添加缺失的字段
ALTER TABLE product 
ADD COLUMN IF NOT EXISTS brand VARCHAR(100) COMMENT '品牌' AFTER category_id,
ADD COLUMN IF NOT EXISTS sales_count INT DEFAULT 0 COMMENT '销量' AFTER stock,
ADD COLUMN IF NOT EXISTS detail_images VARCHAR(1000) COMMENT '详情图片，逗号分隔' AFTER image_url,
ADD COLUMN IF NOT EXISTS sub_title VARCHAR(500) COMMENT '副标题' AFTER name;

-- 查看 product 表结构
DESCRIBE product;
