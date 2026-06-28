USE shopping_system;

SELECT '=== 商家数据 ===';
SELECT id, username, status, level FROM merchant;

SELECT '=== 用户数据 ===';
SELECT id, username, status FROM user;

SELECT '=== 更新商家状态和密码 ===';
UPDATE merchant SET status=1, password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=1;
UPDATE merchant SET status=1, password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=2;
UPDATE merchant SET status=1, password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=3;
UPDATE merchant SET status=1, password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=4;
UPDATE merchant SET status=1, password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=5;

UPDATE user SET password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=1;
UPDATE user SET password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=2;
UPDATE user SET password='$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de' WHERE id=3;

SELECT '=== 更新后 ===';
SELECT id, username, status FROM merchant;
SELECT id, username, status FROM user;

SELECT '完成';
