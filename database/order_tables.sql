-- ============================================
-- 人员3 - 订单/支付/售后/平台运营后台 数据表
-- 适用于 shopping-order-service（端口 8084）
-- 在 shopping_system 库下执行
-- ============================================

USE shopping_system;

-- ---------- 1. 订单主表 ----------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
    `id`                BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    `parent_order_id`   BIGINT DEFAULT 0 COMMENT '父订单ID，0表示主订单/普通订单',
    `order_type`        TINYINT DEFAULT 1 COMMENT '订单类型：1普通订单 2拼团订单 3秒杀订单',
    `order_no`          VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
    `user_id`           BIGINT NOT NULL COMMENT '用户ID',
    `merchant_id`       BIGINT NOT NULL COMMENT '商家ID',
    `total_amount`      DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '订单总金额（商品合计）',
    `freight_amount`    DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '运费',
    `discount_amount`   DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '优惠金额',
    `pay_amount`        DECIMAL(10,2) NOT NULL DEFAULT 0 COMMENT '实付金额',
    `coupon_id`         BIGINT COMMENT '使用的优惠券ID（user_coupon.id）',
    `coupon_ids`        VARCHAR(255) COMMENT '使用的优惠券ID列表，JSON格式如[1,2]',
    `status`            TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待支付 1已支付/待发货 2已发货 3已完成 4已取消 5退款中 6已退款 7已过期',
    `group_buy_team_id` BIGINT COMMENT '拼单团队ID',
    `group_buy_time`    DATETIME COMMENT '拼单时间',
    `address_id`        BIGINT COMMENT '收货地址ID',
    `receiver_name`     VARCHAR(50) COMMENT '收货人',
    `receiver_phone`    VARCHAR(20) COMMENT '收货人手机号',
    `receiver_address`  VARCHAR(255) COMMENT '收货地址',
    `pay_method`        TINYINT COMMENT '支付方式：1微信 2支付宝 3余额',
    `pay_trade_no`      VARCHAR(64) COMMENT '支付流水号',
    `pay_time`          DATETIME COMMENT '支付时间',
    `delivery_time`     DATETIME COMMENT '发货时间',
    `express_company`   VARCHAR(50) COMMENT '快递公司',
    `tracking_no`       VARCHAR(64) COMMENT '物流单号',
    `receive_time`      DATETIME COMMENT '确认收货时间',
    `cancel_time`       DATETIME COMMENT '取消时间',
    `cancel_reason`     VARCHAR(255) COMMENT '取消原因',
    `remark`            VARCHAR(255) COMMENT '订单备注',
    `created_at`        DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`        DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_merchant_id` (`merchant_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_coupon_id` (`coupon_id`),
    INDEX `idx_group_buy_team_id` (`group_buy_team_id`),
    INDEX `idx_parent_order_id` (`parent_order_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单主表';

-- ---------- 2. 订单明细表 ----------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '明细ID',
    `order_id`        BIGINT NOT NULL COMMENT '订单ID',
    `product_id`      BIGINT NOT NULL COMMENT '商品ID',
    `sku_id`          BIGINT COMMENT 'SKU ID',
    `merchant_id`     BIGINT COMMENT '商家ID',
    `product_name`    VARCHAR(200) NOT NULL COMMENT '商品名称（快照）',
    `product_image`   VARCHAR(255) COMMENT '商品图片（快照）',
    `spec_values`     VARCHAR(255) COMMENT '规格值（快照）',
    `price`           DECIMAL(10,2) NOT NULL COMMENT '单价（快照）',
    `quantity`        INT NOT NULL COMMENT '数量',
    `subtotal`        DECIMAL(10,2) NOT NULL COMMENT '小计',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单明细表';

-- ---------- 3. 支付记录表 ----------
DROP TABLE IF EXISTS `payment`;
CREATE TABLE `payment` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '支付ID',
    `order_id`        BIGINT NOT NULL COMMENT '订单ID',
    `order_no`        VARCHAR(50) NOT NULL COMMENT '订单号',
    `user_id`         BIGINT NOT NULL COMMENT '用户ID',
    `pay_method`      TINYINT NOT NULL COMMENT '支付方式：1微信 2支付宝 3余额',
    `pay_amount`      DECIMAL(10,2) NOT NULL COMMENT '支付金额',
    `pay_trade_no`    VARCHAR(64) COMMENT '支付平台流水号',
    `status`          TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待支付 1支付成功 2支付失败 3已退款',
    `pay_time`        DATETIME COMMENT '支付成功时间',
    `callback_time`   DATETIME COMMENT '回调时间',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uk_order_id` (`order_id`),
    INDEX `idx_order_no` (`order_no`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='支付记录表';

-- ---------- 4. 退款记录表 ----------
DROP TABLE IF EXISTS `refund`;
CREATE TABLE `refund` (
    `id`                    BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '退款ID',
    `refund_no`             VARCHAR(50) NOT NULL UNIQUE COMMENT '退款单号',
    `order_id`              BIGINT NOT NULL COMMENT '订单ID',
    `user_id`               BIGINT NOT NULL COMMENT '用户ID',
    `refund_amount`         DECIMAL(10,2) NOT NULL COMMENT '退款金额',
    `refund_reason`         VARCHAR(500) COMMENT '退款原因',
    `voucher_images`        VARCHAR(1000) DEFAULT NULL COMMENT '凭证图片，逗号分隔',
    `refund_type`           TINYINT NOT NULL COMMENT '类型：1仅退款 2退货退款',
    `status`                TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0待审核 1待退货 2已拒绝 3已完成 4已取消 5退货中',
    `merchant_remark`       VARCHAR(500) COMMENT '商家备注/拒绝原因',
    `admin_remark`          VARCHAR(500) COMMENT '平台备注',
    `return_logistics_company` VARCHAR(100) DEFAULT NULL COMMENT '退货物流公司',
    `return_tracking_no`    VARCHAR(100) DEFAULT NULL COMMENT '退货物流单号',
    `return_ship_time`      DATETIME DEFAULT NULL COMMENT '退货发货时间',
    `return_receive_time`   DATETIME DEFAULT NULL COMMENT '商家确认收货时间',
    `apply_time`            DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    `audit_time`            DATETIME COMMENT '审核时间',
    `refund_time`           DATETIME COMMENT '退款完成时间',
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='退款记录表';

-- ============================================
-- 平台运营后台 RBAC
-- ============================================

-- ---------- 5. 管理员表 ----------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
    `id`               BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '管理员ID',
    `username`         VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password`         VARCHAR(100) NOT NULL COMMENT '密码（BCrypt）',
    `real_name`        VARCHAR(50) COMMENT '真实姓名',
    `email`            VARCHAR(100) COMMENT '邮箱',
    `phone`            VARCHAR(20) COMMENT '手机号',
    `avatar`           VARCHAR(255) COMMENT '头像URL',
    `status`           TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `is_super`         TINYINT DEFAULT 0 COMMENT '是否超级管理员：0否 1是',
    `last_login_time`  DATETIME COMMENT '最近登录时间',
    `last_login_ip`    VARCHAR(50) COMMENT '最近登录IP',
    `created_at`       DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台管理员表';

-- ---------- 6. 角色表 ----------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    `name`        VARCHAR(50) NOT NULL COMMENT '角色名',
    `code`        VARCHAR(50) NOT NULL UNIQUE COMMENT '角色编码',
    `description` VARCHAR(255) COMMENT '描述',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- ---------- 7. 权限（菜单）表 ----------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    `parent_id`   BIGINT DEFAULT 0 COMMENT '父级ID，0为顶级',
    `name`        VARCHAR(50) NOT NULL COMMENT '权限名称',
    `code`        VARCHAR(100) NOT NULL COMMENT '权限编码（如 order:list）',
    `type`        TINYINT NOT NULL DEFAULT 1 COMMENT '类型：1菜单 2按钮 3接口',
    `path`        VARCHAR(255) COMMENT '前端路由路径',
    `component`   VARCHAR(255) COMMENT '前端组件路径',
    `icon`        VARCHAR(50) COMMENT '图标',
    `sort_order`  INT DEFAULT 0 COMMENT '排序号',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_parent_id` (`parent_id`),
    INDEX `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='权限（菜单）表';

-- ---------- 8. 管理员-角色关联表 ----------
DROP TABLE IF EXISTS `admin_role`;
CREATE TABLE `admin_role` (
    `admin_id` BIGINT NOT NULL COMMENT '管理员ID',
    `role_id`  BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (`admin_id`, `role_id`),
    INDEX `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员-角色关联表';

-- ---------- 9. 角色-权限关联表 ----------
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission` (
    `role_id`       BIGINT NOT NULL COMMENT '角色ID',
    `permission_id` BIGINT NOT NULL COMMENT '权限ID',
    PRIMARY KEY (`role_id`, `permission_id`),
    INDEX `idx_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色-权限关联表';

-- ============================================
-- 初始数据
-- ============================================

-- 超级管理员账号（密码 123456 的 BCrypt 哈希）
-- 这个哈希值经过 BCryptPasswordEncoder.matches 验证通过
INSERT INTO `admin` (`username`, `password`, `real_name`, `email`, `is_super`, `status`)
VALUES ('admin', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',
        '超级管理员', 'admin@shopping.com', 1, 1);

-- 普通运营账号（密码 123456）
INSERT INTO `admin` (`username`, `password`, `real_name`, `email`, `is_super`, `status`)
VALUES ('operator', '$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',
        '运营员', 'operator@shopping.com', 0, 1);

-- 角色
INSERT INTO `role` (`name`, `code`, `description`) VALUES
('超级管理员', 'SUPER_ADMIN', '拥有系统全部权限'),
('运营',       'OPERATOR',    '负责日常运营管理'),
('客服',       'CS',          '处理订单售后');

-- ============================================
-- 菜单/权限（按运营总后台结构）
-- 树形结构：parent_id = 0 为顶级
-- ============================================
INSERT INTO `permission` (`id`, `parent_id`, `name`, `code`, `type`, `path`, `component`, `icon`, `sort_order`) VALUES
-- 顶级
(1,  0, '工作台',    'dashboard',   1, '/dashboard',  'Dashboard',  'DataLine',  1),

(2,  0, '订单管理',  'order',       1, '/order',      'Layout',     'List',      10),
(3,  2, '全部订单',  'order:list',  1, '/order/list', 'OrderList',  '',          1),
(4,  2, '退款管理',  'refund:list', 1, '/refund',     'RefundList', '',          2),

(5,  0, '商品管理',  'product',     1, '/product',    'Layout',     'Goods',     20),
(6,  5, '商品列表',  'product:list',1, '/product/list','ProductList','',         1),
(7,  5, '商品分类',  'category:list',1,'/category',   'CategoryList','',         2),
(8,  5, '商家管理',  'merchant:list',1,'/merchant',   'MerchantList','',         3),

(9,  0, '营销管理',  'marketing',   1, '/marketing',  'Layout',     'Promotion', 30),
(10, 9, '优惠券',    'coupon:list', 1, '/coupon',     'CouponList', '',          1),
(11, 9, '活动配置',  'activity:list',1,'/activity',   'ActivityList','',         2),

(12, 0, '用户管理',  'user',        1, '/user',       'UserList',   'User',      40),

(13, 0, '数据统计',  'statistics',  1, '/statistics', 'Statistics', 'DataAnalysis', 50),

(14, 0, '系统管理',  'system',      1, '/system',     'Layout',     'Setting',   99),
(15, 14, '管理员',   'admin:list',  1, '/system/admin',     'AdminList',     '',      1),
(16, 14, '角色',     'role:list',   1, '/system/role',      'RoleList',      '',      2),
(17, 14, '权限',     'permission:list', 1, '/system/permission', 'PermissionList', '',   3);

-- 超级管理员拥有所有权限
INSERT INTO `role_permission` (`role_id`, `permission_id`)
SELECT 1, id FROM `permission`;

-- 运营：订单/商品/营销/用户（没有系统管理）
INSERT INTO `role_permission` (`role_id`, `permission_id`)
SELECT 2, id FROM `permission` WHERE `code` IN
  ('dashboard','order:list','refund:list','product:list','category:list','merchant:list',
   'coupon:list','activity:list','statistics');

-- 客服：订单/退款
INSERT INTO `role_permission` (`role_id`, `permission_id`)
SELECT 3, id FROM `permission` WHERE `code` IN
  ('dashboard','order:list','refund:list');

-- 关联 admin 账号到角色
INSERT INTO `admin_role` (`admin_id`, `role_id`) VALUES (1, 1);
INSERT INTO `admin_role` (`admin_id`, `role_id`) VALUES (2, 2);

-- ============================================
-- 验证
-- ============================================
SELECT 'admin 表:' AS info;
SELECT id, username, real_name, is_super, status FROM `admin`;

SELECT 'role 表:' AS info;
SELECT id, name, code FROM `role`;

SELECT 'permission 表:' AS info;
SELECT id, parent_id, name, code, type FROM `permission` ORDER BY parent_id, sort_order;

SELECT 'admin_role 关联:' AS info;
SELECT ar.admin_id, a.username, ar.role_id, r.name AS role_name
FROM `admin_role` ar
LEFT JOIN `admin` a ON a.id = ar.admin_id
LEFT JOIN `role`  r ON r.id = ar.role_id;

-- ============================================
-- 10. 订单物流轨迹表
-- ============================================
DROP TABLE IF EXISTS `order_logistics_track`;
CREATE TABLE `order_logistics_track` (
    `id`              BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT 'ID',
    `order_id`        BIGINT NOT NULL COMMENT '订单ID',
    `express_company` VARCHAR(50) COMMENT '快递公司',
    `tracking_no`     VARCHAR(50) COMMENT '物流单号',
    `status`          VARCHAR(50) COMMENT '物流状态',
    `location`        VARCHAR(200) COMMENT '当前位置',
    `description`     VARCHAR(500) COMMENT '描述',
    `track_time`      DATETIME COMMENT '轨迹时间',
    `created_at`      DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单物流轨迹表';

-- ============================================
-- 11. 订单评价表
-- ============================================
DROP TABLE IF EXISTS `order_review`;
CREATE TABLE `order_review` (
    `id`             BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '评价ID',
    `order_id`       BIGINT NOT NULL COMMENT '订单ID',
    `order_item_id`  BIGINT COMMENT '订单明细ID',
    `user_id`        BIGINT NOT NULL COMMENT '用户ID',
    `product_id`     BIGINT NOT NULL COMMENT '商品ID',
    `merchant_id`    BIGINT NOT NULL COMMENT '商家ID',
    `rating`         TINYINT NOT NULL DEFAULT 5 COMMENT '评分：1-5星',
    `content`        VARCHAR(1000) COMMENT '评价内容',
    `images`         VARCHAR(1000) COMMENT '晒图图片，逗号分隔',
    `is_anonymous`   TINYINT DEFAULT 0 COMMENT '是否匿名：0否 1是',
    `merchant_reply` VARCHAR(500) COMMENT '商家回复',
    `reply_time`     DATETIME COMMENT '回复时间',
    `status`         TINYINT DEFAULT 1 COMMENT '状态：0隐藏 1显示',
    `created_at`     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_product_id` (`product_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单评价表';

-- ============================================
-- 12. 操作日志表
-- ============================================
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
    `id`            BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    `module`        VARCHAR(50) COMMENT '模块：order/refund/product等',
    `operation`     VARCHAR(100) COMMENT '操作名称',
    `business_id`   BIGINT COMMENT '业务ID',
    `operator_type` TINYINT COMMENT '操作人类型：1用户 2商家 3管理员',
    `operator_id`   BIGINT COMMENT '操作人ID',
    `operator_name` VARCHAR(100) COMMENT '操作人名称',
    `ip`            VARCHAR(50) COMMENT 'IP地址',
    `request_params` TEXT COMMENT '请求参数',
    `result`        TEXT COMMENT '操作结果',
    `status`        TINYINT DEFAULT 1 COMMENT '状态：0失败 1成功',
    `error_msg`     VARCHAR(500) COMMENT '错误信息',
    `cost_time`     BIGINT COMMENT '耗时(ms)',
    `created_at`    DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX `idx_module` (`module`),
    INDEX `idx_business_id` (`business_id`),
    INDEX `idx_operator` (`operator_type`, `operator_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- ============================================
-- 13. 运费模板表
-- ============================================
DROP TABLE IF EXISTS `freight_template`;
CREATE TABLE `freight_template` (
    `id`          BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '模板ID',
    `merchant_id` BIGINT NOT NULL COMMENT '商家ID',
    `name`        VARCHAR(100) NOT NULL COMMENT '模板名称',
    `free_amount` DECIMAL(10,2) DEFAULT NULL COMMENT '满多少包邮，NULL表示不包邮',
    `base_freight` DECIMAL(10,2) DEFAULT 0 COMMENT '基础运费',
    `status`      TINYINT DEFAULT 1 COMMENT '状态：0禁用 1启用',
    `created_at`  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运费模板表';

-- 插入默认运费模板数据
INSERT INTO `freight_template` (`merchant_id`, `name`, `free_amount`, `base_freight`, `status`) VALUES
(1, '默认运费模板', 99.00, 8.00, 1),
(2, '默认运费模板', 99.00, 10.00, 1);
