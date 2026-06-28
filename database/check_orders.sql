USE shopping_system;
SELECT COUNT(*) as order_count FROM `order`;
SELECT id, order_no, user_id, status, total_amount, created_at FROM `order` LIMIT 10;
SELECT COUNT(*) as order_item_count FROM order_item;
