package com.shopping.common.exception;

import lombok.Getter;

@Getter
public enum ErrorCode {

    SUCCESS(200, "成功"),
    PARAM_ERROR(400, "参数错误"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "禁止访问"),
    NOT_FOUND(404, "资源不存在"),
    SERVER_ERROR(500, "服务器内部错误"),

    ORDER_NOT_FOUND(10001, "订单不存在"),
    ORDER_STATUS_ERROR(10002, "订单状态错误"),
    ORDER_CANCEL_ERROR(10003, "订单取消失败"),
    ORDER_PAY_ERROR(10004, "订单支付失败"),

    REFUND_NOT_FOUND(20001, "退款申请不存在"),
    REFUND_STATUS_ERROR(20002, "退款状态错误"),
    REFUND_AMOUNT_ERROR(20003, "退款金额错误"),

    PRODUCT_NOT_FOUND(30001, "商品不存在"),
    STOCK_NOT_ENOUGH(30002, "库存不足"),

    USER_NOT_FOUND(40001, "用户不存在"),
    USER_NOT_LOGIN(40002, "用户未登录");

    private final Integer code;
    private final String message;

    ErrorCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }
}
