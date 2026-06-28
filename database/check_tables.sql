USE shopping_system;

-- 检查商品数量
SELECT CONCAT('商品数量: ', COUNT(*)) FROM product;
SELECT CONCAT('分类数量: ', COUNT(*)) FROM category;
SELECT CONCAT('商家数量: ', COUNT(*)) FROM merchant;
SELECT CONCAT('用户数量: ', COUNT(*)) FROM user;
