USE shopping_system;

-- 1. 将 receiver 字段改名为 name
ALTER TABLE address CHANGE COLUMN receiver name VARCHAR(50) NOT NULL COMMENT '收货人姓名';

-- 2. 增加 status 字段
ALTER TABLE address ADD COLUMN status TINYINT DEFAULT 1 COMMENT '状态：0禁用，1启用' AFTER is_default;

-- 验证
DESCRIBE address;
