#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
购物系统高并发性能快速验证脚本
使用方法:
    1. 确保已安装 Python 3.7+
    2. 安装依赖: pip install requests
    3. 启动所有微服务 (8081-8084) 和 Redis
    4. 运行: python test_concurrency.py
"""

import requests
import threading
import time
import json
from concurrent.futures import ThreadPoolExecutor, as_completed

# ==================== 配置 ====================

# 服务地址
MARKETING_URL = "http://localhost:8083"
ORDER_URL = "http://localhost:8084"
USER_URL = "http://localhost:8081"
PRODUCT_URL = "http://localhost:8082"

# 并发配置
CONCURRENT_USERS = 50       # 并发用户数
REQUESTS_PER_USER = 5       # 每个用户的请求次数
REQUEST_TIMEOUT = 10        # 请求超时时间(秒)

# 全局统计
stats = {
    "total": 0,
    "success": 0,
    "lock_fail": 0,        # 分布式锁拦截（操作过于频繁）
    "business_fail": 0,    # 业务逻辑失败（如库存不足、已达上限等）
    "error": 0,            # 请求异常
    "total_time": 0,
    "min_time": 999999,
    "max_time": 0,
    "response_times": [],
}
stats_lock = threading.Lock()


def record_result(success_type, response_time, message=""):
    """记录测试结果"""
    with stats_lock:
        stats["total"] += 1
        stats["response_times"].append(response_time)
        stats["total_time"] += response_time
        if response_time < stats["min_time"]:
            stats["min_time"] = response_time
        if response_time > stats["max_time"]:
            stats["max_time"] = response_time
        
        if success_type == "success":
            stats["success"] += 1
        elif success_type == "lock_fail":
            stats["lock_fail"] += 1
        elif success_type == "business_fail":
            stats["business_fail"] += 1
        else:
            stats["error"] += 1


def print_separator(title=""):
    """打印分隔线"""
    if title:
        print(f"\n{'='*20} {title} {'='*20}")
    else:
        print("\n" + "="*60)


# ==================== 测试场景 ====================

def test_seckill_place_order():
    """
    测试场景1: 秒杀下单并发测试
    验证: 同一个用户不能重复秒杀同一个活动
    """
    print_separator("测试场景1: 秒杀下单并发测试")
    print(f"并发用户数: {CONCURRENT_USERS}, 每人请求次数: {REQUESTS_PER_USER}")
    print(f"测试目的: 验证同一个用户不能重复秒杀同一个活动（分布式锁生效）")
    
    def worker(user_id):
        for i in range(REQUESTS_PER_USER):
            url = f"{MARKETING_URL}/seckill/order"
            params = {
                "activityId": 1,
                "productId": 1,
                "skuId": 1,
                "userId": user_id,
                "quantity": 1
            }
            start = time.time()
            try:
                resp = requests.post(url, params=params, timeout=REQUEST_TIMEOUT)
                elapsed = time.time() - start
                
                if resp.status_code == 200:
                    result = resp.json()
                    code = result.get("code", 500) if isinstance(result, dict) else 500
                    msg = str(result.get("message", "")) if isinstance(result, dict) else ""
                    
                    if code == 200:
                        record_result("success", elapsed, msg)
                    elif "操作过于频繁" in msg or "frequent" in msg.lower():
                        record_result("lock_fail", elapsed, msg)
                    else:
                        record_result("business_fail", elapsed, msg)
                else:
                    record_result("error", elapsed, f"HTTP {resp.status_code}")
            except Exception as e:
                elapsed = time.time() - start
                record_result("error", elapsed, str(e))
    
    run_concurrent_test(worker)
    print_test_results("秒杀下单")
    print_lock_effectiveness_check()


def test_coupon_receive():
    """
    测试场景2: 优惠券领取并发测试
    验证: 同一个用户不能重复领取同一张优惠券
    """
    print_separator("测试场景2: 优惠券领取并发测试")
    print(f"并发用户数: {CONCURRENT_USERS}, 每人请求次数: {REQUESTS_PER_USER}")
    print(f"测试目的: 验证同一个用户不能重复领取同一张优惠券（分布式锁生效）")
    
    def worker(user_id):
        for i in range(REQUESTS_PER_USER):
            url = f"{MARKETING_URL}/coupon/receive"
            params = {
                "userId": user_id,
                "templateId": 1
            }
            start = time.time()
            try:
                resp = requests.post(url, params=params, timeout=REQUEST_TIMEOUT)
                elapsed = time.time() - start
                
                if resp.status_code == 200:
                    result = resp.json()
                    code = result.get("code", 500) if isinstance(result, dict) else 500
                    msg = str(result.get("message", "")) if isinstance(result, dict) else ""
                    
                    if code == 200:
                        record_result("success", elapsed, msg)
                    elif "操作过于频繁" in msg or "frequent" in msg.lower():
                        record_result("lock_fail", elapsed, msg)
                    else:
                        record_result("business_fail", elapsed, msg)
                else:
                    record_result("error", elapsed, f"HTTP {resp.status_code}")
            except Exception as e:
                elapsed = time.time() - start
                record_result("error", elapsed, str(e))
    
    run_concurrent_test(worker)
    print_test_results("优惠券领取")
    print_lock_effectiveness_check()


def test_groupbuy_join():
    """
    测试场景3: 拼团参团并发测试
    验证: 同一个用户不能重复参加同一个团
    """
    print_separator("测试场景3: 拼团参团并发测试")
    print(f"并发用户数: {CONCURRENT_USERS}, 每人请求次数: {REQUESTS_PER_USER}")
    print(f"测试目的: 验证同一个用户不能重复参加同一个团（分布式锁生效）")
    
    # 需要先在数据库准备一个真实团队，或者通过接口创建
    # 这里假设有团队ID=1，需要根据实际情况修改
    team_no = "GB1782916346671646"  # 请替换为数据库中真实存在的团队编号
    
    def worker(user_id):
        for i in range(REQUESTS_PER_USER):
            url = f"{MARKETING_URL}/group/join/{team_no}"
            params = {
                "userId": user_id
            }
            start = time.time()
            try:
                resp = requests.post(url, params=params, timeout=REQUEST_TIMEOUT)
                elapsed = time.time() - start
                
                if resp.status_code == 200:
                    result = resp.json()
                    code = result.get("code", 500) if isinstance(result, dict) else 500
                    msg = str(result.get("message", "")) if isinstance(result, dict) else ""
                    
                    if code == 200:
                        record_result("success", elapsed, msg)
                    elif "操作过于频繁" in msg or "frequent" in msg.lower():
                        record_result("lock_fail", elapsed, msg)
                    else:
                        record_result("business_fail", elapsed, msg)
                else:
                    record_result("error", elapsed, f"HTTP {resp.status_code}")
            except Exception as e:
                elapsed = time.time() - start
                record_result("error", elapsed, str(e))
    
    run_concurrent_test(worker)
    print_test_results("拼团参团")
    print_lock_effectiveness_check()


def test_order_create():
    """
    测试场景4: 订单创建并发测试
    验证: 同一个用户并发提交订单不会重复创建
    """
    print_separator("测试场景4: 订单创建并发测试")
    print(f"并发用户数: {CONCURRENT_USERS}, 每人请求次数: {REQUESTS_PER_USER}")
    print(f"测试目的: 验证同一个用户并发提交订单不会重复创建（分布式锁兜底）")
    
    def worker(user_id):
        for i in range(REQUESTS_PER_USER):
            url = f"{ORDER_URL}/order/create"
            payload = {
                "userId": user_id,
                "addressId": 1,
                "items": [
                    {
                        "productId": 1,
                        "skuId": 1,
                        "quantity": 1
                    }
                ]
            }
            start = time.time()
            try:
                resp = requests.post(url, json=payload, timeout=REQUEST_TIMEOUT)
                elapsed = time.time() - start
                
                if resp.status_code == 200:
                    result = resp.json()
                    code = result.get("code", 500) if isinstance(result, dict) else 500
                    msg = str(result.get("message", "")) if isinstance(result, dict) else ""
                    
                    if code == 200:
                        record_result("success", elapsed, msg)
                    elif "操作过于频繁" in msg or "frequent" in msg.lower():
                        record_result("lock_fail", elapsed, msg)
                    else:
                        record_result("business_fail", elapsed, msg)
                else:
                    record_result("error", elapsed, f"HTTP {resp.status_code}")
            except Exception as e:
                elapsed = time.time() - start
                record_result("error", elapsed, str(e))
    
    run_concurrent_test(worker)
    print_test_results("订单创建")
    print_lock_effectiveness_check()


def test_payment_create():
    """
    测试场景5: 支付创建并发测试
    验证: 同一个订单不能重复创建支付
    """
    print_separator("测试场景5: 支付创建并发测试")
    print(f"并发用户数: {CONCURRENT_USERS}, 每人请求次数: {REQUESTS_PER_USER}")
    print(f"测试目的: 验证同一个订单不能重复创建支付（分布式锁生效）")
    
    # 需要先通过场景4创建订单，或使用数据库中真实存在的待支付订单ID
    order_id = 1  # 请替换为数据库中真实存在的待支付订单ID
    
    def worker(user_id):
        for i in range(REQUESTS_PER_USER):
            url = f"{ORDER_URL}/payment/create"
            params = {
                "orderId": order_id,
                "payMethod": 1
            }
            start = time.time()
            try:
                resp = requests.post(url, params=params, timeout=REQUEST_TIMEOUT)
                elapsed = time.time() - start
                
                if resp.status_code == 200:
                    result = resp.json()
                    code = result.get("code", 500) if isinstance(result, dict) else 500
                    msg = str(result.get("message", "")) if isinstance(result, dict) else ""
                    
                    if code == 200:
                        record_result("success", elapsed, msg)
                    elif "操作过于频繁" in msg or "frequent" in msg.lower():
                        record_result("lock_fail", elapsed, msg)
                    else:
                        record_result("business_fail", elapsed, msg)
                else:
                    record_result("error", elapsed, f"HTTP {resp.status_code}")
            except Exception as e:
                elapsed = time.time() - start
                record_result("error", elapsed, str(e))
    
    run_concurrent_test(worker)
    print_test_results("支付创建")
    print_lock_effectiveness_check()


def test_system_stability():
    """
    测试场景6: 系统稳定性压测
    验证: 高并发下系统不崩溃
    """
    global REQUESTS_PER_USER
    print_separator("测试场景6: 系统稳定性压测（查询接口）")
    print(f"并发用户数: {CONCURRENT_USERS * 2}, 每人请求次数: {REQUESTS_PER_USER * 2}")
    print(f"测试目的: 验证高并发查询下系统是否稳定（连接池/线程池是否足够）")
    
    original_requests = REQUESTS_PER_USER
    REQUESTS_PER_USER = REQUESTS_PER_USER * 2
    
    def worker(user_id):
        urls = [
            f"{MARKETING_URL}/seckill/activity/list",
            f"{MARKETING_URL}/coupon/template/active",
            f"{PRODUCT_URL}/product/list?page=1&size=10",
            f"{USER_URL}/user/info?userId={user_id}",
        ]
        for i in range(REQUESTS_PER_USER):
            url = urls[i % len(urls)]
            start = time.time()
            try:
                resp = requests.get(url, timeout=REQUEST_TIMEOUT)
                elapsed = time.time() - start
                
                if resp.status_code == 200:
                    record_result("success", elapsed)
                else:
                    record_result("business_fail", elapsed, f"HTTP {resp.status_code}")
            except Exception as e:
                elapsed = time.time() - start
                record_result("error", elapsed, str(e))
    
    run_concurrent_test(worker, user_count=CONCURRENT_USERS * 2)
    print_test_results("系统稳定性查询")
    
    REQUESTS_PER_USER = original_requests
    
    # 输出稳定性结论
    error_rate = stats["error"] / stats["total"] * 100 if stats["total"] > 0 else 0
    print(f"\n系统稳定性评估:")
    if error_rate < 1:
        print(f"  ✅ 系统稳定，错误率仅 {error_rate:.2f}%")
    elif error_rate < 5:
        print(f"  ⚠️  系统基本稳定，错误率 {error_rate:.2f}%，建议关注")
    else:
        print(f"  ❌ 系统不稳定，错误率 {error_rate:.2f}%，需要优化")


# ==================== 工具函数 ====================

def run_concurrent_test(worker_func, user_count=None):
    """运行并发测试"""
    if user_count is None:
        user_count = CONCURRENT_USERS
    
    # 重置统计
    global stats
    stats = {
        "total": 0,
        "success": 0,
        "lock_fail": 0,
        "business_fail": 0,
        "error": 0,
        "total_time": 0,
        "min_time": 999999,
        "max_time": 0,
        "response_times": [],
    }
    
    start_time = time.time()
    
    with ThreadPoolExecutor(max_workers=user_count) as executor:
        futures = []
        for user_id in range(1, user_count + 1):
            futures.append(executor.submit(worker_func, user_id))
        
        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                print(f"  线程异常: {e}")
    
    total_duration = time.time() - start_time
    stats["total_duration"] = total_duration


def print_test_results(scenario_name):
    """打印测试结果"""
    total = stats["total"]
    success = stats["success"]
    lock_fail = stats["lock_fail"]
    business_fail = stats["business_fail"]
    error = stats["error"]
    total_duration = stats.get("total_duration", 0)
    
    avg_time = stats["total_time"] / total * 1000 if total > 0 else 0
    min_time = stats["min_time"] * 1000 if total > 0 else 0
    max_time = stats["max_time"] * 1000 if total > 0 else 0
    qps = total / total_duration if total_duration > 0 else 0
    
    # 计算百分位数
    times = sorted(stats["response_times"])
    p50 = times[len(times)//2] * 1000 if times else 0
    p90 = times[int(len(times)*0.9)] * 1000 if times else 0
    p99 = times[int(len(times)*0.99)] * 1000 if times else 0
    
    print(f"\n{'─'*50}")
    print(f"  测试场景: {scenario_name}")
    print(f"{'─'*50}")
    print(f"  总请求数:     {total}")
    print(f"  成功:         {success}  ({success/total*100:.1f}%)" if total > 0 else "  成功:         0")
    print(f"  锁拦截:       {lock_fail}  ({lock_fail/total*100:.1f}%)" if total > 0 else "  锁拦截:       0")
    print(f"  业务失败:     {business_fail}  ({business_fail/total*100:.1f}%)" if total > 0 else "  业务失败:     0")
    print(f"  请求异常:     {error}  ({error/total*100:.1f}%)" if total > 0 else "  请求异常:     0")
    print(f"{'─'*50}")
    print(f"  总耗时:       {total_duration:.2f} 秒")
    print(f"  吞吐量(QPS):  {qps:.2f} req/s")
    print(f"  平均响应:     {avg_time:.2f} ms")
    print(f"  最小响应:     {min_time:.2f} ms")
    print(f"  最大响应:     {max_time:.2f} ms")
    print(f"  P50 响应:     {p50:.2f} ms")
    print(f"  P90 响应:     {p90:.2f} ms")
    print(f"  P99 响应:     {p99:.2f} ms")
    print(f"{'─'*50}")


def print_lock_effectiveness_check():
    """检查分布式锁是否生效"""
    total = stats["total"]
    lock_fail = stats["lock_fail"]
    
    print(f"\n  🔒 分布式锁验证:")
    if total == 0:
        print(f"     无请求数据")
    elif lock_fail > 0:
        print(f"     ✅ 分布式锁生效！拦截了 {lock_fail} 次重复请求")
        print(f"     锁拦截率: {lock_fail/total*100:.1f}%")
    else:
        print(f"     ⚠️  未检测到锁拦截（可能原因：）")
        print(f"        1. 每个用户只发了1次请求，没有重复请求")
        print(f"        2. 数据准备不足（如活动/商品不存在）")
        print(f"        3. 分布式锁未正确配置")
        print(f"     建议: 增加 REQUESTS_PER_USER 到 10 以上重试")


def check_services_available():
    """检查服务是否可用"""
    print("检查服务可用性...")
    services = {
        "用户服务(8081)": f"{USER_URL}/user/info?userId=1",
        "商品服务(8082)": f"{PRODUCT_URL}/product/list?page=1&size=1",
        "营销服务(8083)": f"{MARKETING_URL}/seckill/activity/list",
        "订单服务(8084)": f"{ORDER_URL}/order/list?userId=1&page=1&size=1",
    }
    
    all_ok = True
    for name, url in services.items():
        try:
            resp = requests.get(url, timeout=3)
            if resp.status_code == 200:
                print(f"  ✅ {name}: 运行中")
            else:
                print(f"  ⚠️  {name}: HTTP {resp.status_code}")
                all_ok = False
        except Exception as e:
            print(f"  ❌ {name}: 连接失败 ({e})")
            all_ok = False
    
    return all_ok


def print_menu():
    """打印菜单"""
    print_separator("购物系统高并发性能测试工具")
    print("")
    print("请选择测试场景:")
    print("  1. 秒杀下单并发测试")
    print("  2. 优惠券领取并发测试")
    print("  3. 拼团参团并发测试")
    print("  4. 订单创建并发测试")
    print("  5. 支付创建并发测试")
    print("  6. 系统稳定性压测（查询接口）")
    print("  7. 全部测试（依次执行所有场景）")
    print("  8. 修改并发配置")
    print("  0. 退出")
    print("")


def modify_config():
    """修改并发配置"""
    global CONCURRENT_USERS, REQUESTS_PER_USER
    
    print_separator("修改并发配置")
    print(f"当前配置: 并发用户数={CONCURRENT_USERS}, 每人请求次数={REQUESTS_PER_USER}")
    print("")
    
    try:
        new_users = input("请输入新的并发用户数 (回车保持不变): ").strip()
        if new_users:
            CONCURRENT_USERS = int(new_users)
        
        new_requests = input("请输入新的每人请求次数 (回车保持不变): ").strip()
        if new_requests:
            REQUESTS_PER_USER = int(new_requests)
        
        print(f"配置已更新: 并发用户数={CONCURRENT_USERS}, 每人请求次数={REQUESTS_PER_USER}")
    except ValueError:
        print("输入无效，配置未改变")


# ==================== 主程序 ====================

def main():
    print("""
  ╔══════════════════════════════════════════╗
  ║     购物系统高并发性能快速验证工具         ║
  ║     Shopping System Concurrency Test     ║
  ╚══════════════════════════════════════════╝
    """)
    
    # 检查服务
    if not check_services_available():
        print("\n⚠️  部分服务不可用，请先启动所有微服务和 Redis！")
        print("   继续测试可能会失败，是否继续？(y/n)")
        choice = input("> ").strip().lower()
        if choice != 'y':
            print("已退出。")
            return
    
    while True:
        print_menu()
        choice = input("请输入选项: ").strip()
        
        if choice == '1':
            test_seckill_place_order()
        elif choice == '2':
            test_coupon_receive()
        elif choice == '3':
            test_groupbuy_join()
        elif choice == '4':
            test_order_create()
        elif choice == '5':
            test_payment_create()
        elif choice == '6':
            test_system_stability()
        elif choice == '7':
            print("\n🚀 开始全场景测试...")
            test_seckill_place_order()
            test_coupon_receive()
            test_groupbuy_join()
            test_order_create()
            test_payment_create()
            test_system_stability()
            print_separator("全场景测试完成")
        elif choice == '8':
            modify_config()
        elif choice == '0':
            print("\n👋 退出测试工具，再见！")
            break
        else:
            print("无效选项，请重新输入。")
        
        input("\n按回车键继续...")


if __name__ == "__main__":
    main()
