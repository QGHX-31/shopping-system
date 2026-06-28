USE shopping_system;

-- ============================================================
-- 重新写入用户数据
-- ============================================================
DELETE FROM user;
INSERT INTO user (id, username, password, email, phone, nickname, status, created_at, updated_at) VALUES
(1, 'user01', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'user01@example.com', '13800000001', '用户小王', 1, NOW(), NOW()),
(2, 'user02', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'user02@example.com', '13800000002', '用户小李', 1, NOW(), NOW()),
(3, 'test001', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'test001@example.com', '13800000003', '测试用户', 1, NOW(), NOW());

-- ============================================================
-- 重新写入商家数据
-- ============================================================
DELETE FROM merchant;
INSERT INTO merchant (id, username, password, shop_name, logo, contact_name, contact_phone, email, address, business_license, status, level, created_at, updated_at) VALUES
(1, 'merchant01', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'Apple官方旗舰店', NULL, '张三', '13800001111', 'service@apple.com', '上海市浦东新区', NULL, 1, 4, NOW(), NOW()),
(2, 'merchant02', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '优衣库官方旗舰店', NULL, '李四', '13800002222', 'service@uniqlo.com', '上海市静安区', NULL, 1, 3, NOW(), NOW()),
(3, 'merchant03', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '华为官方旗舰店', NULL, '华为客服', '400-830-8300', 'service@huawei.com', '广东省深圳市', NULL, 1, 5, NOW(), NOW()),
(4, 'merchant04', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '小米官方旗舰店', NULL, '小米客服', '400-100-5678', 'service@xiaomi.com', '北京市海淀区', NULL, 1, 1, NOW(), NOW()),
(5, 'merchant05', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '名创优品官方店', NULL, '名创客服', '400-123-4567', 'service@miniso.com', '广东省广州市', NULL, 1, 1, NOW(), NOW());

-- 验证
SELECT '用户:';
SELECT id, username, status FROM user;

SELECT '商家:';
SELECT id, username, shop_name, status FROM merchant;

SELECT '完成';
