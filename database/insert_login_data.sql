USE shopping_system;

-- ============================================================
-- 写入用户数据（INSERT IGNORE 不删除现有数据）
-- ============================================================
INSERT IGNORE INTO user (id, username, password, email, phone, nickname, status, created_at, updated_at) VALUES
(1, 'user01', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'user01@example.com', '13800000001', '用户小王', 1, NOW(), NOW()),
(2, 'user02', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'user02@example.com', '13800000002', '用户小李', 1, NOW(), NOW()),
(3, 'test001', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'test001@example.com', '13800000003', '测试用户', 1, NOW(), NOW());

-- ============================================================
-- 商家状态统一更新为已通过（status=1），密码统一
-- ============================================================
UPDATE merchant SET status = 1, password = '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de';

-- 验证
SELECT '用户:';
SELECT id, username, status FROM user;

SELECT '商家:';
SELECT id, username, shop_name, status FROM merchant;

SELECT '完成';
