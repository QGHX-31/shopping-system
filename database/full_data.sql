-- ============================================================
-- 完整初始化数据（统一整理版）
-- 执行顺序：先执行 schema.sql → order_tables.sql → activity_tables.sql → 再执行本文件
-- ============================================================

USE shopping_system;

-- ============================================================
-- 一、扩展商品分类
-- ============================================================

INSERT IGNORE INTO category (id, name, parent_id, sort_order, icon, status, created_at, updated_at) VALUES
-- 一级分类
(11, '家居生活', 0, 3, '🏠', 1, NOW(), NOW()),
(12, '美妆个护', 0, 4, '💄', 1, NOW(), NOW()),
(13, '食品生鲜', 0, 5, '🍎', 1, NOW(), NOW()),
(14, '图书文具', 0, 6, '📚', 1, NOW(), NOW()),
(15, '运动户外', 0, 7, '⚽', 1, NOW(), NOW()),
(16, '母婴用品', 0, 8, '👶', 1, NOW(), NOW()),
-- 电子产品子分类（补充）
(17, '数码配件', 1, 6, '🎧', 1, NOW(), NOW()),
-- 服装鞋包子分类（补充）
(18, '女装', 2, 2, '👗', 1, NOW(), NOW()),
(19, '鞋靴', 2, 3, '👟', 1, NOW(), NOW()),
(20, '箱包', 2, 4, '👜', 1, NOW(), NOW()),
-- 美妆个护子分类
(21, '护肤', 12, 1, '🧴', 1, NOW(), NOW()),
(22, '彩妆', 12, 2, '💋', 1, NOW(), NOW()),
(23, '香水', 12, 3, '🌸', 1, NOW(), NOW()),
-- 食品生鲜子分类
(24, '零食', 13, 1, '🍪', 1, NOW(), NOW()),
(25, '生鲜', 13, 2, '🥬', 1, NOW(), NOW()),
(26, '饮料', 13, 3, '🧃', 1, NOW(), NOW()),
-- 图书文具子分类
(27, '图书', 14, 1, '📖', 1, NOW(), NOW()),
(28, '文具', 14, 2, '✏️', 1, NOW(), NOW()),
-- 运动户外子分类
(29, '运动服饰', 15, 1, '🏃', 1, NOW(), NOW()),
(30, '运动器材', 15, 2, '🏀', 1, NOW(), NOW()),
-- 母婴用品子分类
(31, '奶粉辅食', 16, 1, '🍼', 1, NOW(), NOW()),
(32, '尿裤湿巾', 16, 2, '🧷', 1, NOW(), NOW()),
(33, '童车童床', 16, 3, '🚗', 1, NOW(), NOW()),
-- 家居生活子分类
(34, '家纺', 11, 1, '🛏️', 1, NOW(), NOW()),
(35, '厨具', 11, 2, '🍳', 1, NOW(), NOW()),
(36, '家具', 11, 3, '🪑', 1, NOW(), NOW());

-- ============================================================
-- 二、补充商家（店铺）
-- ============================================================

-- 补充华为商家（merchant_id=3）
INSERT IGNORE INTO merchant (id, username, password, shop_name, logo, contact_name, contact_phone, email, address, status, level, created_at, updated_at) VALUES
(3, 'merchant03', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '华为官方旗舰店', NULL, '华为客服', '400-830-8300', 'service@huawei.com', '广东省深圳市龙岗区坂田华为基地', 1, 5, NOW(), NOW());

-- 小米、名创优品、三只松鼠、完美日记（4-7）
INSERT IGNORE INTO merchant (id, username, password, shop_name, logo, contact_name, contact_phone, email, address, status, level, created_at, updated_at) VALUES
(4, 'merchant04', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '小米官方旗舰店', NULL, '小米客服', '400-100-5678', 'service@xiaomi.com', '北京市海淀区清河', 1, 1, NOW(), NOW()),
(5, 'merchant05', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '名创优品官方店', NULL, '名创客服', '400-123-4567', 'service@miniso.com', '广东省广州市', 1, 1, NOW(), NOW()),
(6, 'merchant06', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '三只松鼠旗舰店', NULL, '松鼠客服', '400-800-1234', 'service@sanzhi.com', '安徽省芜湖市', 1, 1, NOW(), NOW()),
(7, 'merchant07', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '完美日记旗舰店', NULL, '完美日记客服', '400-600-8888', 'service@perfect.com', '广东省广州市', 1, 1, NOW(), NOW());

-- 新增8个店铺（8-15）
INSERT IGNORE INTO merchant (id, username, password, shop_name, logo, contact_name, contact_phone, email, address, status, level, created_at, updated_at) VALUES
(8, 'merchant08', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '李宁官方旗舰店', NULL, '李宁客服', '400-610-0011', 'service@lining.com', '北京市通州区李宁工业园', 1, 4, NOW(), NOW()),
(9, 'merchant09', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'Nike耐克官方旗舰店', NULL, 'Nike客服', '400-880-6453', 'service@nike.com', '上海市静安区南京西路', 1, 5, NOW(), NOW()),
(10, 'merchant10', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '当当图书旗舰店', NULL, '当当客服', '400-106-6666', 'service@dangdang.com', '北京市朝阳区安慧里', 1, 3, NOW(), NOW()),
(11, 'merchant11', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '孩子王官方旗舰店', NULL, '孩子王客服', '400-888-9999', 'service@haiziwang.com', '南京市建邺区新城科技园', 1, 3, NOW(), NOW()),
(12, 'merchant12', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '良品铺子旗舰店', NULL, '良品客服', '400-117-7577', 'service@liangpinpuzi.com', '湖北省武汉市东西湖区', 1, 3, NOW(), NOW()),
(13, 'merchant13', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '宜家家居旗舰店', NULL, '宜家客服', '400-800-2345', 'service@ikea.com', '上海市徐汇区漕溪路', 1, 4, NOW(), NOW()),
(14, 'merchant14', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '安踏官方旗舰店', NULL, '安踏客服', '400-886-8888', 'service@anta.com', '福建省泉州市晋江市', 1, 4, NOW(), NOW()),
(15, 'merchant15', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '兰蔻官方旗舰店', NULL, '兰蔻客服', '400-820-8088', 'service@lancome.com', '上海市静安区南京西路', 1, 5, NOW(), NOW());

-- ============================================================
-- 三、补充最初2个店铺的地址信息
-- ============================================================

UPDATE merchant SET address = '上海市浦东新区张江高科技园区', email = 'service@apple.com' WHERE id = 1;
UPDATE merchant SET address = '上海市徐汇区虹桥路', email = 'service@uniqlo.com' WHERE id = 2;

-- ============================================================
-- 四、修正商品归属（schema.sql里的初始数据有误）
-- ============================================================

-- 华为Mate 60 Pro 应该属于华为店铺（3），而不是Apple
UPDATE product SET merchant_id = 3 WHERE id = 2 AND merchant_id = 1;

-- 小米14 Ultra 应该属于小米店铺（4），而不是Apple
UPDATE product SET merchant_id = 4 WHERE id = 4 AND merchant_id = 1;

-- ============================================================
-- 五、华为店铺商品（merchant_id=3）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(9, '华为 Mate 60 Pro+', 3, '华为', 8999.00, 9999.00, 150, 60, '华为Mate60 Pro+ 16GB+1TB 砚黑', 'https://picsum.photos/400/400?random=9', '[]', 1, 1, 1, 3, NOW(), NOW()),
(10, '华为 Pura 70 Ultra', 3, '华为', 9999.00, 10999.00, 80, 25, '华为Pura70 Ultra 超聚光伸缩镜头', 'https://picsum.photos/400/400?random=10', '[]', 1, 1, 1, 3, NOW(), NOW()),
(11, '华为 MatePad Pro 13.2', 8, '华为', 5499.00, 5999.00, 100, 40, '华为MatePad Pro 13.2英寸 鸿蒙系统', 'https://picsum.photos/400/400?random=11', '[]', 1, 0, 1, 3, NOW(), NOW()),
(12, '华为 FreeBuds Pro 3', 9, '华为', 1299.00, 1499.00, 300, 120, '华为FreeBuds Pro 3 主动降噪蓝牙耳机', 'https://picsum.photos/400/400?random=12', '[]', 1, 1, 1, 3, NOW(), NOW()),
(13, '华为 Watch GT 4', 10, '华为', 1488.00, 1688.00, 200, 80, '华为Watch GT 4 46mm 智能手表', 'https://picsum.photos/400/400?random=13', '[]', 0, 1, 1, 3, NOW(), NOW()),
(14, '华为 MateBook X Pro', 4, '华为', 11999.00, 12999.00, 60, 15, '华为MateBook X Pro 2024款 微绒典藏版', 'https://picsum.photos/400/400?random=14', '[]', 0, 0, 1, 3, NOW(), NOW()),
(15, '华为 nova 12 Pro', 3, '华为', 4999.00, 5499.00, 250, 90, '华为nova 12 Pro 前置6000万追焦双摄', 'https://picsum.photos/400/400?random=15', '[]', 0, 1, 1, 3, NOW(), NOW());

-- ============================================================
-- 六、小米店铺商品（merchant_id=4）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(23, '小米14 Ultra', 3, '小米', 6499.00, 6999.00, 200, 80, '小米14 Ultra 徕卡光学 专业影像旗舰', 'https://picsum.photos/400/400?random=23', '[]', 1, 1, 1, 4, NOW(), NOW()),
(24, '小米电视 S Pro 75寸', 1, '小米', 4999.00, 5999.00, 100, 30, '小米电视 S Pro 75英寸 Mini LED', 'https://picsum.photos/400/400?random=24', '[]', 0, 1, 1, 4, NOW(), NOW()),
(25, '小米手环 8 Pro', 10, '小米', 379.00, 429.00, 500, 200, '小米手环8 Pro 大屏 长续航', 'https://picsum.photos/400/400?random=25', '[]', 1, 0, 1, 4, NOW(), NOW()),
(26, '米家空气净化器 4 Pro', 1, '小米', 1499.00, 1699.00, 150, 60, '米家空气净化器4 Pro 除甲醛', 'https://picsum.photos/400/400?random=26', '[]', 0, 0, 1, 4, NOW(), NOW()),
(27, '小米保温杯', 11, '小米', 89.00, 129.00, 800, 300, '小米保温杯 316不锈钢 大容量', 'https://picsum.photos/400/400?random=27', '[]', 1, 0, 1, 4, NOW(), NOW()),
(28, 'RedmiBook Pro 15', 4, '小米', 4999.00, 5499.00, 120, 40, 'RedmiBook Pro 15 2024款 标压处理器', 'https://picsum.photos/400/400?random=28', '[]', 0, 1, 1, 4, NOW(), NOW()),
(29, '小米电动牙刷 T700', 11, '小米', 299.00, 349.00, 300, 120, '小米电动牙刷T700 声波震动', 'https://picsum.photos/400/400?random=29', '[]', 0, 0, 1, 4, NOW(), NOW()),
(30, 'Redmi Watch 4', 10, '小米', 599.00, 699.00, 250, 90, 'Redmi Watch 4 智能手表 运动健康', 'https://picsum.photos/400/400?random=30', '[]', 1, 1, 1, 4, NOW(), NOW());

-- ============================================================
-- 七、名创优品店铺商品（merchant_id=5）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(31, '名创优品香薰蜡烛', 11, 'MINISO', 39.90, 59.90, 600, 250, '名创优品香薰蜡烛 北欧风', 'https://picsum.photos/400/400?random=31', '[]', 1, 0, 1, 5, NOW(), NOW()),
(32, '可爱毛绒玩偶', 11, 'MINISO', 29.90, 49.90, 1000, 450, '可爱毛绒玩偶 公仔礼物', 'https://picsum.photos/400/400?random=32', '[]', 1, 1, 1, 5, NOW(), NOW()),
(33, '收纳整理盒三件套', 11, 'MINISO', 49.90, 79.90, 400, 180, '收纳整理盒 桌面收纳 三件套', 'https://picsum.photos/400/400?random=33', '[]', 0, 0, 1, 5, NOW(), NOW()),
(34, '保湿补水面膜 10片装', 21, 'MINISO', 59.90, 89.90, 500, 220, '保湿补水面膜 10片装 深层补水', 'https://picsum.photos/400/400?random=34', '[]', 1, 0, 1, 5, NOW(), NOW()),
(35, '保温杯 350ml', 11, 'MINISO', 39.90, 59.90, 700, 280, '保温杯 350ml 迷你便携', 'https://picsum.photos/400/400?random=35', '[]', 0, 1, 1, 5, NOW(), NOW()),
(36, '笔记本套装', 28, 'MINISO', 24.90, 39.90, 800, 320, '笔记本套装 3本装 简约风', 'https://picsum.photos/400/400?random=36', '[]', 0, 0, 1, 5, NOW(), NOW());

-- ============================================================
-- 八、三只松鼠店铺商品（merchant_id=6）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(37, '三只松鼠每日坚果 750g', 24, '三只松鼠', 89.90, 129.90, 500, 300, '每日坚果 750g 混合坚果 30包', 'https://picsum.photos/400/400?random=37', '[]', 1, 0, 1, 6, NOW(), NOW()),
(38, '三只松鼠夏威夷果', 24, '三只松鼠', 39.90, 59.90, 600, 250, '夏威夷果 奶油味 265g', 'https://picsum.photos/400/400?random=38', '[]', 1, 0, 1, 6, NOW(), NOW()),
(39, '三只松鼠辣条大礼包', 24, '三只松鼠', 29.90, 49.90, 800, 400, '辣条大礼包 网红零食 儿时味道', 'https://picsum.photos/400/400?random=39', '[]', 1, 1, 1, 6, NOW(), NOW()),
(40, '三只松鼠碧根果', 24, '三只松鼠', 45.90, 65.90, 400, 180, '碧根果 奶油味 210g', 'https://picsum.photos/400/400?random=40', '[]', 0, 0, 1, 6, NOW(), NOW()),
(41, '三只松鼠水果干组合', 24, '三只松鼠', 59.90, 89.90, 350, 150, '水果干组合 芒果干 草莓干', 'https://picsum.photos/400/400?random=41', '[]', 0, 1, 1, 6, NOW(), NOW()),
(42, '三只松鼠牛肉干', 24, '三只松鼠', 69.90, 99.90, 300, 120, '牛肉干 香辣味 200g', 'https://picsum.photos/400/400?random=42', '[]', 0, 0, 1, 6, NOW(), NOW());

-- ============================================================
-- 九、完美日记店铺商品（merchant_id=7）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(43, '完美日记小细跟口红', 22, '完美日记', 99.00, 129.00, 400, 220, '小细跟口红 丝绒哑光 显白', 'https://picsum.photos/400/400?random=43', '[]', 1, 0, 1, 7, NOW(), NOW()),
(44, '完美日记动物眼影盘', 22, '完美日记', 129.00, 169.00, 300, 150, '动物眼影盘 十二色 大地色', 'https://picsum.photos/400/400?random=44', '[]', 1, 1, 1, 7, NOW(), NOW()),
(45, '完美日记氨基酸洗面奶', 21, '完美日记', 59.90, 79.90, 500, 200, '氨基酸洗面奶 温和清洁 补水', 'https://picsum.photos/400/400?random=45', '[]', 0, 0, 1, 7, NOW(), NOW()),
(46, '完美日记天鹅绒唇釉', 22, '完美日记', 79.90, 99.90, 450, 180, '天鹅绒唇釉 哑光丝绒 持久', 'https://picsum.photos/400/400?random=46', '[]', 1, 0, 1, 7, NOW(), NOW()),
(47, '完美日记气垫BB霜', 22, '完美日记', 119.00, 159.00, 350, 130, '气垫BB霜 遮瑕保湿 持久不脱妆', 'https://picsum.photos/400/400?random=47', '[]', 0, 1, 1, 7, NOW(), NOW()),
(48, '完美日记香水', 23, '完美日记', 159.00, 199.00, 200, 80, '香水 花香调 持久淡香', 'https://picsum.photos/400/400?random=48', '[]', 0, 0, 1, 7, NOW(), NOW());

-- ============================================================
-- 十、优衣库店铺补充商品（merchant_id=2）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(200, '优衣库圆领T恤', 5, 'UNIQLO', 99.00, 149.00, 500, 280, '优衣库男士圆领T恤 纯棉', 'https://picsum.photos/400/400?random=200', '[]', 1, 0, 1, 2, NOW(), NOW()),
(201, '优衣库牛仔裤', 5, 'UNIQLO', 199.00, 299.00, 400, 200, '优衣库男士牛仔裤 直筒', 'https://picsum.photos/400/400?random=201', '[]', 0, 0, 1, 2, NOW(), NOW()),
(202, '优衣库连衣裙', 18, 'UNIQLO', 249.00, 349.00, 300, 150, '优衣库女士连衣裙 夏季', 'https://picsum.photos/400/400?random=202', '[]', 1, 1, 1, 2, NOW(), NOW()),
(203, '优衣库衬衫', 5, 'UNIQLO', 149.00, 249.00, 350, 160, '优衣库男士长袖衬衫', 'https://picsum.photos/400/400?random=203', '[]', 0, 0, 1, 2, NOW(), NOW()),
(204, '优衣库卫衣', 5, 'UNIQLO', 199.00, 299.00, 300, 140, '优衣库连帽卫衣 加绒', 'https://picsum.photos/400/400?random=204', '[]', 1, 0, 1, 2, NOW(), NOW()),
(205, '优衣库女款针织衫', 18, 'UNIQLO', 179.00, 279.00, 250, 120, '优衣库女士针织开衫', 'https://picsum.photos/400/400?random=205', '[]', 0, 1, 1, 2, NOW(), NOW()),
(206, '优衣库短裤', 5, 'UNIQLO', 99.00, 149.00, 400, 180, '优衣库男士短裤 速干', 'https://picsum.photos/400/400?random=206', '[]', 0, 0, 1, 2, NOW(), NOW());

-- ============================================================
-- 十一、Apple店铺补充商品（merchant_id=1）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(210, 'iPhone 15 Pro Max', 3, 'Apple', 9999.00, 10999.00, 80, 40, 'iPhone 15 Pro Max 256GB', 'https://picsum.photos/400/400?random=210', '[]', 1, 0, 1, 1, NOW(), NOW()),
(211, 'Apple Watch Series 9', 10, 'Apple', 2999.00, 3199.00, 150, 70, 'Apple Watch Series 9 GPS款', 'https://picsum.photos/400/400?random=211', '[]', 0, 1, 1, 1, NOW(), NOW()),
(212, 'MacBook Air M2', 4, 'Apple', 8999.00, 9499.00, 60, 25, 'MacBook Air 13寸 M2', 'https://picsum.photos/400/400?random=212', '[]', 0, 0, 1, 1, NOW(), NOW()),
(213, 'AirPods Max', 9, 'Apple', 3999.00, 4399.00, 100, 40, 'AirPods Max 头戴式耳机', 'https://picsum.photos/400/400?random=213', '[]', 1, 0, 1, 1, NOW(), NOW());

-- ============================================================
-- 十二、李宁旗舰店商品（merchant_id=8）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(49, '李宁篮球鞋 闪击8', 19, '李宁', 599.00, 799.00, 300, 150, '李宁闪击8 篮球鞋 实战减震', 'https://picsum.photos/400/400?random=49', '[]', 1, 0, 1, 8, NOW(), NOW()),
(50, '李宁运动T恤', 29, '李宁', 149.00, 249.00, 500, 280, '李宁运动T恤 速干透气', 'https://picsum.photos/400/400?random=50', '[]', 1, 1, 1, 8, NOW(), NOW()),
(51, '李宁羽毛球拍', 30, '李宁', 399.00, 599.00, 200, 90, '李宁羽毛球拍 碳素超轻', 'https://picsum.photos/400/400?random=51', '[]', 0, 0, 1, 8, NOW(), NOW()),
(52, '李宁跑鞋 赤兔6', 19, '李宁', 499.00, 699.00, 400, 200, '李宁赤兔6 跑步鞋 轻量竞速', 'https://picsum.photos/400/400?random=52', '[]', 1, 1, 1, 8, NOW(), NOW()),
(53, '李宁运动裤', 29, '李宁', 199.00, 299.00, 350, 160, '李宁运动长裤 速干透气', 'https://picsum.photos/400/400?random=53', '[]', 0, 0, 1, 8, NOW(), NOW()),
(54, '李宁双肩背包', 20, '李宁', 179.00, 279.00, 250, 110, '李宁双肩背包 运动休闲', 'https://picsum.photos/400/400?random=54', '[]', 0, 1, 1, 8, NOW(), NOW()),
(55, '李宁卫衣', 29, '李宁', 299.00, 449.00, 300, 130, '李宁套头卫衣 加绒保暖', 'https://picsum.photos/400/400?random=55', '[]', 1, 0, 1, 8, NOW(), NOW()),
(56, '李宁乒乓球拍', 30, '李宁', 129.00, 199.00, 400, 180, '李宁乒乓球拍 双拍套装', 'https://picsum.photos/400/400?random=56', '[]', 0, 0, 1, 8, NOW(), NOW());

-- ============================================================
-- 十三、Nike耐克旗舰店商品（merchant_id=9）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(57, 'Nike Air Jordan 1', 19, 'Nike', 1299.00, 1599.00, 150, 80, 'Air Jordan 1 经典篮球鞋', 'https://picsum.photos/400/400?random=57', '[]', 1, 0, 1, 9, NOW(), NOW()),
(58, 'Nike Air Force 1', 19, 'Nike', 799.00, 899.00, 300, 180, 'Air Force 1 空军一号 小白鞋', 'https://picsum.photos/400/400?random=58', '[]', 1, 1, 1, 9, NOW(), NOW()),
(59, 'Nike Pro运动T恤', 29, 'Nike', 229.00, 299.00, 500, 250, 'Nike Pro 紧身速干T恤', 'https://picsum.photos/400/400?random=59', '[]', 1, 0, 1, 9, NOW(), NOW()),
(60, 'Nike Pegasus 40', 19, 'Nike', 899.00, 1099.00, 250, 120, 'Nike Pegasus 40 跑步鞋', 'https://picsum.photos/400/400?random=60', '[]', 0, 1, 1, 9, NOW(), NOW()),
(61, 'Nike运动短裤', 29, 'Nike', 199.00, 259.00, 400, 200, 'Nike运动短裤 速干透气', 'https://picsum.photos/400/400?random=61', '[]', 0, 0, 1, 9, NOW(), NOW()),
(62, 'Nike双肩包', 20, 'Nike', 349.00, 449.00, 200, 90, 'Nike双肩背包 大容量', 'https://picsum.photos/400/400?random=62', '[]', 1, 0, 1, 9, NOW(), NOW()),
(63, 'Nike篮球', 30, 'Nike', 199.00, 299.00, 300, 140, 'Nike标准7号篮球 室内外通用', 'https://picsum.photos/400/400?random=63', '[]', 0, 0, 1, 9, NOW(), NOW()),
(64, 'Nike鸭舌帽', 20, 'Nike', 149.00, 199.00, 350, 160, 'Nike运动鸭舌帽 防晒透气', 'https://picsum.photos/400/400?random=64', '[]', 0, 1, 1, 9, NOW(), NOW());

-- ============================================================
-- 十四、当当图书旗舰店商品（merchant_id=10）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(65, '三体全集 套装3册', 27, '当当', 83.00, 168.00, 500, 320, '三体全集1-3 刘慈欣科幻小说', 'https://picsum.photos/400/400?random=65', '[]', 1, 0, 1, 10, NOW(), NOW()),
(66, '活着 余华', 27, '当当', 21.00, 45.00, 800, 500, '活着 余华代表作 正版', 'https://picsum.photos/400/400?random=66', '[]', 1, 1, 1, 10, NOW(), NOW()),
(67, '百年孤独', 27, '当当', 39.50, 79.00, 600, 280, '百年孤独 马尔克斯 诺贝尔文学奖', 'https://picsum.photos/400/400?random=67', '[]', 0, 0, 1, 10, NOW(), NOW()),
(68, '新华字典 第12版', 27, '当当', 19.90, 32.80, 1000, 600, '新华字典 第12版 商务印书馆', 'https://picsum.photos/400/400?random=68', '[]', 1, 0, 1, 10, NOW(), NOW()),
(69, '晨光中性笔12支装', 28, '晨光', 19.90, 29.90, 1000, 450, '晨光中性笔 12支装 黑色', 'https://picsum.photos/400/400?random=69', '[]', 1, 1, 1, 10, NOW(), NOW()),
(70, '得力笔记本A5 5本装', 28, '得力', 29.90, 49.90, 800, 380, '得力笔记本 A5 5本装', 'https://picsum.photos/400/400?random=70', '[]', 0, 0, 1, 10, NOW(), NOW()),
(71, '小王子', 27, '当当', 19.90, 39.80, 700, 350, '小王子 经典儿童文学', 'https://picsum.photos/400/400?random=71', '[]', 1, 0, 1, 10, NOW(), NOW()),
(72, '人类简史', 27, '当当', 48.00, 96.00, 400, 180, '人类简史 从动物到上帝', 'https://picsum.photos/400/400?random=72', '[]', 0, 1, 1, 10, NOW(), NOW());

-- ============================================================
-- 十五、孩子王官方旗舰店商品（merchant_id=11）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(73, '爱他美奶粉 3段 800g', 31, '爱他美', 258.00, 328.00, 400, 220, '爱他美经典版 3段 800g', 'https://picsum.photos/400/400?random=73', '[]', 1, 0, 1, 11, NOW(), NOW()),
(74, '帮宝适纸尿裤 L码', 32, '帮宝适', 99.00, 149.00, 600, 350, '帮宝适超薄干爽 L码 72片', 'https://picsum.photos/400/400?random=74', '[]', 1, 1, 1, 11, NOW(), NOW()),
(75, '费雪海马安抚玩偶', 33, '费雪', 129.00, 169.00, 300, 150, '费雪声光安抚小海马', 'https://picsum.photos/400/400?random=75', '[]', 0, 0, 1, 11, NOW(), NOW()),
(76, '惠氏启赋奶粉 2段', 31, '惠氏', 388.00, 488.00, 300, 140, '惠氏启赋蓝钻 2段 900g', 'https://picsum.photos/400/400?random=76', '[]', 0, 1, 1, 11, NOW(), NOW()),
(77, '婴儿湿巾 80抽x5包', 32, '好奇', 49.90, 79.90, 500, 280, '婴儿手口湿巾 80抽*5包', 'https://picsum.photos/400/400?random=77', '[]', 1, 0, 1, 11, NOW(), NOW()),
(78, '好孩子婴儿推车', 33, '好孩子', 899.00, 1299.00, 150, 60, '好孩子婴儿推车 轻便折叠', 'https://picsum.photos/400/400?random=78', '[]', 0, 0, 1, 11, NOW(), NOW()),
(79, '飞鹤奶粉 1段 900g', 31, '飞鹤', 308.00, 398.00, 350, 160, '飞鹤星飞帆 1段 900g', 'https://picsum.photos/400/400?random=79', '[]', 1, 0, 1, 11, NOW(), NOW()),
(80, '婴儿连体衣 3件装', 29, '巴拉巴拉', 89.90, 139.90, 500, 240, '婴儿连体衣 纯棉 3件装', 'https://picsum.photos/400/400?random=80', '[]', 0, 1, 1, 11, NOW(), NOW());

-- ============================================================
-- 十六、良品铺子旗舰店商品（merchant_id=12）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(81, '良品铺子每日坚果 750g', 24, '良品铺子', 89.90, 129.00, 500, 280, '每日坚果 30包 750g', 'https://picsum.photos/400/400?random=81', '[]', 1, 0, 1, 12, NOW(), NOW()),
(82, '良品铺子猪肉脯 200g', 24, '良品铺子', 39.90, 59.90, 600, 320, '猪肉脯 自然片 200g', 'https://picsum.photos/400/400?random=82', '[]', 1, 1, 1, 12, NOW(), NOW()),
(83, '良品铺子芒果干 108g', 24, '良品铺子', 25.90, 39.90, 800, 450, '芒果干 休闲零食 蜜饯果干', 'https://picsum.photos/400/400?random=83', '[]', 0, 0, 1, 12, NOW(), NOW()),
(84, '良品铺子鸭脖 190g', 24, '良品铺子', 32.90, 49.90, 500, 250, '鸭脖 卤味 麻辣 190g', 'https://picsum.photos/400/400?random=84', '[]', 1, 0, 1, 12, NOW(), NOW()),
(85, '良品铺子手撕面包 1kg', 24, '良品铺子', 29.90, 49.90, 700, 380, '手撕面包 1kg 早餐糕点', 'https://picsum.photos/400/400?random=85', '[]', 1, 1, 1, 12, NOW(), NOW()),
(86, '良品铺子夏威夷果 238g', 24, '良品铺子', 45.90, 65.90, 400, 180, '夏威夷果 奶油味 238g', 'https://picsum.photos/400/400?random=86', '[]', 0, 0, 1, 12, NOW(), NOW()),
(87, '良品铺子牛板筋 150g', 24, '良品铺子', 35.90, 55.90, 450, 200, '牛板筋 烧烤味 150g', 'https://picsum.photos/400/400?random=87', '[]', 0, 1, 1, 12, NOW(), NOW()),
(88, '良品铺子曲奇饼干', 24, '良品铺子', 29.90, 45.90, 600, 260, '曲奇饼干 黄油味 200g', 'https://picsum.photos/400/400?random=88', '[]', 0, 0, 1, 12, NOW(), NOW());

-- ============================================================
-- 十七、宜家家居旗舰店商品（merchant_id=13）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(89, '宜家拉克边桌', 36, '宜家', 79.00, 129.00, 400, 220, '拉克边桌 白色 55x55cm', 'https://picsum.photos/400/400?random=89', '[]', 1, 0, 1, 13, NOW(), NOW()),
(90, '宜家波昂扶手椅', 36, '宜家', 499.00, 699.00, 150, 60, '波昂单人扶手椅 桦木贴面', 'https://picsum.photos/400/400?random=90', '[]', 0, 1, 1, 13, NOW(), NOW()),
(91, '宜家被套枕套套装', 34, '宜家', 149.00, 249.00, 300, 150, '被套枕套套装 双人 全棉', 'https://picsum.photos/400/400?random=91', '[]', 1, 0, 1, 13, NOW(), NOW()),
(92, '宜家卡瓦科砧板', 35, '宜家', 29.90, 49.90, 500, 280, '卡瓦科砧板 竹制 2件套', 'https://picsum.photos/400/400?random=92', '[]', 0, 0, 1, 13, NOW(), NOW()),
(93, '宜家特提亚工作灯', 36, '宜家', 99.00, 149.00, 250, 120, '特提亚工作灯 银色 可调节', 'https://picsum.photos/400/400?random=93', '[]', 1, 1, 1, 13, NOW(), NOW()),
(94, '宜家考肯密封罐', 35, '宜家', 39.90, 59.90, 600, 320, '考肯密封罐 玻璃 3件套', 'https://picsum.photos/400/400?random=94', '[]', 0, 0, 1, 13, NOW(), NOW()),
(95, '宜家记忆棉枕头', 34, '宜家', 129.00, 199.00, 350, 160, '记忆棉枕头 人体工学', 'https://picsum.photos/400/400?random=95', '[]', 1, 0, 1, 13, NOW(), NOW()),
(96, '宜家收纳盒 3件套', 36, '宜家', 59.90, 89.90, 450, 200, '收纳盒 3件套 可叠放', 'https://picsum.photos/400/400?random=96', '[]', 0, 1, 1, 13, NOW(), NOW());

-- ============================================================
-- 十八、安踏官方旗舰店商品（merchant_id=14）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(97, '安踏KT8篮球鞋', 19, '安踏', 599.00, 799.00, 250, 120, '安踏KT8 汤普森签名篮球鞋', 'https://picsum.photos/400/400?random=97', '[]', 1, 0, 1, 14, NOW(), NOW()),
(98, '安踏氢跑4 跑步鞋', 19, '安踏', 349.00, 499.00, 400, 200, '安踏氢跑4 轻量跑步鞋', 'https://picsum.photos/400/400?random=98', '[]', 1, 1, 1, 14, NOW(), NOW()),
(99, '安踏运动T恤', 29, '安踏', 129.00, 199.00, 500, 280, '安踏速干T恤 透气短袖', 'https://picsum.photos/400/400?random=99', '[]', 0, 0, 1, 14, NOW(), NOW()),
(100, '安踏运动套装', 29, '安踏', 299.00, 449.00, 300, 140, '安踏运动套装 短袖短裤', 'https://picsum.photos/400/400?random=100', '[]', 1, 0, 1, 14, NOW(), NOW()),
(101, '安踏足球鞋', 19, '安踏', 299.00, 429.00, 200, 80, '安踏足球鞋 碎钉 人造草地', 'https://picsum.photos/400/400?random=101', '[]', 0, 1, 1, 14, NOW(), NOW()),
(102, '安踏双肩背包', 20, '安踏', 159.00, 249.00, 300, 150, '安踏双肩包 学生书包', 'https://picsum.photos/400/400?random=102', '[]', 0, 0, 1, 14, NOW(), NOW()),
(103, '安踏运动长裤', 29, '安踏', 199.00, 299.00, 350, 160, '安踏运动长裤 束脚卫裤', 'https://picsum.photos/400/400?random=103', '[]', 1, 0, 1, 14, NOW(), NOW()),
(104, '安踏运动袜 3双装', 15, '安踏', 39.90, 59.90, 600, 300, '安踏运动袜 中筒 3双装', 'https://picsum.photos/400/400?random=104', '[]', 0, 1, 1, 14, NOW(), NOW());

-- ============================================================
-- 十九、兰蔻官方旗舰店商品（merchant_id=15）
-- ============================================================

INSERT IGNORE INTO product (id, name, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(105, '兰蔻小黑瓶精华 50ml', 21, '兰蔻', 1080.00, 1280.00, 200, 120, '兰蔻小黑瓶 精华肌底液 50ml', 'https://picsum.photos/400/400?random=105', '[]', 1, 0, 1, 15, NOW(), NOW()),
(106, '兰蔻粉水 400ml', 21, '兰蔻', 480.00, 580.00, 300, 180, '兰蔻清滢柔肤水 粉水 400ml', 'https://picsum.photos/400/400?random=106', '[]', 1, 1, 1, 15, NOW(), NOW()),
(107, '兰蔻196口红', 22, '兰蔻', 320.00, 380.00, 400, 250, '兰蔻菁纯口红 196 朱砂橘', 'https://picsum.photos/400/400?random=107', '[]', 1, 0, 1, 15, NOW(), NOW()),
(108, '兰蔻菁纯眼霜 20ml', 21, '兰蔻', 1180.00, 1380.00, 150, 70, '兰蔻菁纯眼霜 20ml 抗皱紧致', 'https://picsum.photos/400/400?random=108', '[]', 0, 1, 1, 15, NOW(), NOW()),
(109, '兰蔻极光水 150ml', 21, '兰蔻', 830.00, 980.00, 200, 90, '兰蔻极光水 净澈焕肤 150ml', 'https://picsum.photos/400/400?random=109', '[]', 0, 0, 1, 15, NOW(), NOW()),
(110, '兰蔻奇迹香水 30ml', 23, '兰蔻', 580.00, 680.00, 250, 110, '兰蔻奇迹香水 女士淡香 30ml', 'https://picsum.photos/400/400?random=110', '[]', 1, 0, 1, 15, NOW(), NOW()),
(111, '兰蔻防晒霜 50ml', 21, '兰蔻', 480.00, 560.00, 300, 140, '兰蔻小白管 轻透防晒 50ml', 'https://picsum.photos/400/400?random=111', '[]', 0, 1, 1, 15, NOW(), NOW()),
(112, '兰蔻洁面泡沫 125ml', 21, '兰蔻', 350.00, 420.00, 350, 160, '兰蔻臻白洁面泡沫 125ml', 'https://picsum.photos/400/400?random=112', '[]', 0, 0, 1, 15, NOW(), NOW());

-- ============================================================
-- 二十、店铺优惠券
-- ============================================================

-- 小米店铺券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('小米旗舰店满500减50', 4, 1, 50.00, 500.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '小米官方旗舰店全店满500减50', 2, 2, 1, 0, NOW(), NOW()),
('小米旗舰店满2000减200', 4, 1, 200.00, 2000.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '小米官方旗舰店全店满2000减200', 2, 2, 1, 0, NOW(), NOW()),
('小米14系列专属300券', 4, 1, 300.00, 5000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '仅小米14系列手机可用', 3, 3, 1, 0, NOW(), NOW());

-- 名创优品优惠券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('名创优品满59减10', 5, 1, 10.00, 59.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '名创优品全店满59减10', 2, 2, 1, 0, NOW(), NOW()),
('名创优品满99减20', 5, 1, 20.00, 99.00, 8000, 8000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '名创优品全店满99减20', 2, 2, 1, 0, NOW(), NOW());

-- 三只松鼠优惠券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('三只松鼠满69减10', 6, 1, 10.00, 69.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '三只松鼠全店满69减10', 2, 2, 1, 0, NOW(), NOW()),
('三只松鼠满129减25', 6, 1, 25.00, 129.00, 6000, 6000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '三只松鼠全店满129减25', 2, 2, 1, 0, NOW(), NOW()),
('坚果品类专享券', 6, 1, 15.00, 89.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '坚果品类专用 满89减15', 4, 2, 1, 0, NOW(), NOW());

-- 完美日记优惠券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('完美日记满99减15', 7, 1, 15.00, 99.00, 8000, 8000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '完美日记全店满99减15', 2, 2, 1, 0, NOW(), NOW()),
('完美日记满199减40', 7, 1, 40.00, 199.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '完美日记全店满199减40', 2, 2, 1, 0, NOW(), NOW()),
('新人首单立减20', 7, 1, 20.00, 50.00, 10000, 10000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY), 1, '完美日记新用户首单立减20', 2, 2, 1, 1, NOW(), NOW());

-- 华为店铺券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('华为满1000减100', 3, 1, 100.00, 1000.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '华为旗舰店满1000减100', 2, 2, 1, 0, NOW(), NOW()),
('华为满3000减300', 3, 1, 300.00, 3000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '华为旗舰店满3000减300', 2, 2, 1, 0, NOW(), NOW());

-- 李宁店铺券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('李宁满299减30', 8, 1, 30.00, 299.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '李宁旗舰店满299减30', 2, 2, 1, 0, NOW(), NOW()),
('李宁满599减80', 8, 1, 80.00, 599.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '李宁旗舰店满599减80', 2, 2, 1, 0, NOW(), NOW());

-- Nike店铺券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('Nike满500减50', 9, 1, 50.00, 500.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 'Nike旗舰店满500减50', 2, 2, 1, 0, NOW(), NOW()),
('Nike满1000减120', 9, 1, 120.00, 1000.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 'Nike旗舰店满1000减120', 2, 2, 1, 0, NOW(), NOW());

-- 当当图书券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('当当满99减10', 10, 1, 10.00, 99.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '当当图书满99减10', 2, 2, 1, 0, NOW(), NOW()),
('当当满199减30', 10, 1, 30.00, 199.00, 5000, 5000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '当当图书满199减30', 2, 2, 1, 0, NOW(), NOW());

-- 孩子王券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('孩子王满199减20', 11, 1, 20.00, 199.00, 8000, 8000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '孩子王满199减20', 2, 2, 1, 0, NOW(), NOW()),
('孩子王满499减60', 11, 1, 60.00, 499.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '孩子王满499减60', 2, 2, 1, 0, NOW(), NOW());

-- 良品铺子券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('良品铺子满59减10', 12, 1, 10.00, 59.00, 10000, 10000, 3, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '良品铺子满59减10', 2, 2, 1, 0, NOW(), NOW()),
('良品铺子满129减25', 12, 1, 25.00, 129.00, 5000, 5000, 2, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '良品铺子满129减25', 2, 2, 1, 0, NOW(), NOW());

-- 宜家家居券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('宜家满299减30', 13, 1, 30.00, 299.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '宜家家居满299减30', 2, 2, 1, 0, NOW(), NOW()),
('宜家满999减120', 13, 1, 120.00, 999.00, 2000, 2000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '宜家家居满999减120', 2, 2, 1, 0, NOW(), NOW());

-- 安踏店铺券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('安踏满299减40', 14, 1, 40.00, 299.00, 5000, 5000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '安踏旗舰店满299减40', 2, 2, 1, 0, NOW(), NOW()),
('安踏满599减90', 14, 1, 90.00, 599.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '安踏旗舰店满599减90', 2, 2, 1, 0, NOW(), NOW());

-- 兰蔻店铺券
INSERT IGNORE INTO coupon_template (name, merchant_id, type, discount_amount, min_amount, total_count, remaining_count, per_user_limit, start_time, end_time, status, description, scope_type, coupon_level, mutually_exclusive, user_type, created_at, updated_at) VALUES
('兰蔻满500减60', 15, 1, 60.00, 500.00, 3000, 3000, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '兰蔻旗舰店满500减60', 2, 2, 1, 0, NOW(), NOW()),
('兰蔻满1000减150', 15, 1, 150.00, 1000.00, 1500, 1500, 1, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, '兰蔻旗舰店满1000减150', 2, 2, 1, 0, NOW(), NOW());
