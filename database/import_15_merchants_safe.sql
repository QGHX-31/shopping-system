-- ============================================================
-- 15商家数据导入脚本（安全版）
-- ⚠️ 重要：本脚本使用 INSERT IGNORE，不会删除任何现有数据！
-- 执行顺序：
-- 1. 如果分类表为空，先执行 schema.sql 中的分类插入
-- 2. 再执行本文件
-- ============================================================

USE shopping_system;

-- ============================================================
-- 一、插入15个商家数据
-- ============================================================

INSERT IGNORE INTO merchant (id, username, password, shop_name, logo, contact_name, contact_phone, email, address, status, level, created_at, updated_at) VALUES
-- 1. Apple官方旗舰店
(1, 'merchant01', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'Apple官方旗舰店', NULL, '张经理', '13800001111', 'service@apple.com', '上海市浦东新区张江高科技园区', 1, 5, NOW(), NOW()),
-- 2. 优衣库官方旗舰店
(2, 'merchant02', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '优衣库官方旗舰店', NULL, '李经理', '13800002222', 'service@uniqlo.com', '上海市徐汇区虹桥路', 1, 4, NOW(), NOW()),
-- 3. 华为官方旗舰店
(3, 'merchant03', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '华为官方旗舰店', NULL, '华为客服', '400-830-8300', 'service@huawei.com', '广东省深圳市龙岗区坂田华为基地', 1, 5, NOW(), NOW()),
-- 4. 小米官方旗舰店
(4, 'merchant04', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '小米官方旗舰店', NULL, '小米客服', '400-100-5678', 'service@xiaomi.com', '北京市海淀区清河', 1, 5, NOW(), NOW()),
-- 5. 名创优品官方店
(5, 'merchant05', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '名创优品官方店', NULL, '名创客服', '400-123-4567', 'service@miniso.com', '广东省广州市', 1, 3, NOW(), NOW()),
-- 6. 三只松鼠旗舰店
(6, 'merchant06', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '三只松鼠旗舰店', NULL, '松鼠客服', '400-800-1234', 'service@sanzhi.com', '安徽省芜湖市', 1, 4, NOW(), NOW()),
-- 7. 完美日记旗舰店
(7, 'merchant07', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '完美日记旗舰店', NULL, '完美日记客服', '400-600-8888', 'service@perfect.com', '广东省广州市', 1, 4, NOW(), NOW()),
-- 8. 李宁官方旗舰店
(8, 'merchant08', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '李宁官方旗舰店', NULL, '李宁客服', '400-610-0011', 'service@lining.com', '北京市通州区李宁工业园', 1, 4, NOW(), NOW()),
-- 9. Nike耐克官方旗舰店
(9, 'merchant09', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', 'Nike耐克官方旗舰店', NULL, 'Nike客服', '400-880-6453', 'service@nike.com', '上海市静安区南京西路', 1, 5, NOW(), NOW()),
-- 10. 当当图书旗舰店
(10, 'merchant10', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '当当图书旗舰店', NULL, '当当客服', '400-106-6666', 'service@dangdang.com', '北京市朝阳区安慧里', 1, 3, NOW(), NOW()),
-- 11. 孩子王官方旗舰店
(11, 'merchant11', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '孩子王官方旗舰店', NULL, '孩子王客服', '400-888-9999', 'service@haiziwang.com', '南京市建邺区新城科技园', 1, 3, NOW(), NOW()),
-- 12. 良品铺子旗舰店
(12, 'merchant12', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '良品铺子旗舰店', NULL, '良品客服', '400-117-7577', 'service@liangpinpuzi.com', '湖北省武汉市东西湖区', 1, 3, NOW(), NOW()),
-- 13. 宜家家居旗舰店
(13, 'merchant13', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '宜家家居旗舰店', NULL, '宜家客服', '400-800-2345', 'service@ikea.com', '上海市徐汇区漕溪路', 1, 4, NOW(), NOW()),
-- 14. 安踏官方旗舰店
(14, 'merchant14', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '安踏官方旗舰店', NULL, '安踏客服', '400-886-8888', 'service@anta.com', '福建省泉州市晋江市', 1, 4, NOW(), NOW()),
-- 15. 兰蔻官方旗舰店
(15, 'merchant15', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de', '兰蔻官方旗舰店', NULL, '兰蔻客服', '400-820-8088', 'service@lancome.com', '上海市静安区南京西路', 1, 5, NOW(), NOW());

-- ============================================================
-- 二、插入商品数据（15个商家，每个商家6-8个商品）
-- ============================================================

-- Apple店铺商品（merchant_id=1）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(1, 'iPhone 15 Pro Max', 'A17 Pro芯片 钛金属设计', 11, 'Apple', 9999.00, 10999.00, 80, 40, 'iPhone 15 Pro Max 256GB 深空黑', 'https://picsum.photos/400/400?random=1', '[]', 1, 1, 1, 1, NOW(), NOW()),
(2, 'MacBook Pro 14英寸', 'M3 Pro芯片 专业级性能', 21, 'Apple', 14999.00, 16499.00, 60, 25, 'MacBook Pro 14寸 M3 Pro 18+512GB', 'https://picsum.photos/400/400?random=2', '[]', 1, 1, 1, 1, NOW(), NOW()),
(3, 'iPad Pro 12.9英寸', 'M2芯片 Liquid视网膜XDR屏', 12, 'Apple', 9299.00, 10299.00, 100, 35, 'iPad Pro 12.9寸 M2 256GB', 'https://picsum.photos/400/400?random=3', '[]', 1, 0, 1, 1, NOW(), NOW()),
(4, 'Apple Watch Series 9', 'S9芯片 精准健康监测', 13, 'Apple', 2999.00, 3199.00, 150, 70, 'Apple Watch Series 9 GPS款 45mm', 'https://picsum.photos/400/400?random=4', '[]', 1, 1, 1, 1, NOW(), NOW()),
(5, 'AirPods Pro 2代', '主动降噪 自适应音频', 14, 'Apple', 1899.00, 2099.00, 200, 90, 'AirPods Pro 第二代 USB-C', 'https://picsum.photos/400/400?random=5', '[]', 1, 0, 1, 1, NOW(), NOW()),
(6, 'Mac mini M2', '小巧精致 性能强劲', 21, 'Apple', 4499.00, 4999.00, 80, 30, 'Mac mini M2 8+256GB', 'https://picsum.photos/400/400?random=6', '[]', 0, 1, 1, 1, NOW(), NOW()),
(7, 'iPhone 15', '灵动岛 A16芯片', 11, 'Apple', 5999.00, 6499.00, 120, 55, 'iPhone 15 128GB 蓝色', 'https://picsum.photos/400/400?random=7', '[]', 1, 0, 1, 1, NOW(), NOW()),
(8, 'AirPods Max', '头戴式降噪耳机', 14, 'Apple', 3999.00, 4399.00, 100, 40, 'AirPods Max 银色', 'https://picsum.photos/400/400?random=8', '[]', 1, 0, 1, 1, NOW(), NOW());

-- 优衣库店铺商品（merchant_id=2）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(9, '优衣库圆领T恤', '纯棉舒适 多色可选', 31, 'UNIQLO', 99.00, 149.00, 500, 280, '优衣库男士圆领T恤 纯棉基础款', 'https://picsum.photos/400/400?random=9', '[]', 1, 0, 1, 2, NOW(), NOW()),
(10, '优衣库牛仔裤', '修身剪裁 经典款式', 31, 'UNIQLO', 199.00, 299.00, 400, 200, '优衣库男士牛仔裤 直筒版型', 'https://picsum.photos/400/400?random=10', '[]', 0, 0, 1, 2, NOW(), NOW()),
(11, '优衣库连衣裙', '夏季新款 简约时尚', 32, 'UNIQLO', 249.00, 349.00, 300, 150, '优衣库女士连衣裙 通勤款', 'https://picsum.photos/400/400?random=11', '[]', 1, 1, 1, 2, NOW(), NOW()),
(12, '优衣库衬衫', '商务休闲 易于搭配', 31, 'UNIQLO', 149.00, 249.00, 350, 160, '优衣库男士长袖衬衫', 'https://picsum.photos/400/400?random=12', '[]', 0, 0, 1, 2, NOW(), NOW()),
(13, '优衣库卫衣', '加绒保暖 休闲百搭', 31, 'UNIQLO', 199.00, 299.00, 300, 140, '优衣库连帽卫衣', 'https://picsum.photos/400/400?random=13', '[]', 1, 0, 1, 2, NOW(), NOW()),
(14, '优衣库女款针织衫', '柔软舒适 春秋必备', 32, 'UNIQLO', 179.00, 279.00, 250, 120, '优衣库女士针织开衫', 'https://picsum.photos/400/400?random=14', '[]', 0, 1, 1, 2, NOW(), NOW()),
(15, '优衣库运动短裤', '速干透气 运动舒适', 33, 'UNIQLO', 99.00, 149.00, 400, 180, '优衣库男士运动短裤', 'https://picsum.photos/400/400?random=15', '[]', 0, 0, 1, 2, NOW(), NOW()),
(16, '优衣库保暖内衣', 'HeatTech发热技术', 31, 'UNIQLO', 149.00, 199.00, 450, 200, '优衣库HeatTech保暖内衣套装', 'https://picsum.photos/400/400?random=16', '[]', 1, 0, 1, 2, NOW(), NOW());

-- 华为店铺商品（merchant_id=3）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(17, 'HUAWEI Mate 60 Pro+', '麒麟9000S 卫星通话', 11, '华为', 8999.00, 9999.00, 150, 60, '华为Mate60 Pro+ 16GB+1TB 砚黑', 'https://picsum.photos/400/400?random=17', '[]', 1, 1, 1, 3, NOW(), NOW()),
(18, 'HUAWEI Pura 70 Ultra', '超聚光伸缩镜头 影像旗舰', 11, '华为', 9999.00, 10999.00, 80, 25, '华为Pura70 Ultra 16GB+512GB', 'https://picsum.photos/400/400?random=18', '[]', 1, 1, 1, 3, NOW(), NOW()),
(19, '华为 MatePad Pro 13.2', '鸿蒙系统 生产力工具', 12, '华为', 5499.00, 5999.00, 100, 40, '华为MatePad Pro 13.2英寸', 'https://picsum.photos/400/400?random=19', '[]', 1, 0, 1, 3, NOW(), NOW()),
(20, '华为 FreeBuds Pro 3', '主动降噪 Hi-Res音质', 14, '华为', 1299.00, 1499.00, 300, 120, '华为FreeBuds Pro 3 星河蓝', 'https://picsum.photos/400/400?random=20', '[]', 1, 1, 1, 3, NOW(), NOW()),
(21, '华为 Watch GT 4', '14天续航 专业健康监测', 13, '华为', 1488.00, 1688.00, 200, 80, '华为Watch GT 4 46mm', 'https://picsum.photos/400/400?random=21', '[]', 0, 1, 1, 3, NOW(), NOW()),
(22, '华为 MateBook X Pro', '超轻薄 3.1K原色屏', 21, '华为', 11999.00, 12999.00, 60, 15, '华为MateBook X Pro 2024款', 'https://picsum.photos/400/400?random=22', '[]', 0, 0, 1, 3, NOW(), NOW()),
(23, '华为 nova 12 Pro', '前置6000万 追焦双摄', 11, '华为', 3999.00, 4499.00, 250, 90, '华为nova 12 Pro 256GB', 'https://picsum.photos/400/400?random=23', '[]', 0, 1, 1, 3, NOW(), NOW());

-- 小米店铺商品（merchant_id=4）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(24, '小米14 Ultra', '徕卡专业影像 骁龙8 Gen3', 11, '小米', 6499.00, 6999.00, 200, 80, '小米14 Ultra 徕卡光学Summilux镜头', 'https://picsum.photos/400/400?random=24', '[]', 1, 1, 1, 4, NOW(), NOW()),
(25, '小米电视 S Pro 75英寸', 'Mini LED 高画质', 3, '小米', 4999.00, 5999.00, 100, 30, '小米电视 S Pro 75英寸 Mini LED', 'https://picsum.photos/400/400?random=25', '[]', 0, 1, 1, 4, NOW(), NOW()),
(26, '小米手环 8 Pro', '大屏长续航 运动健康', 13, '小米', 379.00, 429.00, 500, 200, '小米手环8 Pro 黑色', 'https://picsum.photos/400/400?random=26', '[]', 1, 0, 1, 4, NOW(), NOW()),
(27, '米家空气净化器 4 Pro', '除甲醛 智能互联', 3, '小米', 1499.00, 1699.00, 150, 60, '米家空气净化器4 Pro', 'https://picsum.photos/400/400?random=27', '[]', 0, 0, 1, 4, NOW(), NOW()),
(28, '小米保温杯', '316不锈钢 大容量便携', 4, '小米', 89.00, 129.00, 800, 300, '小米保温杯 500ml', 'https://picsum.photos/400/400?random=28', '[]', 1, 0, 1, 4, NOW(), NOW()),
(29, 'RedmiBook Pro 15', '标压处理器 高性能轻薄本', 21, '小米', 4999.00, 5499.00, 120, 40, 'RedmiBook Pro 15 2024款', 'https://picsum.photos/400/400?random=29', '[]', 0, 1, 1, 4, NOW(), NOW()),
(30, '小米电动牙刷 T700', '声波震动 智能洁齿', 4, '小米', 299.00, 349.00, 300, 120, '小米电动牙刷T700', 'https://picsum.photos/400/400?random=30', '[]', 0, 0, 1, 4, NOW(), NOW()),
(31, 'Redmi Watch 4', '大屏 AMOLED 智能手表', 13, '小米', 599.00, 699.00, 250, 90, 'Redmi Watch 4', 'https://picsum.photos/400/400?random=31', '[]', 1, 1, 1, 4, NOW(), NOW());

-- 名创优品店铺商品（merchant_id=5）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(32, '名创优品香薰蜡烛', '天然植物精油 持久留香', 41, 'MINISO', 39.90, 59.90, 600, 250, '香薰蜡烛 100g 多种香型', 'https://picsum.photos/400/400?random=32', '[]', 1, 0, 1, 5, NOW(), NOW()),
(33, '可爱毛绒玩偶', '柔软亲肤 送礼自用', 41, 'MINISO', 29.90, 49.90, 1000, 450, '可爱毛绒玩偶 20cm', 'https://picsum.photos/400/400?random=33', '[]', 1, 1, 1, 5, NOW(), NOW()),
(34, '收纳整理盒三件套', '桌面收纳 整洁有序', 41, 'MINISO', 49.90, 79.90, 400, 180, '收纳盒三件套 透明可视', 'https://picsum.photos/400/400?random=34', '[]', 0, 0, 1, 5, NOW(), NOW()),
(35, '保湿补水面膜 10片装', '深层补水 肌肤焕亮', 42, 'MINISO', 59.90, 89.90, 500, 220, '补水面膜 10片装', 'https://picsum.photos/400/400?random=35', '[]', 1, 0, 1, 5, NOW(), NOW()),
(36, '保温杯 350ml', '迷你便携 304不锈钢', 41, 'MINISO', 39.90, 59.90, 700, 280, 'MINISO保温杯 350ml', 'https://picsum.photos/400/400?random=36', '[]', 0, 1, 1, 5, NOW(), NOW()),
(37, 'MINISO笔记本套装', '简约设计 文具礼盒', 43, 'MINISO', 24.90, 39.90, 800, 320, 'MINISO笔记本套装 3本装', 'https://picsum.photos/400/400?random=37', '[]', 0, 0, 1, 5, NOW(), NOW()),
(38, '名创优品护手霜套装', '滋润保湿 迷你便携', 42, 'MINISO', 19.90, 29.90, 600, 280, '护手霜套装 3支装', 'https://picsum.photos/400/400?random=38', '[]', 1, 0, 1, 5, NOW(), NOW());

-- 三只松鼠店铺商品（merchant_id=6）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(39, '三只松鼠每日坚果 750g', '8种坚果 科学配比', 51, '三只松鼠', 89.90, 129.90, 500, 300, '每日坚果 750g 30包', 'https://picsum.photos/400/400?random=39', '[]', 1, 0, 1, 6, NOW(), NOW()),
(40, '三只松鼠夏威夷果', '奶油味 开口易剥', 51, '三只松鼠', 39.90, 59.90, 600, 250, '夏威夷果 265g 奶油味', 'https://picsum.photos/400/400?random=40', '[]', 1, 0, 1, 6, NOW(), NOW()),
(41, '三只松鼠辣条大礼包', '网红零食 怀旧味道', 51, '三只松鼠', 29.90, 49.90, 800, 400, '辣条大礼包 520g', 'https://picsum.photos/400/400?random=41', '[]', 1, 1, 1, 6, NOW(), NOW()),
(42, '三只松鼠碧根果', '奶油味 醇香酥脆', 51, '三只松鼠', 45.90, 65.90, 400, 180, '碧根果 210g 奶油味', 'https://picsum.photos/400/400?random=42', '[]', 0, 0, 1, 6, NOW(), NOW()),
(43, '三只松鼠水果干组合', '芒果草莓 酸甜可口', 51, '三只松鼠', 59.90, 89.90, 350, 150, '水果干组合 400g', 'https://picsum.photos/400/400?random=43', '[]', 0, 1, 1, 6, NOW(), NOW()),
(44, '三只松鼠牛肉干', '香辣味 嚼劲十足', 51, '三只松鼠', 69.90, 99.90, 300, 120, '牛肉干 200g 香辣味', 'https://picsum.photos/400/400?random=44', '[]', 0, 0, 1, 6, NOW(), NOW()),
(45, '三只松鼠开心果', '盐焗味 自然开口', 51, '三只松鼠', 49.90, 69.90, 450, 190, '开心果 265g 盐焗味', 'https://picsum.photos/400/400?random=45', '[]', 1, 0, 1, 6, NOW(), NOW());

-- 完美日记店铺商品（merchant_id=7）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(46, '完美日记小细跟口红', '丝绒哑光 高级质感', 42, '完美日记', 99.00, 129.00, 400, 220, '小细跟口红 3.6g 多色可选', 'https://picsum.photos/400/400?random=46', '[]', 1, 0, 1, 7, NOW(), NOW()),
(47, '完美日记动物眼影盘', '12色大盘 日常百搭', 42, '完美日记', 129.00, 169.00, 300, 150, '动物眼影盘 12g 瓦塔吉限定', 'https://picsum.photos/400/400?random=47', '[]', 1, 1, 1, 7, NOW(), NOW()),
(48, '完美日记氨基酸洗面奶', '温和清洁 补水保湿', 42, '完美日记', 59.90, 79.90, 500, 200, '氨基酸洗面奶 150ml', 'https://picsum.photos/400/400?random=48', '[]', 0, 0, 1, 7, NOW(), NOW()),
(49, '完美日记天鹅绒唇釉', '哑光丝绒 持久不脱妆', 42, '完美日记', 79.90, 99.90, 450, 180, '天鹅绒唇釉 3.5g', 'https://picsum.photos/400/400?random=49', '[]', 1, 0, 1, 7, NOW(), NOW()),
(50, '完美日记气垫BB霜', '遮瑕保湿 打造裸妆', 42, '完美日记', 119.00, 159.00, 350, 130, '气垫BB霜 15g*2', 'https://picsum.photos/400/400?random=50', '[]', 0, 1, 1, 7, NOW(), NOW()),
(51, '完美日记名片香水', '淡香持久 约会必备', 42, '完美日记', 89.00, 129.00, 200, 80, '名片香水 15ml', 'https://picsum.photos/400/400?random=51', '[]', 0, 0, 1, 7, NOW(), NOW());

-- 李宁店铺商品（merchant_id=8）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(52, '李宁篮球鞋 闪击8', '实战减震 耐磨防滑', 33, '李宁', 599.00, 799.00, 300, 150, '李宁闪击8篮球鞋 专业实战', 'https://picsum.photos/400/400?random=52', '[]', 1, 0, 1, 8, NOW(), NOW()),
(53, '李宁运动T恤', '速干透气 运动舒适', 33, '李宁', 149.00, 249.00, 500, 280, '李宁运动T恤 男款', 'https://picsum.photos/400/400?random=53', '[]', 1, 1, 1, 8, NOW(), NOW()),
(54, '李宁羽毛球拍', '碳素超轻 攻防兼备', 33, '李宁', 399.00, 599.00, 200, 90, '李宁羽毛球拍 碳纤维', 'https://picsum.photos/400/400?random=54', '[]', 0, 0, 1, 8, NOW(), NOW()),
(55, '李宁跑鞋 赤兔6', '轻量竞速 专业跑步', 33, '李宁', 499.00, 699.00, 400, 200, '李宁赤兔6跑鞋', 'https://picsum.photos/400/400?random=55', '[]', 1, 1, 1, 8, NOW(), NOW()),
(56, '李宁运动裤', '速干透气 弹力舒适', 33, '李宁', 199.00, 299.00, 350, 160, '李宁运动长裤 男款', 'https://picsum.photos/400/400?random=56', '[]', 0, 0, 1, 8, NOW(), NOW()),
(57, '李宁双肩背包', '大容量 多隔层', 33, '李宁', 179.00, 279.00, 250, 110, '李宁双肩背包 30L', 'https://picsum.photos/400/400?random=57', '[]', 0, 1, 1, 8, NOW(), NOW()),
(58, '李宁卫衣', '加绒保暖 休闲运动', 33, '李宁', 299.00, 449.00, 300, 130, '李宁套头卫衣', 'https://picsum.photos/400/400?random=58', '[]', 1, 0, 1, 8, NOW(), NOW());

-- Nike耐克店铺商品（merchant_id=9）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(59, 'Nike Air Jordan 1', '经典篮球鞋 时尚百搭', 33, 'Nike', 1299.00, 1599.00, 150, 80, 'Air Jordan 1 MID 黑红', 'https://picsum.photos/400/400?random=59', '[]', 1, 0, 1, 9, NOW(), NOW()),
(60, 'Nike Air Force 1', '小白鞋经典 永恒时尚', 33, 'Nike', 799.00, 899.00, 300, 180, 'Air Force 1 07 白色', 'https://picsum.photos/400/400?random=60', '[]', 1, 1, 1, 9, NOW(), NOW()),
(61, 'Nike Pro运动T恤', '紧身速干 专业运动', 33, 'Nike', 229.00, 299.00, 500, 250, 'Nike Pro男子紧身T恤', 'https://picsum.photos/400/400?random=61', '[]', 1, 0, 1, 9, NOW(), NOW()),
(62, 'Nike Pegasus 40', '缓震跑步鞋 日常训练', 33, 'Nike', 899.00, 1099.00, 250, 120, 'Nike Pegasus 40 男子跑鞋', 'https://picsum.photos/400/400?random=62', '[]', 0, 1, 1, 9, NOW(), NOW()),
(63, 'Nike运动短裤', '速干透气 运动自如', 33, 'Nike', 199.00, 259.00, 400, 200, 'Nike男子运动短裤', 'https://picsum.photos/400/400?random=63', '[]', 0, 0, 1, 9, NOW(), NOW()),
(64, 'Nike双肩包', '大容量 背负舒适', 33, 'Nike', 349.00, 449.00, 200, 90, 'Nike男子双肩背包', 'https://picsum.photos/400/400?random=64', '[]', 1, 0, 1, 9, NOW(), NOW()),
(65, 'Nike篮球', '室内外通用 耐磨耐打', 33, 'Nike', 199.00, 299.00, 300, 140, 'Nike标准7号篮球', 'https://picsum.photos/400/400?random=65', '[]', 0, 0, 1, 9, NOW(), NOW());

-- 当当图书店铺商品（merchant_id=10）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(66, '三体全集 套装3册', '刘慈欣科幻巅峰之作', 71, '当当', 83.00, 168.00, 500, 320, '三体全集1-3 正版精装', 'https://picsum.photos/400/400?random=66', '[]', 1, 0, 1, 10, NOW(), NOW()),
(67, '活着 余华', '人生必读经典文学', 71, '当当', 21.00, 45.00, 800, 500, '活着 余华代表作', 'https://picsum.photos/400/400?random=67', '[]', 1, 1, 1, 10, NOW(), NOW()),
(68, '百年孤独', '诺贝尔文学奖经典', 71, '当当', 39.50, 79.00, 600, 280, '百年孤独 加西亚·马尔克斯', 'https://picsum.photos/400/400?random=68', '[]', 0, 0, 1, 10, NOW(), NOW()),
(69, '新华字典 第12版', '权威工具书 学习必备', 71, '当当', 19.90, 32.80, 1000, 600, '新华字典 第12版 商务印书馆', 'https://picsum.photos/400/400?random=69', '[]', 1, 0, 1, 10, NOW(), NOW()),
(70, '晨光中性笔12支装', '顺滑书写 考试必备', 71, '晨光', 19.90, 29.90, 1000, 450, '晨光中性笔 12支 黑色', 'https://picsum.photos/400/400?random=70', '[]', 1, 1, 1, 10, NOW(), NOW()),
(71, '得力笔记本A5 5本装', '优质纸张 书写流畅', 71, '得力', 29.90, 49.90, 800, 380, '得力笔记本 A5 5本装', 'https://picsum.photos/400/400?random=71', '[]', 0, 0, 1, 10, NOW(), NOW()),
(72, '小王子', '儿童文学经典', 71, '当当', 19.90, 39.80, 700, 350, '小王子 圣埃克苏佩里', 'https://picsum.photos/400/400?random=72', '[]', 1, 0, 1, 10, NOW(), NOW());

-- 孩子王店铺商品（merchant_id=11）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(73, '爱他美奶粉 3段 800g', '德国原装 宝宝健康', 61, '爱他美', 258.00, 328.00, 400, 220, '爱他美经典版 3段 800g', 'https://picsum.photos/400/400?random=73', '[]', 1, 0, 1, 11, NOW(), NOW()),
(74, '帮宝适纸尿裤 L码', '超薄干爽 整夜安睡', 61, '帮宝适', 99.00, 149.00, 600, 350, '帮宝适超薄干爽 L码 72片', 'https://picsum.photos/400/400?random=74', '[]', 1, 1, 1, 11, NOW(), NOW()),
(75, '费雪海马安抚玩偶', '声光安抚 哄睡神器', 61, '费雪', 129.00, 169.00, 300, 150, '费雪声光安抚小海马', 'https://picsum.photos/400/400?random=75', '[]', 0, 0, 1, 11, NOW(), NOW()),
(76, '惠氏启赋奶粉 2段', '亲和人体 宝宝易吸收', 61, '惠氏', 388.00, 488.00, 300, 140, '惠氏启赋蓝钻 2段 900g', 'https://picsum.photos/400/400?random=76', '[]', 0, 1, 1, 11, NOW(), NOW()),
(77, '婴儿湿巾 80抽x5包', '手口可用 柔软亲肤', 61, '好奇', 49.90, 79.90, 500, 280, '婴儿手口湿巾 80抽*5包', 'https://picsum.photos/400/400?random=77', '[]', 1, 0, 1, 11, NOW(), NOW()),
(78, '好孩子婴儿推车', '轻便折叠 一键收车', 61, '好孩子', 899.00, 1299.00, 150, 60, '好孩子婴儿推车 轻便型', 'https://picsum.photos/400/400?random=78', '[]', 0, 0, 1, 11, NOW(), NOW()),
(79, '飞鹤奶粉 1段 900g', '新鲜生牛乳 宝宝辅食', 61, '飞鹤', 308.00, 398.00, 350, 160, '飞鹤星飞帆 1段 900g', 'https://picsum.photos/400/400?random=79', '[]', 1, 0, 1, 11, NOW(), NOW());

-- 良品铺子店铺商品（merchant_id=12）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(80, '良品铺子每日坚果 750g', '8种坚果 科学配比', 51, '良品铺子', 89.90, 129.00, 500, 280, '每日坚果 30包 750g', 'https://picsum.photos/400/400?random=80', '[]', 1, 0, 1, 12, NOW(), NOW()),
(81, '良品铺子猪肉脯 200g', '自然片 越嚼越香', 51, '良品铺子', 39.90, 59.90, 600, 320, '猪肉脯 自然片 200g', 'https://picsum.photos/400/400?random=81', '[]', 1, 1, 1, 12, NOW(), NOW()),
(82, '良品铺子芒果干 108g', '厚切大片 酸甜可口', 51, '良品铺子', 25.90, 39.90, 800, 450, '芒果干 108g', 'https://picsum.photos/400/400?random=82', '[]', 0, 0, 1, 12, NOW(), NOW()),
(83, '良品铺子鸭脖 190g', '卤味零食 麻辣鲜香', 51, '良品铺子', 32.90, 49.90, 500, 250, '鸭脖 190g 麻辣味', 'https://picsum.photos/400/400?random=83', '[]', 1, 0, 1, 12, NOW(), NOW()),
(84, '良品铺子手撕面包 1kg', '早餐糕点 营养美味', 51, '良品铺子', 29.90, 49.90, 700, 380, '手撕面包 1kg', 'https://picsum.photos/400/400?random=84', '[]', 1, 1, 1, 12, NOW(), NOW()),
(85, '良品铺子夏威夷果 238g', '奶油味 开口易剥', 51, '良品铺子', 45.90, 65.90, 400, 180, '夏威夷果 238g 奶油味', 'https://picsum.photos/400/400?random=85', '[]', 0, 0, 1, 12, NOW(), NOW()),
(86, '良品铺子牛板筋 150g', '烧烤味 嚼劲十足', 51, '良品铺子', 35.90, 55.90, 450, 200, '牛板筋 150g 烧烤味', 'https://picsum.photos/400/400?random=86', '[]', 0, 1, 1, 12, NOW(), NOW());

-- 宜家家居店铺商品（merchant_id=13）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(87, '宜家拉克边桌', '白色简约 多场景适用', 61, '宜家', 79.00, 129.00, 400, 220, '拉克边桌 白色 55x55cm', 'https://picsum.photos/400/400?random=87', '[]', 1, 0, 1, 13, NOW(), NOW()),
(88, '宜家波昂扶手椅', '桦木贴面 舒适体验', 61, '宜家', 499.00, 699.00, 150, 60, '波昂扶手椅 桦木贴面', 'https://picsum.photos/400/400?random=88', '[]', 0, 1, 1, 13, NOW(), NOW()),
(89, '宜家被套枕套套装', '纯棉舒适 亲肤透气', 61, '宜家', 149.00, 249.00, 300, 150, '被套枕套套装 双人', 'https://picsum.photos/400/400?random=89', '[]', 1, 0, 1, 13, NOW(), NOW()),
(90, '宜家卡瓦科砧板', '竹制环保 耐用易清洗', 61, '宜家', 29.90, 49.90, 500, 280, '卡瓦科砧板 竹制 2件套', 'https://picsum.photos/400/400?random=90', '[]', 0, 0, 1, 13, NOW(), NOW()),
(91, '宜家特提亚工作灯', '可调节臂 高品质照明', 61, '宜家', 99.00, 149.00, 250, 120, '特提亚工作灯 银色', 'https://picsum.photos/400/400?random=91', '[]', 1, 1, 1, 13, NOW(), NOW()),
(92, '宜家考肯密封罐', '玻璃材质 密封保鲜', 61, '宜家', 39.90, 59.90, 600, 320, '考肯密封罐 玻璃 3件套', 'https://picsum.photos/400/400?random=92', '[]', 0, 0, 1, 13, NOW(), NOW()),
(93, '宜家记忆棉枕头', '人体工学 舒适支撑', 61, '宜家', 129.00, 199.00, 350, 160, '记忆棉枕头', 'https://picsum.photos/400/400?random=93', '[]', 1, 0, 1, 13, NOW(), NOW());

-- 安踏店铺商品（merchant_id=14）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(94, '安踏KT8篮球鞋', '汤普森签名 专业实战', 33, '安踏', 599.00, 799.00, 250, 120, '安踏KT8 汤普森战靴', 'https://picsum.photos/400/400?random=94', '[]', 1, 0, 1, 14, NOW(), NOW()),
(95, '安踏氢跑4 跑步鞋', '轻量透气 缓震舒适', 33, '安踏', 349.00, 499.00, 400, 200, '安踏氢跑4跑鞋', 'https://picsum.photos/400/400?random=95', '[]', 1, 1, 1, 14, NOW(), NOW()),
(96, '安踏运动T恤', '速干透气 运动舒适', 33, '安踏', 129.00, 199.00, 500, 280, '安踏速干T恤 男款', 'https://picsum.photos/400/400?random=96', '[]', 0, 0, 1, 14, NOW(), NOW()),
(97, '安踏运动套装', '短袖短裤 运动必备', 33, '安踏', 299.00, 449.00, 300, 140, '安踏运动套装 男款', 'https://picsum.photos/400/400?random=97', '[]', 1, 0, 1, 14, NOW(), NOW()),
(98, '安踏足球鞋', '碎钉设计 人工草地适用', 33, '安踏', 299.00, 429.00, 200, 80, '安踏足球鞋 AG碎钉', 'https://picsum.photos/400/400?random=98', '[]', 0, 1, 1, 14, NOW(), NOW()),
(99, '安踏双肩背包', '大容量 多隔层设计', 33, '安踏', 159.00, 249.00, 300, 150, '安踏双肩背包', 'https://picsum.photos/400/400?random=99', '[]', 0, 0, 1, 14, NOW(), NOW()),
(100, '安踏运动长裤', '束脚卫裤 时尚运动', 33, '安踏', 199.00, 299.00, 350, 160, '安踏运动长裤 男款', 'https://picsum.photos/400/400?random=100', '[]', 1, 0, 1, 14, NOW(), NOW());

-- 兰蔻店铺商品（merchant_id=15）
INSERT IGNORE INTO product (id, name, sub_title, category_id, brand, price, original_price, stock, sales_count, description, image_url, detail_images, is_hot, is_new, status, merchant_id, created_at, updated_at) VALUES
(101, '兰蔻小黑瓶精华 50ml', '精华肌底 肌肤焕亮', 42, '兰蔻', 1080.00, 1280.00, 200, 120, '兰蔻小黑瓶 50ml', 'https://picsum.photos/400/400?random=101', '[]', 1, 0, 1, 15, NOW(), NOW()),
(102, '兰蔻粉水 400ml', '清滢柔肤 补水保湿', 42, '兰蔻', 480.00, 580.00, 300, 180, '兰蔻粉水 400ml', 'https://picsum.photos/400/400?random=102', '[]', 1, 1, 1, 15, NOW(), NOW()),
(103, '兰蔻196口红', '朱砂橘色 高级显白', 42, '兰蔻', 320.00, 380.00, 400, 250, '兰蔻菁纯口红 196', 'https://picsum.photos/400/400?random=103', '[]', 1, 0, 1, 15, NOW(), NOW()),
(104, '兰蔻菁纯眼霜 20ml', '抗皱紧致 眼周焕亮', 42, '兰蔻', 1180.00, 1380.00, 150, 70, '兰蔻菁纯眼霜 20ml', 'https://picsum.photos/400/400?random=104', '[]', 0, 1, 1, 15, NOW(), NOW()),
(105, '兰蔻极光水 150ml', '净澈焕肤 细腻透亮', 42, '兰蔻', 830.00, 980.00, 200, 90, '兰蔻极光水 150ml', 'https://picsum.photos/400/400?random=105', '[]', 0, 0, 1, 15, NOW(), NOW()),
(106, '兰蔻奇迹香水 30ml', '女士淡香 优雅迷人', 42, '兰蔻', 580.00, 680.00, 250, 110, '兰蔻奇迹香水 30ml', 'https://picsum.photos/400/400?random=106', '[]', 1, 0, 1, 15, NOW(), NOW()),
(107, '兰蔻小白管防晒 50ml', '轻透不油腻 防晒黑', 42, '兰蔻', 480.00, 560.00, 300, 140, '兰蔻小白管防晒 50ml', 'https://picsum.photos/400/400?random=107', '[]', 0, 1, 1, 15, NOW(), NOW());

-- ============================================================
-- 三、验证数据导入
-- ============================================================

SELECT '===== 15商家数据导入完成 =====' AS '';
SELECT CONCAT('商家数量: ', COUNT(*)) FROM merchant;
SELECT CONCAT('商品数量: ', COUNT(*)) FROM product;
SELECT '商家列表:' AS '';
SELECT id, shop_name, username FROM merchant ORDER BY id;
