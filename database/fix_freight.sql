USE shopping_system;

-- 给 freight_template 添加缺失字段
ALTER TABLE freight_template ADD COLUMN type TINYINT DEFAULT 1 COMMENT '计费方式：1按件数 2按重量' AFTER name;
ALTER TABLE freight_template ADD COLUMN free_amount DECIMAL(10,2) DEFAULT 0.00 COMMENT '包邮门槛金额' AFTER default_freight;
ALTER TABLE freight_template ADD COLUMN is_default TINYINT DEFAULT 0 COMMENT '是否默认模板：0否 1是' AFTER free_amount;

DESCRIBE freight_template;
