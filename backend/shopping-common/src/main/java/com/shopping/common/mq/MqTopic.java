package com.shopping.common.mq;

/**
 * MQ 主题常量
 */
public class MqTopic {
    /** 订单创建 */
    public static final String ORDER_CREATED = "order_created";
    /** 订单支付 */
    public static final String ORDER_PAID = "order_paid";
    /** 订单取消 */
    public static final String ORDER_CANCELLED = "order_cancelled";

    /** 库存扣减 */
    public static final String STOCK_DEDUCT = "stock_deduct";
    /** 库存回滚 */
    public static final String STOCK_ROLLBACK = "stock_rollback";

    /** 秒杀活动开始 */
    public static final String SECKILL_START = "seckill_start";
    /** 秒杀活动结束 */
    public static final String SECKILL_END = "seckill_end";
    /** 秒杀下单 */
    public static final String SECKILL_PLACE = "seckill_place";

    /** 拼团创建 */
    public static final String GROUP_CREATED = "group_created";
    /** 拼团成团 */
    public static final String GROUP_SUCCESS = "group_success";
    /** 拼团失败 */
    public static final String GROUP_FAIL = "group_fail";

    /** 优惠券领取 */
    public static final String COUPON_RECEIVE = "coupon_receive";
    /** 优惠券使用 */
    public static final String COUPON_USE = "coupon_use";

    /** 商家数据统计 */
    public static final String MERCHANT_STATS = "merchant_stats";
}
