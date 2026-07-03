CREATE TABLE IF NOT EXISTS coupon_status_apply (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    template_id BIGINT NOT NULL COMMENT '优惠券模板ID',
    merchant_id BIGINT NOT NULL COMMENT '商家ID',
    target_status INT NOT NULL COMMENT '目标状态 0-停用 1-启用',
    reason TEXT COMMENT '申请原因',
    apply_status INT DEFAULT 0 COMMENT '申请状态 0-待审核 1-已通过 2-已拒绝',
    admin_remark VARCHAR(500) COMMENT '管理员备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_template_id (template_id),
    INDEX idx_merchant_id (merchant_id),
    INDEX idx_apply_status (apply_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券状态变更申请表';