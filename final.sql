-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: shopping_system
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `address`
--

DROP TABLE IF EXISTS `address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `name` varchar(50) NOT NULL COMMENT '收货人姓名',
  `phone` varchar(20) NOT NULL COMMENT '收货人电话',
  `province` varchar(50) DEFAULT NULL COMMENT '省份',
  `city` varchar(50) DEFAULT NULL COMMENT '城市',
  `district` varchar(50) DEFAULT NULL COMMENT '区县',
  `detail` varchar(200) DEFAULT NULL COMMENT '详细地址',
  `is_default` tinyint DEFAULT '0' COMMENT '是否默认：0否，1是',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_default` (`is_default`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收货地址表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address`
--

LOCK TABLES `address` WRITE;
/*!40000 ALTER TABLE `address` DISABLE KEYS */;
INSERT INTO `address` VALUES (1,3,'1','13312343456','河北省','秦皇岛市','抚宁区','111',1,1,'2026-07-01 20:02:04','2026-07-01 20:02:04'),(2,2,'hhh','18877777777','云南省','昆明市','五华区','44',1,1,'2026-07-01 20:18:06','2026-07-01 20:18:06'),(3,1,'小王','17666663622','云南省','昆明市','五华区','我家',1,1,'2026-07-03 01:16:07','2026-07-03 01:16:07');
/*!40000 ALTER TABLE `address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin`
--

DROP TABLE IF EXISTS `admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码（BCrypt）',
  `real_name` varchar(50) DEFAULT NULL COMMENT '真实姓名',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `is_super` tinyint DEFAULT '0' COMMENT '是否超级管理员：0否 1是',
  `last_login_time` datetime DEFAULT NULL COMMENT '最近登录时间',
  `last_login_ip` varchar(50) DEFAULT NULL COMMENT '最近登录IP',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='平台管理员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin`
--

LOCK TABLES `admin` WRITE;
/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` VALUES (1,'admin','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de','超级管理员','admin@shopping.com',NULL,NULL,1,1,'2026-07-03 19:47:26',NULL,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(2,'operator','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de','运营员','operator@shopping.com',NULL,NULL,1,0,'2026-07-02 17:04:34',NULL,'2026-07-01 19:53:49','2026-07-01 19:53:49');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_role`
--

DROP TABLE IF EXISTS `admin_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_role` (
  `admin_id` bigint NOT NULL COMMENT '管理员ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`admin_id`,`role_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='管理员-角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_role`
--

LOCK TABLES `admin_role` WRITE;
/*!40000 ALTER TABLE `admin_role` DISABLE KEYS */;
INSERT INTO `admin_role` VALUES (1,1),(2,2);
/*!40000 ALTER TABLE `admin_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '购物车ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '数量',
  `selected` tinyint DEFAULT '1' COMMENT '是否选中：0否 1是',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product_sku` (`user_id`,`product_id`,`sku_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='购物车表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES (1,1,70,NULL,NULL,1,1,'2026-07-03 17:55:16','2026-07-03 17:55:16');
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `parent_id` bigint DEFAULT '0' COMMENT '父分类ID，0为顶级',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `icon` varchar(50) DEFAULT NULL COMMENT '图标',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (1,'数码产品',0,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(2,'电脑办公',0,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(3,'服装鞋帽',0,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(4,'美妆护肤',0,4,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(5,'食品饮料',0,5,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(6,'图书音像',0,6,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(7,'运动户外',0,7,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(11,'手机',1,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(12,'平板',1,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(13,'智能穿戴',1,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(14,'耳机/音频',1,4,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(15,'摄影摄像',1,5,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(16,'游戏机',1,6,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(21,'笔记本',2,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(22,'台式机',2,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(23,'配件外设',2,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(24,'办公设备',2,4,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(31,'男装',3,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(32,'女装',3,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(33,'鞋靴',3,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(34,'箱包',3,4,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(35,'配饰',3,5,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(41,'彩妆',4,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(42,'护肤',4,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(43,'香水',4,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(44,'个人护理',4,4,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(51,'零食',5,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(52,'坚果炒货',5,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(53,'饮料',5,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(54,'生鲜',5,4,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(61,'图书',6,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(62,'杂志',6,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(63,'音像制品',6,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(71,'运动服装',7,1,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(72,'运动鞋',7,2,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21'),(73,'运动器材',7,3,NULL,1,'2026-07-02 17:53:21','2026-07-02 17:53:21');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_status_apply`
--

DROP TABLE IF EXISTS `coupon_status_apply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_status_apply` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `template_id` bigint NOT NULL COMMENT '优惠券模板ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `target_status` int NOT NULL COMMENT '目标状态 0-停用 1-启用',
  `reason` text COMMENT '申请原因',
  `apply_status` int DEFAULT '0' COMMENT '申请状态 0-待审核 1-已通过 2-已拒绝',
  `admin_remark` varchar(500) DEFAULT NULL COMMENT '管理员备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_apply_status` (`apply_status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='优惠券状态变更申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_status_apply`
--

LOCK TABLES `coupon_status_apply` WRITE;
/*!40000 ALTER TABLE `coupon_status_apply` DISABLE KEYS */;
INSERT INTO `coupon_status_apply` VALUES (1,37,1,0,'',1,'','2026-07-03 19:35:58','2026-07-03 19:47:44');
/*!40000 ALTER TABLE `coupon_status_apply` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon_template`
--

DROP TABLE IF EXISTS `coupon_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `type` tinyint NOT NULL COMMENT '类型：1满减券 2折扣券',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠金额（满减券）',
  `min_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低使用金额',
  `total_count` int DEFAULT '0' COMMENT '发放总量',
  `remaining_count` int DEFAULT '0' COMMENT '剩余数量',
  `per_user_limit` int DEFAULT '1' COMMENT '每人限领数量',
  `start_time` datetime DEFAULT NULL COMMENT '领取开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '领取结束时间',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `description` varchar(500) DEFAULT NULL COMMENT '使用说明',
  `scope_type` tinyint DEFAULT '2' COMMENT '适用范围：1全场 2指定商品 3指定分类',
  `scope_ids` varchar(500) DEFAULT NULL COMMENT '适用范围ID，逗号分隔',
  `coupon_level` tinyint DEFAULT '2' COMMENT '优惠券层级：1平台券 2店铺券',
  `mutually_exclusive` tinyint DEFAULT '1' COMMENT '是否互斥：0否 1是',
  `user_type` tinyint DEFAULT '0' COMMENT '用户类型：0全部用户 1新用户 2会员',
  `member_level` int DEFAULT NULL COMMENT '会员等级（user_type=2时生效）',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_coupon_level` (`coupon_level`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='店铺优惠券模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon_template`
--

LOCK TABLES `coupon_template` WRITE;
/*!40000 ALTER TABLE `coupon_template` DISABLE KEYS */;
INSERT INTO `coupon_template` VALUES (1,'Apple满500减50',1,1,50.00,500.00,3000,2995,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'Apple官方旗舰店全店满500减50',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-02 16:16:36'),(2,'Apple满3000减300',1,1,300.00,3000.00,1000,998,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'Apple官方旗舰店满3000减300',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-03 16:43:07'),(3,'iPhone专属500券',1,1,500.00,5000.00,800,798,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'仅iPhone系列手机可用',3,NULL,3,1,0,NULL,'2026-07-01 19:54:36','2026-07-03 16:43:07'),(4,'优衣库满199减20',2,1,20.00,199.00,5000,4999,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'优衣库全店满199减20',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-02 15:37:04'),(5,'优衣库满399减50',2,1,50.00,399.00,3000,2999,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'优衣库全店满399减50',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-02 15:37:07'),(6,'新人首单立减15',2,1,15.00,99.00,10000,10000,1,'2026-07-01 19:54:36','2026-08-30 19:54:36',1,'优衣库新用户首单立减15',2,NULL,2,1,1,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(7,'华为满1000减100',3,1,100.00,1000.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'华为旗舰店满1000减100',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(8,'华为满3000减300',3,1,300.00,3000.00,2000,2000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'华为旗舰店满3000减300',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(9,'Mate系列专属券',3,1,200.00,4000.00,1500,1498,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'仅Mate系列手机可用',3,NULL,3,1,0,NULL,'2026-07-01 19:54:36','2026-07-03 16:43:07'),(10,'小米满500减50',4,1,50.00,500.00,5000,5000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'小米官方旗舰店全店满500减50',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(11,'小米满2000减200',4,1,200.00,2000.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'小米官方旗舰店全店满2000减200',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(12,'小米14系列专属300券',4,1,300.00,5000.00,2000,1998,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'仅小米14系列手机可用',3,NULL,3,1,0,NULL,'2026-07-01 19:54:36','2026-07-03 16:43:07'),(13,'名创优品满59减10',5,1,10.00,59.00,10000,10000,3,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'名创优品全店满59减10',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(14,'名创优品满99减20',5,1,20.00,99.00,8000,8000,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'名创优品全店满99减20',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(15,'三只松鼠满69减10',6,1,10.00,69.00,10000,10000,3,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'三只松鼠全店满69减10',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(16,'三只松鼠满129减25',6,1,25.00,129.00,6000,6000,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'三只松鼠全店满129减25',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(17,'完美日记满99减15',7,1,15.00,99.00,8000,7998,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'完美日记全店满99减15',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 23:09:17'),(18,'完美日记满199减40',7,1,40.00,199.00,5000,4999,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'完美日记全店满199减40',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 22:32:46'),(19,'李宁满299减30',8,1,30.00,299.00,5000,5000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'李宁旗舰店满299减30',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(20,'李宁满599减80',8,1,80.00,599.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'李宁旗舰店满599减80',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(21,'Nike满500减50',9,1,50.00,500.00,5000,4999,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'Nike旗舰店满500减50',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-02 20:11:35'),(22,'Nike满1000减120',9,1,120.00,1000.00,2000,1999,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'Nike旗舰店满1000减120',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-02 20:11:35'),(23,'当当满99减10',10,1,10.00,99.00,10000,9999,3,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'当当图书满99减10',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-03 17:55:36'),(24,'当当满199减30',10,1,30.00,199.00,5000,4999,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'当当图书满199减30',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-03 17:55:36'),(25,'孩子王满199减20',11,1,20.00,199.00,8000,8000,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'孩子王满199减20',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(26,'孩子王满499减60',11,1,60.00,499.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'孩子王满499减60',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(27,'良品铺子满59减10',12,1,10.00,59.00,10000,10000,3,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'良品铺子满59减10',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(28,'良品铺子满129减25',12,1,25.00,129.00,5000,5000,2,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'良品铺子满129减25',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(29,'宜家满299减30',13,1,30.00,299.00,5000,5000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'宜家家居满299减30',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(30,'宜家满999减120',13,1,120.00,999.00,2000,2000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'宜家家居满999减120',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(31,'安踏满299减40',14,1,40.00,299.00,5000,5000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'安踏旗舰店满299减40',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(32,'安踏满599减90',14,1,90.00,599.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'安踏旗舰店满599减90',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(33,'兰蔻满500减60',15,1,60.00,500.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'兰蔻旗舰店满500减60',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(34,'兰蔻满1000减150',15,1,150.00,1000.00,1500,1500,1,'2026-07-01 19:54:36','2026-07-31 19:54:36',1,'兰蔻旗舰店满1000减150',2,NULL,2,1,0,NULL,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(35,'新人优惠',0,1,10.00,100.00,1000,1000,1,'2026-07-01 16:00:00','2026-07-08 16:00:00',0,NULL,2,'',2,1,0,0,'2026-07-02 18:49:59','2026-07-02 18:49:59'),(36,'满100减去10',0,1,10.00,100.00,1000,998,1,'2026-07-01 16:00:00','2026-08-04 16:00:00',1,'',1,NULL,1,1,0,0,'2026-07-02 20:05:00','2026-07-03 16:43:06'),(37,'手机满100减10',1,1,10.00,100.00,1000,1000,1,'2026-07-02 16:00:00','2026-07-07 16:00:00',0,'',2,NULL,2,1,0,0,'2026-07-03 19:17:39','2026-07-03 19:47:44');
/*!40000 ALTER TABLE `coupon_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exchange`
--

DROP TABLE IF EXISTS `exchange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exchange` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `exchange_no` varchar(50) NOT NULL COMMENT '换货单号',
  `order_id` bigint NOT NULL COMMENT '原订单ID',
  `order_item_id` bigint NOT NULL COMMENT '原订单明细ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `exchange_reason` varchar(500) DEFAULT NULL COMMENT '换货原因',
  `voucher_images` varchar(1000) DEFAULT NULL COMMENT '凭证图片',
  `original_order_status` tinyint DEFAULT NULL COMMENT '申请换货时的原订单状态',
  `original_product_id` bigint NOT NULL COMMENT '原商品ID',
  `original_sku_id` bigint DEFAULT NULL COMMENT '原SKU ID',
  `original_product_name` varchar(200) DEFAULT NULL COMMENT '原商品名称',
  `original_spec_values` varchar(500) DEFAULT NULL COMMENT '原规格值',
  `original_quantity` int NOT NULL DEFAULT '1' COMMENT '原数量',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原商品单价',
  `new_product_id` bigint NOT NULL COMMENT '新商品ID',
  `new_sku_id` bigint DEFAULT NULL COMMENT '新SKU ID',
  `new_product_name` varchar(200) DEFAULT NULL COMMENT '新商品名称',
  `new_spec_values` varchar(500) DEFAULT NULL COMMENT '新规格值',
  `new_quantity` int NOT NULL DEFAULT '1' COMMENT '新数量',
  `new_price` decimal(10,2) DEFAULT NULL COMMENT '新商品单价',
  `price_difference` decimal(10,2) DEFAULT '0.00' COMMENT '价格差异',
  `return_logistics_company` varchar(100) DEFAULT NULL COMMENT '退货物流公司',
  `return_tracking_no` varchar(100) DEFAULT NULL COMMENT '退货物流单号',
  `return_ship_time` datetime DEFAULT NULL COMMENT '退货发货时间',
  `return_receive_time` datetime DEFAULT NULL COMMENT '商家确认收货时间',
  `exchange_logistics_company` varchar(100) DEFAULT NULL COMMENT '换货发货物流公司',
  `exchange_tracking_no` varchar(100) DEFAULT NULL COMMENT '换货发货物流单号',
  `exchange_ship_time` datetime DEFAULT NULL COMMENT '换货发货时间',
  `exchange_receive_time` datetime DEFAULT NULL COMMENT '用户确认收货时间',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0待审核 1待退货 2已拒绝 3已完成 4已取消 5退货中 6待发货 7已发货',
  `merchant_remark` varchar(500) DEFAULT NULL COMMENT '商家备注',
  `apply_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `complete_time` datetime DEFAULT NULL COMMENT '换货完成时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `exchange_no` (`exchange_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='换货申请表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exchange`
--

LOCK TABLES `exchange` WRITE;
/*!40000 ALTER TABLE `exchange` DISABLE KEYS */;
INSERT INTO `exchange` VALUES (1,'E202607012356337965',9,9,3,7,'其他',NULL,3,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,0.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,4,NULL,'2026-07-01 23:56:33',NULL,NULL,'2026-07-01 23:56:33','2026-07-01 23:56:33'),(2,'E202607020008373004',9,9,3,7,'颜色/款式不满意',NULL,3,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,0.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,4,NULL,'2026-07-02 00:08:38',NULL,NULL,'2026-07-02 00:08:37','2026-07-02 00:08:37'),(3,'E202607020008370674',9,9,3,7,'颜色/款式不满意',NULL,3,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,0.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,4,NULL,'2026-07-02 00:08:38',NULL,NULL,'2026-07-02 00:08:37','2026-07-02 00:08:37'),(4,'E202607020009280202',9,9,3,7,'收到错误商品',NULL,3,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,0.00,'顺丰速运','11111www','2026-07-02 00:21:54','2026-07-02 00:23:08','顺丰快递','1122223334','2026-07-02 00:23:45','2026-07-02 00:24:45',3,NULL,'2026-07-02 00:09:29','2026-07-02 00:21:20','2026-07-02 00:24:45','2026-07-02 00:09:28','2026-07-02 00:09:28'),(5,'E202607020033100772',9,9,3,7,'颜色/款式不满意',NULL,3,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,47,NULL,'完美日记动物眼影盘',NULL,1,129.00,0.00,'EMS','11111','2026-07-02 00:34:49','2026-07-02 00:35:14','顺丰快递','11122','2026-07-02 00:35:19','2026-07-02 00:35:43',3,NULL,'2026-07-02 00:33:11','2026-07-02 00:33:50','2026-07-02 00:35:43','2026-07-02 00:33:10','2026-07-02 00:33:10'),(6,'E202607031954597303',31,31,1,1,'111',NULL,3,108,NULL,'iPhone 18',NULL,1,9700.00,108,4,'iPhone 18','红色512',1,12000.00,2300.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,4,NULL,'2026-07-03 19:54:59','2026-07-03 19:56:15',NULL,'2026-07-03 19:54:59','2026-07-03 19:54:59'),(7,'E202607032005042191',39,39,1,1,'111',NULL,3,1,1,'iPhone 15 Pro Max',NULL,1,9999.00,1,2,'iPhone 15 Pro Max','512GB',1,10999.00,1000.00,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-07-03 20:05:05',NULL,NULL,'2026-07-03 20:05:04','2026-07-03 20:05:04'),(8,'E202607032011470294',40,40,2,1,'11111',NULL,3,1,NULL,'iPhone 15 Pro Max',NULL,1,9999.00,1,2,'iPhone 15 Pro Max','512GB',1,10999.00,1000.00,'顺丰速运','SF12345678','2026-07-03 20:12:51','2026-07-03 20:13:05','圆通快递','YT12345678','2026-07-03 20:13:16','2026-07-03 20:13:34',3,'1','2026-07-03 20:11:48','2026-07-03 20:12:13','2026-07-03 20:13:34','2026-07-03 20:11:47','2026-07-03 20:11:47');
/*!40000 ALTER TABLE `exchange` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `favorite`
--

DROP TABLE IF EXISTS `favorite`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `favorite` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '收藏ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_product` (`user_id`,`product_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收藏表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorite`
--

LOCK TABLES `favorite` WRITE;
/*!40000 ALTER TABLE `favorite` DISABLE KEYS */;
/*!40000 ALTER TABLE `favorite` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `freight_template`
--

DROP TABLE IF EXISTS `freight_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `freight_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `name` varchar(100) NOT NULL COMMENT '模板名称',
  `free_amount` decimal(10,2) DEFAULT NULL COMMENT '满多少包邮，NULL表示不包邮',
  `base_freight` decimal(10,2) DEFAULT '0.00' COMMENT '基础运费',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='运费模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `freight_template`
--

LOCK TABLES `freight_template` WRITE;
/*!40000 ALTER TABLE `freight_template` DISABLE KEYS */;
INSERT INTO `freight_template` VALUES (1,1,'默认运费模板',99.00,8.00,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(2,2,'默认运费模板',99.00,10.00,1,'2026-07-01 19:53:49','2026-07-01 19:53:49');
/*!40000 ALTER TABLE `freight_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_buy_activity`
--

DROP TABLE IF EXISTS `group_buy_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_buy_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '活动ID',
  `name` varchar(200) NOT NULL COMMENT '活动名称',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `group_price` decimal(10,2) NOT NULL COMMENT '拼团价',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `required_num` int NOT NULL DEFAULT '3' COMMENT '成团人数',
  `total_stock` int DEFAULT '0' COMMENT '总库存',
  `available_stock` int DEFAULT '0' COMMENT '可用库存',
  `start_time` datetime DEFAULT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `group_duration` int DEFAULT '24' COMMENT '成团有效期(小时)',
  `status` tinyint DEFAULT '0' COMMENT '状态：0未开始 1进行中 2已结束 3已取消',
  `description` varchar(500) DEFAULT NULL COMMENT '活动描述',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='团购活动表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_buy_activity`
--

LOCK TABLES `group_buy_activity` WRITE;
/*!40000 ALTER TABLE `group_buy_activity` DISABLE KEYS */;
INSERT INTO `group_buy_activity` VALUES (5,'拼团活动',3,17,NULL,7649.00,8999.00,3,80,80,'2026-07-01 22:32:26','2026-07-08 22:32:26',24,1,NULL,'2026-07-01 22:32:26','2026-07-02 23:55:49');
/*!40000 ALTER TABLE `group_buy_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_buy_member`
--

DROP TABLE IF EXISTS `group_buy_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_buy_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '成员ID',
  `team_id` bigint NOT NULL COMMENT '团队ID',
  `product_id` bigint DEFAULT NULL COMMENT '商品ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `order_no` varchar(50) DEFAULT NULL COMMENT '订单号',
  `is_leader` tinyint DEFAULT '0' COMMENT '是否团长：0否 1是',
  `status` int DEFAULT '0' COMMENT '状态 0-待支付 1-已支付',
  `join_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  PRIMARY KEY (`id`),
  KEY `idx_team_id` (`team_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='拼团成员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_buy_member`
--

LOCK TABLES `group_buy_member` WRITE;
/*!40000 ALTER TABLE `group_buy_member` DISABLE KEYS */;
INSERT INTO `group_buy_member` VALUES (14,13,69,3,NULL,1,0,'2026-07-03 01:32:44'),(15,13,NULL,1,NULL,0,0,'2026-07-03 01:33:08'),(16,14,67,1,NULL,1,0,'2026-07-03 01:33:26'),(17,14,NULL,3,NULL,0,0,'2026-07-03 01:39:21'),(18,15,82,1,'O202607031953585113',1,1,'2026-07-03 19:53:58'),(19,16,1,2,'O202607032008037691',1,1,'2026-07-03 20:08:03'),(20,16,NULL,1,'O202607032009239650',0,1,'2026-07-03 20:09:23'),(21,17,1,2,'O202607032017145114',1,1,'2026-07-03 20:17:15');
/*!40000 ALTER TABLE `group_buy_member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `group_buy_team`
--

DROP TABLE IF EXISTS `group_buy_team`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `group_buy_team` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '团队ID',
  `team_no` varchar(50) DEFAULT NULL COMMENT '拼团队编号',
  `activity_id` bigint DEFAULT '0' COMMENT '拼团活动ID',
  `product_id` bigint DEFAULT NULL COMMENT '商品ID',
  `leader_id` bigint NOT NULL COMMENT '团长用户ID',
  `required_num` int NOT NULL DEFAULT '3' COMMENT '成团人数',
  `current_num` int DEFAULT '1' COMMENT '当前人数',
  `status` tinyint DEFAULT '0' COMMENT '状态：0进行中 1成团成功 2成团失败',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `success_time` datetime DEFAULT NULL COMMENT '成团时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_team_no` (`team_no`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='拼团团队表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `group_buy_team`
--

LOCK TABLES `group_buy_team` WRITE;
/*!40000 ALTER TABLE `group_buy_team` DISABLE KEYS */;
INSERT INTO `group_buy_team` VALUES (13,'GB1783013564049603',0,69,3,2,2,1,'2026-07-04 01:32:44','2026-07-03 01:33:08','2026-07-03 01:32:44','2026-07-03 01:32:44'),(14,'GB178301360574367',0,67,1,2,2,1,'2026-07-04 01:33:26','2026-07-03 01:39:21','2026-07-03 01:33:26','2026-07-03 01:33:26'),(15,'GB1783079638369834',0,82,1,2,1,0,'2026-07-04 19:53:58',NULL,'2026-07-03 19:53:58','2026-07-03 19:53:58'),(16,'GB1783080483190766',0,1,2,2,2,1,'2026-07-04 20:08:03','2026-07-03 20:09:25','2026-07-03 20:08:03','2026-07-03 20:08:03'),(17,'GB1783081034937367',0,1,2,2,1,0,'2026-07-04 20:17:15',NULL,'2026-07-03 20:17:15','2026-07-03 20:17:15');
/*!40000 ALTER TABLE `group_buy_team` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '会员ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `member_level` tinyint DEFAULT '1' COMMENT '会员等级：1普通会员，2银卡会员，3金卡会员，4钻石会员',
  `total_points` int DEFAULT '0' COMMENT '总积分',
  `available_points` int DEFAULT '0' COMMENT '可用积分',
  `member_since` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '成为会员时间',
  `expire_time` datetime DEFAULT NULL COMMENT '会员到期时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_member_level` (`member_level`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='会员表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,3,1,0,0,'2026-07-01 20:01:23',NULL,'2026-07-01 20:01:23','2026-07-01 20:01:23'),(2,1,1,0,0,'2026-07-01 20:05:07',NULL,'2026-07-01 20:05:07','2026-07-01 20:05:07'),(3,2,1,0,0,'2026-07-01 20:05:16',NULL,'2026-07-01 20:05:16','2026-07-01 20:05:16'),(4,4,1,0,0,'2026-07-02 18:35:03',NULL,'2026-07-02 18:35:03','2026-07-02 18:35:03');
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant`
--

DROP TABLE IF EXISTS `merchant`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商家ID',
  `username` varchar(50) DEFAULT NULL COMMENT '商家用户名',
  `password` varchar(100) DEFAULT NULL COMMENT '密码（BCrypt）',
  `user_id` bigint DEFAULT NULL COMMENT '关联用户ID',
  `shop_name` varchar(100) NOT NULL COMMENT '店铺名称',
  `logo` varchar(255) DEFAULT NULL COMMENT '店铺Logo',
  `contact_name` varchar(50) DEFAULT NULL COMMENT '联系人姓名',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) DEFAULT NULL COMMENT '联系邮箱',
  `address` varchar(255) DEFAULT NULL COMMENT '店铺地址',
  `business_license` varchar(255) DEFAULT NULL COMMENT '营业执照',
  `status` tinyint DEFAULT '0' COMMENT '状态：0待审核 1已通过 2已拒绝 3已禁用',
  `level` int DEFAULT '1' COMMENT '等级',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant`
--

LOCK TABLES `merchant` WRITE;
/*!40000 ALTER TABLE `merchant` DISABLE KEYS */;
INSERT INTO `merchant` VALUES (1,'merchant01','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'Apple官方旗舰店',NULL,'张三','13800001111','service@apple.com','上海市浦东新区',NULL,1,4,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(2,'merchant02','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'优衣库官方旗舰店',NULL,'李四','13800002222','service@uniqlo.com','上海市静安区',NULL,1,3,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(3,'merchant03','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'华为官方旗舰店',NULL,'华为客服','400-830-8300','service@huawei.com','广东省深圳市',NULL,1,5,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(4,'merchant04','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'小米官方旗舰店',NULL,'小米客服','400-100-5678','service@xiaomi.com','北京市海淀区',NULL,1,1,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(5,'merchant05','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'名创优品官方店',NULL,'名创客服','400-123-4567','service@miniso.com','广东省广州市',NULL,1,1,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(6,'merchant06','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'三只松鼠旗舰店',NULL,'松鼠客服','400-800-1234','service@sanzhi.com','安徽省芜湖市',NULL,1,4,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(7,'merchant07','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'完美日记旗舰店',NULL,'完美日记客服','400-600-8888','service@perfect.com','广东省广州市',NULL,1,4,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(8,'merchant08','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'李宁官方旗舰店',NULL,'李宁客服','400-610-0011','service@lining.com','北京市通州区李宁工业园',NULL,1,4,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(9,'merchant09','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'Nike耐克官方旗舰店',NULL,'Nike客服','400-880-6453','service@nike.com','上海市静安区南京西路',NULL,1,5,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(10,'merchant10','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'当当图书旗舰店',NULL,'当当客服','400-106-6666','service@dangdang.com','北京市朝阳区安慧里',NULL,1,3,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(11,'merchant11','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'孩子王官方旗舰店',NULL,'孩子王客服','400-888-9999','service@haiziwang.com','南京市建邺区新城科技园',NULL,1,3,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(12,'merchant12','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'良品铺子旗舰店',NULL,'良品客服','400-117-7577','service@liangpinpuzi.com','湖北省武汉市东西湖区',NULL,1,3,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(13,'merchant13','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'宜家家居旗舰店',NULL,'宜家客服','400-800-2345','service@ikea.com','上海市徐汇区漕溪路',NULL,1,4,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(14,'merchant14','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'安踏官方旗舰店',NULL,'安踏客服','400-886-8888','service@anta.com','福建省泉州市晋江市',NULL,1,4,'2026-07-01 20:16:23','2026-07-01 20:16:23'),(15,'merchant15','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de',NULL,'兰蔻官方旗舰店',NULL,'兰蔻客服','400-820-8088','service@lancome.com','上海市静安区南京西路',NULL,1,5,'2026-07-01 20:16:23','2026-07-01 20:16:23');
/*!40000 ALTER TABLE `merchant` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_coupon_participation`
--

DROP TABLE IF EXISTS `merchant_coupon_participation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_coupon_participation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '参与ID',
  `template_id` bigint NOT NULL COMMENT '活动模板ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `status` tinyint DEFAULT '0' COMMENT '状态：0待审核 1已通过 2已拒绝',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家优惠券参与表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_coupon_participation`
--

LOCK TABLES `merchant_coupon_participation` WRITE;
/*!40000 ALTER TABLE `merchant_coupon_participation` DISABLE KEYS */;
INSERT INTO `merchant_coupon_participation` VALUES (1,1,1,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(2,2,1,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(3,3,1,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(4,3,1,2,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(5,4,2,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(6,5,2,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(7,7,3,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(8,8,3,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(9,10,4,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(10,11,4,0,2,'2026-07-01 19:54:36','2026-07-01 19:54:36');
/*!40000 ALTER TABLE `merchant_coupon_participation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_group_participation`
--

DROP TABLE IF EXISTS `merchant_group_participation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_group_participation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '参与ID',
  `template_id` bigint NOT NULL COMMENT '活动模板ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `group_price` decimal(10,2) NOT NULL COMMENT '拼团价',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `total_stock` int DEFAULT '0' COMMENT '总库存',
  `available_stock` int DEFAULT '0' COMMENT '可用库存',
  `status` tinyint DEFAULT '0' COMMENT '状态：0待审核 1已通过 2已拒绝',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家拼团参与表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_group_participation`
--

LOCK TABLES `merchant_group_participation` WRITE;
/*!40000 ALTER TABLE `merchant_group_participation` DISABLE KEYS */;
INSERT INTO `merchant_group_participation` VALUES (1,1,1,1,NULL,8499.00,9999.00,100,100,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(2,1,1,5,NULL,1614.00,1899.00,200,200,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(3,2,1,2,NULL,11249.00,14999.00,30,30,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(4,1,3,17,NULL,7649.00,8999.00,80,80,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(5,2,3,18,NULL,7499.00,9999.00,20,20,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(6,1,4,24,NULL,5524.00,6499.00,120,120,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(7,3,2,11,NULL,224.00,249.00,500,500,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(8,1,8,52,NULL,509.00,599.00,150,150,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(9,2,9,59,NULL,974.00,1299.00,50,50,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(10,3,15,103,NULL,288.00,320.00,300,300,2,'2026-07-01 19:54:36','2026-07-01 19:54:36');
/*!40000 ALTER TABLE `merchant_group_participation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_seckill_participation`
--

DROP TABLE IF EXISTS `merchant_seckill_participation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_seckill_participation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '参与ID',
  `template_id` bigint NOT NULL COMMENT '活动模板ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `seckill_price` decimal(10,2) NOT NULL COMMENT '秒杀价',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `total_stock` int DEFAULT '0' COMMENT '总库存',
  `available_stock` int DEFAULT '0' COMMENT '可用库存',
  `limit_per_user` int DEFAULT '1' COMMENT '每人限购数量',
  `status` tinyint DEFAULT '0' COMMENT '状态：0待审核 1已通过 2已拒绝',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家秒杀参与表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_seckill_participation`
--

LOCK TABLES `merchant_seckill_participation` WRITE;
/*!40000 ALTER TABLE `merchant_seckill_participation` DISABLE KEYS */;
INSERT INTO `merchant_seckill_participation` VALUES (1,1,1,1,NULL,6999.00,9999.00,50,50,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(2,1,1,2,NULL,10499.00,14999.00,20,20,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(3,2,1,5,NULL,1519.00,1899.00,100,100,2,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(4,3,1,7,NULL,4199.00,5999.00,30,30,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(5,1,3,17,NULL,6299.00,8999.00,40,40,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(6,2,3,20,NULL,1039.00,1299.00,80,80,2,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(7,1,4,24,NULL,4549.00,6499.00,60,60,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(8,2,4,26,NULL,303.00,379.00,150,150,3,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(9,1,9,59,NULL,909.00,1299.00,30,30,1,2,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(10,2,9,60,NULL,639.00,799.00,100,100,2,2,'2026-07-01 19:54:36','2026-07-01 19:54:36');
/*!40000 ALTER TABLE `merchant_seckill_participation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `merchant_stats`
--

DROP TABLE IF EXISTS `merchant_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `merchant_stats` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `total_orders` int DEFAULT '0' COMMENT '总订单数',
  `total_sales` decimal(15,2) DEFAULT '0.00' COMMENT '总销售额',
  `today_orders` int DEFAULT '0' COMMENT '今日订单数',
  `today_sales` decimal(15,2) DEFAULT '0.00' COMMENT '今日销售额',
  `product_count` int DEFAULT '0' COMMENT '商品数量',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `merchant_id` (`merchant_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商家统计表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `merchant_stats`
--

LOCK TABLES `merchant_stats` WRITE;
/*!40000 ALTER TABLE `merchant_stats` DISABLE KEYS */;
/*!40000 ALTER TABLE `merchant_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message`
--

DROP TABLE IF EXISTS `message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `title` varchar(200) NOT NULL COMMENT '消息标题',
  `content` text COMMENT '消息内容',
  `type` tinyint DEFAULT '1' COMMENT '类型：1订单通知 2退款通知 3活动通知 4系统通知',
  `is_read` tinyint DEFAULT '0' COMMENT '是否已读：0未读 1已读',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='消息表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message`
--

LOCK TABLES `message` WRITE;
/*!40000 ALTER TABLE `message` DISABLE KEYS */;
/*!40000 ALTER TABLE `message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operation_log`
--

DROP TABLE IF EXISTS `operation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `operation_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `module` varchar(50) DEFAULT NULL COMMENT '模块：order/refund/product等',
  `operation` varchar(100) DEFAULT NULL COMMENT '操作名称',
  `business_id` bigint DEFAULT NULL COMMENT '业务ID',
  `operator_type` tinyint DEFAULT NULL COMMENT '操作人类型：1用户 2商家 3管理员',
  `operator_id` bigint DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(100) DEFAULT NULL COMMENT '操作人名称',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `request_params` text COMMENT '请求参数',
  `result` text COMMENT '操作结果',
  `status` tinyint DEFAULT '1' COMMENT '状态：0失败 1成功',
  `error_msg` varchar(500) DEFAULT NULL COMMENT '错误信息',
  `cost_time` bigint DEFAULT NULL COMMENT '耗时(ms)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_module` (`module`),
  KEY `idx_business_id` (`business_id`),
  KEY `idx_operator` (`operator_type`,`operator_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operation_log`
--

LOCK TABLES `operation_log` WRITE;
/*!40000 ALTER TABLE `operation_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `operation_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `parent_order_id` bigint DEFAULT '0' COMMENT '父订单ID，0表示主订单/普通订单',
  `order_type` tinyint DEFAULT '1' COMMENT '订单类型：1普通订单 2拼团订单 3秒杀订单',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '订单总金额（商品合计）',
  `freight_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '运费',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '优惠金额',
  `pay_amount` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT '实付金额',
  `coupon_id` bigint DEFAULT NULL COMMENT '使用的优惠券ID（user_coupon.id）',
  `coupon_ids` varchar(255) DEFAULT NULL COMMENT '使用的优惠券ID列表，JSON格式如[1,2]',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0待支付 1已支付/待发货 2已发货 3已完成 4已取消 5退款中 6已退款 7已过期',
  `group_buy_team_id` bigint DEFAULT NULL COMMENT '拼单团队ID',
  `group_buy_time` datetime DEFAULT NULL COMMENT '拼单时间',
  `address_id` bigint DEFAULT NULL COMMENT '收货地址ID',
  `receiver_name` varchar(50) DEFAULT NULL COMMENT '收货人',
  `receiver_phone` varchar(20) DEFAULT NULL COMMENT '收货人手机号',
  `receiver_address` varchar(255) DEFAULT NULL COMMENT '收货地址',
  `pay_method` tinyint DEFAULT NULL COMMENT '支付方式：1微信 2支付宝 3余额',
  `pay_trade_no` varchar(64) DEFAULT NULL COMMENT '支付流水号',
  `pay_time` datetime DEFAULT NULL COMMENT '支付时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '发货时间',
  `express_company` varchar(50) DEFAULT NULL COMMENT '快递公司',
  `tracking_no` varchar(64) DEFAULT NULL COMMENT '物流单号',
  `receive_time` datetime DEFAULT NULL COMMENT '确认收货时间',
  `cancel_time` datetime DEFAULT NULL COMMENT '取消时间',
  `cancel_reason` varchar(255) DEFAULT NULL COMMENT '取消原因',
  `remark` varchar(255) DEFAULT NULL COMMENT '订单备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_status` (`status`),
  KEY `idx_coupon_id` (`coupon_id`),
  KEY `idx_group_buy_team_id` (`group_buy_team_id`),
  KEY `idx_parent_order_id` (`parent_order_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单主表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order`
--

LOCK TABLES `order` WRITE;
/*!40000 ALTER TABLE `order` DISABLE KEYS */;
INSERT INTO `order` VALUES (4,0,0,'O202607012021032543',2,1,9999.00,0.00,0.00,9999.00,NULL,NULL,6,1,'2026-07-01 20:21:04',2,'hhh','18877777777','云南省昆明市五华区44',1,'MOCK9e0c3cb775754918','2026-07-01 20:21:11',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-01 20:21:04','2026-07-03 20:06:49'),(8,0,0,'O202607012232585908',3,7,119.00,0.00,15.00,104.00,6,'[6]',3,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCK767fb74d43f14cad','2026-07-01 22:32:59','2026-07-01 23:17:42','顺丰速运','SF19061168532000','2026-07-02 23:33:09',NULL,NULL,'','2026-07-01 22:32:58','2026-07-02 23:33:09'),(9,0,0,'O202607012316217451',3,7,129.00,0.00,0.00,129.00,NULL,NULL,3,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',3,'MOCK190dd60256364eaf','2026-07-01 23:16:30','2026-07-01 23:17:39','顺丰速运','SF19057579559450','2026-07-01 23:18:03',NULL,NULL,'','2026-07-01 23:16:21','2026-07-02 00:35:44'),(10,0,0,'O202607021558221871',3,1,9999.00,0.00,0.00,9999.00,NULL,NULL,4,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-02 16:15:37','超时未支付，系统自动取消',NULL,'2026-07-02 15:58:23','2026-07-02 16:15:37'),(13,0,0,'O202607022011477423',3,9,799.00,0.00,60.00,739.00,61,'[61,60]',5,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCK397688ba7a8840b9','2026-07-02 20:11:50',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-02 20:11:48','2026-07-02 23:33:00'),(14,0,0,'O202607022012395872',3,9,229.00,0.00,0.00,229.00,NULL,NULL,5,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCK78d3fde157594ba1','2026-07-02 20:12:41',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-02 20:12:39','2026-07-02 23:32:56'),(16,0,0,'O202607022253060189',3,1,9999.00,0.00,0.00,9999.00,NULL,NULL,5,3,'2026-07-02 22:53:07',1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCKaf120870c3cc4a62','2026-07-02 22:53:08',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-02 22:53:07','2026-07-02 23:32:47'),(17,0,0,'O202607022253215603',3,1,9999.00,0.00,0.00,9999.00,NULL,NULL,5,4,'2026-07-02 22:53:21',1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCK24cd930a59ec4ff8','2026-07-02 22:53:22',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-02 22:53:21','2026-07-02 23:32:44'),(18,0,0,'O202607022331449561',3,3,8999.00,0.00,0.00,8999.00,NULL,NULL,5,10,'2026-07-02 23:31:44',1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCK0f4c208dac7d40a1','2026-07-02 23:31:46',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-02 23:31:44','2026-07-02 23:32:41'),(20,0,0,'O202607030024047740',3,1,10000.00,0.00,0.00,10000.00,NULL,NULL,4,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 00:41:37','超时未支付，系统自动取消','','2026-07-03 00:24:04','2026-07-03 00:41:37'),(21,0,0,'O202607030059028842',3,14,129.00,0.00,0.00,129.00,NULL,NULL,4,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 01:16:37','超时未支付，系统自动取消','','2026-07-03 00:59:03','2026-07-03 01:16:37'),(22,0,0,'O202607030104032628',3,14,129.00,0.00,0.00,129.00,NULL,NULL,1,NULL,NULL,1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCKac9c8c41710f485c','2026-07-03 01:04:05',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 01:04:04','2026-07-03 01:04:05'),(24,0,0,'O202607030109485689',3,10,19.90,10.00,0.00,29.90,NULL,NULL,5,12,'2026-07-03 01:09:48',1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCKfceb3e624e4b4ef6','2026-07-03 01:09:49',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 01:09:48','2026-07-03 01:32:30'),(25,0,0,'O202607030132442619',3,10,19.90,10.00,0.00,29.90,NULL,NULL,1,13,'2026-07-03 01:32:44',1,'1','13312343456','河北省秦皇岛市抚宁区111',1,'MOCK44314d126eb34532','2026-07-03 01:32:48',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 01:32:44','2026-07-03 01:32:48'),(26,0,0,'O202607030133088233',1,10,19.90,10.00,0.00,29.90,NULL,NULL,1,13,'2026-07-03 01:33:08',3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCKb1c3a801f96b4d1a','2026-07-03 01:33:15',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 01:33:08','2026-07-03 01:33:15'),(27,0,0,'O202607030133251025',1,10,21.00,10.00,0.00,31.00,NULL,NULL,1,14,'2026-07-03 01:33:26',3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCK045a1e579452407b','2026-07-03 01:36:53',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 01:33:26','2026-07-03 01:36:53'),(28,0,0,'O202607030139204311',3,10,21.00,10.00,0.00,31.00,NULL,NULL,4,14,'2026-07-03 01:39:21',1,'1','13312343456','河北省秦皇岛市抚宁区111',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 01:56:37','超时未支付，系统自动取消',NULL,'2026-07-03 01:39:21','2026-07-03 01:56:37'),(29,0,0,'O202607031643196512',1,1,9700.00,0.00,310.00,9390.00,64,'[64,63]',1,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCK1afb28235b14456d','2026-07-03 16:43:22',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 16:43:20','2026-07-03 16:43:22'),(30,0,0,'O202607031816038628',1,7,129.00,0.00,0.00,129.00,NULL,NULL,1,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCK19c2373f27d14087','2026-07-03 18:20:16',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 18:16:03','2026-07-03 18:20:16'),(31,0,0,'O202607031823073947',1,1,9700.00,0.00,0.00,9700.00,NULL,NULL,3,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCK59a1d0ec3e8d4d68','2026-07-03 18:23:14','2026-07-03 18:24:04','顺丰速运','SF74241688255865','2026-07-03 18:24:53',NULL,NULL,'111','2026-07-03 18:23:08','2026-07-03 19:57:21'),(32,0,0,'O202607031827597502',1,1,9700.00,0.00,0.00,9700.00,NULL,NULL,1,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCKa0d9005bcbfb4560','2026-07-03 18:28:01',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 18:28:00','2026-07-03 18:28:01'),(33,0,0,'O202607031828093318',1,1,9700.00,0.00,0.00,9700.00,NULL,NULL,1,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCKf9a327f4d057431b','2026-07-03 18:28:12',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 18:28:10','2026-07-03 18:28:12'),(34,0,0,'O202607031907465140',1,1,9700.00,0.00,0.00,9700.00,NULL,NULL,1,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCKd5d98ac81a304c2c','2026-07-03 19:07:52',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 19:07:47','2026-07-03 19:07:52'),(35,0,0,'O202607031952001201',1,1,9700.00,0.00,0.00,9700.00,NULL,NULL,4,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 20:10:37','超时未支付，系统自动取消','','2026-07-03 19:52:01','2026-07-03 20:10:37'),(36,0,0,'O202607031953585113',1,12,25.90,10.00,0.00,35.90,NULL,NULL,1,15,'2026-07-03 19:53:59',3,'小王','17666663622','云南省昆明市五华区我家',2,'MOCK8e121b92bce84093','2026-07-03 19:54:02',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 19:53:59','2026-07-03 19:54:02'),(37,0,0,'O202607031957557792',1,6,89.90,10.00,0.00,99.90,NULL,NULL,1,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCK61936c2bd040415e','2026-07-03 19:57:57',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 19:57:55','2026-07-03 19:57:57'),(38,0,0,'O202607032001185451',1,7,99.00,0.00,0.00,99.00,NULL,NULL,3,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCKc52d8f5de9af4bd4','2026-07-03 20:01:23','2026-07-03 20:02:09','京东物流','JD80125388134804','2026-07-03 20:02:30',NULL,NULL,'','2026-07-03 20:01:18','2026-07-03 20:02:30'),(39,0,0,'O202607032004006122',1,1,9999.00,0.00,0.00,9999.00,NULL,NULL,5,NULL,NULL,3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCK7c3443d705a44aaf','2026-07-03 20:04:02','2026-07-03 20:04:19','圆通速递','SF80255201023669','2026-07-03 20:04:54',NULL,NULL,'','2026-07-03 20:04:00','2026-07-03 20:05:05'),(40,0,0,'O202607032008037691',2,1,9999.00,0.00,0.00,9999.00,NULL,NULL,3,16,'2026-07-03 20:08:03',2,'hhh','18877777777','云南省昆明市五华区44',1,'MOCKb77bdcdd06874e2a','2026-07-03 20:08:05','2026-07-03 20:11:10','顺丰速运','SF80669021236305','2026-07-03 20:11:39',NULL,NULL,'','2026-07-03 20:08:03','2026-07-03 20:13:34'),(41,0,0,'O202607032009239650',1,1,9999.00,0.00,0.00,9999.00,NULL,NULL,2,16,'2026-07-03 20:09:23',3,'小王','17666663622','云南省昆明市五华区我家',1,'MOCKa04bbb4a20124a80','2026-07-03 20:09:25','2026-07-03 20:09:45','顺丰速运','SF80582850489959',NULL,NULL,NULL,NULL,'2026-07-03 20:09:23','2026-07-03 20:09:45'),(42,0,0,'O202607032017145114',2,1,9999.00,0.00,0.00,9999.00,NULL,NULL,1,17,'2026-07-03 20:17:15',2,'hhh','18877777777','云南省昆明市五华区44',2,'MOCK03c32f2379ca476f','2026-07-03 20:17:21',NULL,NULL,NULL,NULL,NULL,NULL,'','2026-07-03 20:17:15','2026-07-03 20:17:21');
/*!40000 ALTER TABLE `order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_item`
--

DROP TABLE IF EXISTS `order_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `product_name` varchar(200) NOT NULL COMMENT '商品名称（快照）',
  `product_image` varchar(255) DEFAULT NULL COMMENT '商品图片（快照）',
  `spec_values` varchar(255) DEFAULT NULL COMMENT '规格值（快照）',
  `price` decimal(10,2) NOT NULL COMMENT '单价（快照）',
  `quantity` int NOT NULL COMMENT '数量',
  `subtotal` decimal(10,2) NOT NULL COMMENT '小计',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_item`
--

LOCK TABLES `order_item` WRITE;
/*!40000 ALTER TABLE `order_item` DISABLE KEYS */;
INSERT INTO `order_item` VALUES (1,1,7,NULL,1,'iPhone 15','https://picsum.photos/400/400?random=7',NULL,5999.00,1,5999.00,'2026-07-01 20:02:32'),(2,2,20,NULL,3,'华为 FreeBuds Pro 3','https://picsum.photos/400/400?random=20',NULL,1299.00,1,1299.00,'2026-07-01 20:02:46'),(3,3,10,NULL,2,'优衣库牛仔裤','https://picsum.photos/400/400?random=10',NULL,199.00,1,199.00,'2026-07-01 20:03:04'),(4,4,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-01 20:21:04'),(5,5,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-01 20:42:23'),(6,6,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-01 21:03:19'),(7,7,17,NULL,3,'HUAWEI Mate 60 Pro+','https://picsum.photos/400/400?random=17',NULL,8999.00,1,8999.00,'2026-07-01 22:32:29'),(8,8,50,NULL,7,'完美日记气垫BB霜','https://picsum.photos/400/400?random=50',NULL,119.00,1,119.00,'2026-07-01 22:32:58'),(9,9,47,NULL,7,'完美日记动物眼影盘','https://picsum.photos/400/400?random=47',NULL,129.00,1,129.00,'2026-07-01 23:16:21'),(10,10,1,1,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-02 15:58:23'),(11,11,1,1,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-02 15:58:35'),(12,12,1,1,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-02 16:16:43'),(13,13,60,NULL,9,'Nike Air Force 1','https://picsum.photos/400/400?random=60',NULL,799.00,1,799.00,'2026-07-02 20:11:48'),(14,14,61,NULL,9,'Nike Pro运动T恤','https://picsum.photos/400/400?random=61',NULL,229.00,1,229.00,'2026-07-02 20:12:39'),(15,15,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,10000.00,1,10000.00,'2026-07-02 22:52:57'),(16,16,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-02 22:53:07'),(17,17,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-02 22:53:21'),(18,18,17,NULL,3,'HUAWEI Mate 60 Pro+','https://picsum.photos/400/400?random=17',NULL,8999.00,1,8999.00,'2026-07-02 23:31:44'),(19,19,17,NULL,3,'HUAWEI Mate 60 Pro+','https://picsum.photos/400/400?random=17',NULL,8999.00,1,8999.00,'2026-07-02 23:50:46'),(20,20,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,10000.00,1,10000.00,'2026-07-03 00:24:04'),(21,21,96,NULL,14,'安踏运动T恤','https://picsum.photos/400/400?random=96',NULL,129.00,1,129.00,'2026-07-03 00:59:03'),(22,22,96,NULL,14,'安踏运动T恤','https://picsum.photos/400/400?random=96',NULL,129.00,1,129.00,'2026-07-03 01:04:04'),(23,23,96,NULL,14,'安踏运动T恤','https://picsum.photos/400/400?random=96',NULL,129.00,1,129.00,'2026-07-03 01:06:44'),(24,24,69,NULL,10,'新华字典 第12版','https://picsum.photos/400/400?random=69',NULL,19.90,1,19.90,'2026-07-03 01:09:48'),(25,25,69,NULL,10,'新华字典 第12版','https://picsum.photos/400/400?random=69',NULL,19.90,1,19.90,'2026-07-03 01:32:44'),(26,26,69,NULL,10,'新华字典 第12版','https://picsum.photos/400/400?random=69',NULL,19.90,1,19.90,'2026-07-03 01:33:08'),(27,27,67,NULL,10,'活着 余华','https://picsum.photos/400/400?random=67',NULL,21.00,1,21.00,'2026-07-03 01:33:26'),(28,28,67,NULL,10,'活着 余华','https://picsum.photos/400/400?random=67',NULL,21.00,1,21.00,'2026-07-03 01:39:21'),(29,29,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,9700.00,1,9700.00,'2026-07-03 16:43:20'),(30,30,47,NULL,7,'完美日记动物眼影盘','https://picsum.photos/400/400?random=47',NULL,129.00,1,129.00,'2026-07-03 18:16:03'),(31,31,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,9700.00,1,9700.00,'2026-07-03 18:23:08'),(32,32,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,9700.00,1,9700.00,'2026-07-03 18:28:00'),(33,33,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,9700.00,1,9700.00,'2026-07-03 18:28:10'),(34,34,108,5,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,9700.00,1,9700.00,'2026-07-03 19:07:47'),(35,35,108,NULL,1,'iPhone 18','https://picsum.photos/400/400?random=108',NULL,9700.00,1,9700.00,'2026-07-03 19:52:01'),(36,36,82,NULL,12,'良品铺子芒果干 108g','https://picsum.photos/400/400?random=82',NULL,25.90,1,25.90,'2026-07-03 19:53:59'),(37,37,39,NULL,6,'三只松鼠每日坚果 750g','https://picsum.photos/400/400?random=39',NULL,89.90,1,89.90,'2026-07-03 19:57:55'),(38,38,46,NULL,7,'完美日记小细跟口红','https://picsum.photos/400/400?random=46',NULL,99.00,1,99.00,'2026-07-03 20:01:18'),(39,39,1,1,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-03 20:04:00'),(40,40,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-03 20:08:03'),(41,41,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-03 20:09:23'),(42,42,1,NULL,1,'iPhone 15 Pro Max','https://picsum.photos/400/400?random=1',NULL,9999.00,1,9999.00,'2026-07-03 20:17:15');
/*!40000 ALTER TABLE `order_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_logistics_track`
--

DROP TABLE IF EXISTS `order_logistics_track`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_logistics_track` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `express_company` varchar(50) DEFAULT NULL COMMENT '快递公司',
  `tracking_no` varchar(50) DEFAULT NULL COMMENT '物流单号',
  `status` varchar(50) DEFAULT NULL COMMENT '物流状态',
  `location` varchar(200) DEFAULT NULL COMMENT '当前位置',
  `description` varchar(500) DEFAULT NULL COMMENT '描述',
  `track_time` datetime DEFAULT NULL COMMENT '轨迹时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单物流轨迹表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_logistics_track`
--

LOCK TABLES `order_logistics_track` WRITE;
/*!40000 ALTER TABLE `order_logistics_track` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_logistics_track` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_review`
--

DROP TABLE IF EXISTS `order_review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_review` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `order_item_id` bigint DEFAULT NULL COMMENT '订单明细ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `rating` tinyint NOT NULL DEFAULT '5' COMMENT '评分：1-5星',
  `content` varchar(1000) DEFAULT NULL COMMENT '评价内容',
  `images` varchar(1000) DEFAULT NULL COMMENT '晒图图片，逗号分隔',
  `is_anonymous` tinyint DEFAULT '0' COMMENT '是否匿名：0否 1是',
  `is_top` tinyint DEFAULT '0' COMMENT '是否置顶：0否 1是',
  `reply_content` varchar(500) DEFAULT NULL COMMENT '商家回复内容',
  `reply_time` datetime DEFAULT NULL COMMENT '回复时间',
  `status` tinyint DEFAULT '1' COMMENT '状态：0隐藏 1显示',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='订单评价表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_review`
--

LOCK TABLES `order_review` WRITE;
/*!40000 ALTER TABLE `order_review` DISABLE KEYS */;
INSERT INTO `order_review` VALUES (1,9,9,3,47,NULL,7,5,'1',NULL,0,0,NULL,NULL,1,'2026-07-02 00:47:00','2026-07-02 00:47:00'),(2,8,8,3,50,NULL,7,4,'号',NULL,0,0,NULL,NULL,1,'2026-07-02 23:51:35','2026-07-02 23:51:35'),(3,31,31,1,108,NULL,1,3,'111',NULL,1,0,NULL,NULL,1,'2026-07-03 18:25:27','2026-07-03 18:25:27');
/*!40000 ALTER TABLE `order_review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '支付ID',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `order_no` varchar(50) NOT NULL COMMENT '订单号',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `pay_method` tinyint NOT NULL COMMENT '支付方式：1微信 2支付宝 3余额',
  `pay_amount` decimal(10,2) NOT NULL COMMENT '支付金额',
  `pay_trade_no` varchar(64) DEFAULT NULL COMMENT '支付平台流水号',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0待支付 1支付成功 2支付失败 3已退款',
  `pay_time` datetime DEFAULT NULL COMMENT '支付成功时间',
  `callback_time` datetime DEFAULT NULL COMMENT '回调时间',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_id` (`order_id`),
  KEY `idx_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (1,1,'O202607012002311310',3,1,5999.00,'MOCK0f33aa4d41ba4b3e',1,'2026-07-01 20:02:33','2026-07-01 20:02:33','2026-07-01 20:02:33','2026-07-01 20:02:33'),(2,2,'O202607012002467764',3,2,1299.00,'MOCKe9ac4de3f42b4bb6',1,'2026-07-01 20:02:50','2026-07-01 20:02:50','2026-07-01 20:02:50','2026-07-01 20:02:50'),(3,4,'O202607012021032543',2,1,9999.00,'MOCK9e0c3cb775754918',1,'2026-07-01 20:21:11','2026-07-01 20:21:11','2026-07-01 20:21:11','2026-07-01 20:21:11'),(4,5,'O202607012042229720',3,1,9999.00,'MOCK9b7ed3e8817149ad',1,'2026-07-01 20:42:26','2026-07-01 20:42:26','2026-07-01 20:42:25','2026-07-01 20:42:26'),(5,6,'O202607012103182467',3,1,9499.00,'MOCKc104a0faf3964a27',1,'2026-07-01 21:03:21','2026-07-01 21:03:21','2026-07-01 21:03:21','2026-07-01 21:03:21'),(6,7,'O202607012232283779',3,1,8999.00,'MOCK8692a54a216e48c4',1,'2026-07-01 22:32:33','2026-07-01 22:32:33','2026-07-01 22:32:33','2026-07-01 22:32:33'),(7,8,'O202607012232585908',3,1,104.00,'MOCK767fb74d43f14cad',1,'2026-07-01 22:32:59','2026-07-01 22:32:59','2026-07-01 22:32:59','2026-07-01 22:32:59'),(8,9,'O202607012316217451',3,3,129.00,'MOCK190dd60256364eaf',1,'2026-07-01 23:16:30','2026-07-01 23:16:30','2026-07-01 23:16:30','2026-07-01 23:16:30'),(9,13,'O202607022011477423',3,1,739.00,'MOCK397688ba7a8840b9',1,'2026-07-02 20:11:50','2026-07-02 20:11:50','2026-07-02 20:11:50','2026-07-02 20:11:50'),(10,14,'O202607022012395872',3,1,229.00,'MOCK78d3fde157594ba1',1,'2026-07-02 20:12:41','2026-07-02 20:12:41','2026-07-02 20:12:41','2026-07-02 20:12:41'),(11,16,'O202607022253060189',3,1,9999.00,'MOCKaf120870c3cc4a62',1,'2026-07-02 22:53:08','2026-07-02 22:53:08','2026-07-02 22:53:08','2026-07-02 22:53:08'),(12,17,'O202607022253215603',3,1,9999.00,'MOCK24cd930a59ec4ff8',1,'2026-07-02 22:53:22','2026-07-02 22:53:22','2026-07-02 22:53:22','2026-07-02 22:53:22'),(13,18,'O202607022331449561',3,1,8999.00,'MOCK0f4c208dac7d40a1',1,'2026-07-02 23:31:46','2026-07-02 23:31:46','2026-07-02 23:31:46','2026-07-02 23:31:46'),(14,22,'O202607030104032628',3,1,129.00,'MOCKac9c8c41710f485c',1,'2026-07-03 01:04:05','2026-07-03 01:04:05','2026-07-03 01:04:05','2026-07-03 01:04:05'),(15,24,'O202607030109485689',3,1,29.90,'MOCKfceb3e624e4b4ef6',1,'2026-07-03 01:09:49','2026-07-03 01:09:49','2026-07-03 01:09:49','2026-07-03 01:09:49'),(16,25,'O202607030132442619',3,1,29.90,'MOCK44314d126eb34532',1,'2026-07-03 01:32:48','2026-07-03 01:32:48','2026-07-03 01:32:48','2026-07-03 01:32:48'),(17,26,'O202607030133088233',1,1,29.90,'MOCKb1c3a801f96b4d1a',1,'2026-07-03 01:33:15','2026-07-03 01:33:15','2026-07-03 01:33:15','2026-07-03 01:33:15'),(18,27,'O202607030133251025',1,1,31.00,'MOCK045a1e579452407b',1,'2026-07-03 01:36:53','2026-07-03 01:36:53','2026-07-03 01:36:53','2026-07-03 01:36:53'),(19,29,'O202607031643196512',1,1,9390.00,'MOCK1afb28235b14456d',1,'2026-07-03 16:43:22','2026-07-03 16:43:22','2026-07-03 16:43:22','2026-07-03 16:43:22'),(20,30,'O202607031816038628',1,1,129.00,'MOCK19c2373f27d14087',1,'2026-07-03 18:20:16','2026-07-03 18:20:16','2026-07-03 18:20:15','2026-07-03 18:20:16'),(21,31,'O202607031823073947',1,1,9700.00,'MOCK59a1d0ec3e8d4d68',1,'2026-07-03 18:23:14','2026-07-03 18:23:14','2026-07-03 18:23:14','2026-07-03 18:23:14'),(22,32,'O202607031827597502',1,1,9700.00,'MOCKa0d9005bcbfb4560',1,'2026-07-03 18:28:01','2026-07-03 18:28:01','2026-07-03 18:28:01','2026-07-03 18:28:01'),(23,33,'O202607031828093318',1,1,9700.00,'MOCKf9a327f4d057431b',1,'2026-07-03 18:28:12','2026-07-03 18:28:12','2026-07-03 18:28:12','2026-07-03 18:28:12'),(24,34,'O202607031907465140',1,1,9700.00,'MOCKd5d98ac81a304c2c',1,'2026-07-03 19:07:52','2026-07-03 19:07:52','2026-07-03 19:07:52','2026-07-03 19:07:52'),(25,36,'O202607031953585113',1,2,35.90,'MOCK8e121b92bce84093',1,'2026-07-03 19:54:02','2026-07-03 19:54:02','2026-07-03 19:54:02','2026-07-03 19:54:02'),(26,37,'O202607031957557792',1,1,99.90,'MOCK61936c2bd040415e',1,'2026-07-03 19:57:57','2026-07-03 19:57:57','2026-07-03 19:57:57','2026-07-03 19:57:57'),(27,38,'O202607032001185451',1,1,99.00,'MOCKc52d8f5de9af4bd4',1,'2026-07-03 20:01:23','2026-07-03 20:01:23','2026-07-03 20:01:23','2026-07-03 20:01:23'),(28,39,'O202607032004006122',1,1,9999.00,'MOCK7c3443d705a44aaf',1,'2026-07-03 20:04:02','2026-07-03 20:04:02','2026-07-03 20:04:02','2026-07-03 20:04:02'),(29,40,'O202607032008037691',2,1,9999.00,'MOCKb77bdcdd06874e2a',1,'2026-07-03 20:08:05','2026-07-03 20:08:05','2026-07-03 20:08:05','2026-07-03 20:08:05'),(30,41,'O202607032009239650',1,1,9999.00,'MOCKa04bbb4a20124a80',1,'2026-07-03 20:09:25','2026-07-03 20:09:25','2026-07-03 20:09:25','2026-07-03 20:09:25'),(31,42,'O202607032017145114',2,2,9999.00,'MOCK03c32f2379ca476f',1,'2026-07-03 20:17:21','2026-07-03 20:17:21','2026-07-03 20:17:21','2026-07-03 20:17:21');
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '权限ID',
  `parent_id` bigint DEFAULT '0' COMMENT '父级ID，0为顶级',
  `name` varchar(50) NOT NULL COMMENT '权限名称',
  `code` varchar(100) NOT NULL COMMENT '权限编码（如 order:list）',
  `type` tinyint NOT NULL DEFAULT '1' COMMENT '类型：1菜单 2按钮 3接口',
  `path` varchar(255) DEFAULT NULL COMMENT '前端路由路径',
  `component` varchar(255) DEFAULT NULL COMMENT '前端组件路径',
  `icon` varchar(50) DEFAULT NULL COMMENT '图标',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='权限（菜单）表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES (1,0,'工作台','dashboard',1,'/dashboard','Dashboard','DataLine',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(2,0,'订单管理','order',1,'/order','OrderList','Document',2,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(3,0,'退款管理','refund',1,'/refund','RefundList','Refund',3,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(4,0,'商品管理','product',1,'/product','ProductList','Goods',4,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(5,0,'商家管理','merchant',1,'/merchant','MerchantList','Shop',5,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(6,0,'活动配置','activity',1,'/activity','ActivityList','Promotion',6,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(7,0,'优惠券','coupon',1,'/coupon','CouponList','Discount',7,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(8,0,'系统管理','system',1,'/system','AdminList','Setting',8,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(9,2,'订单列表','order:list',1,'/order/list','OrderList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(10,3,'退款列表','refund:list',1,'/refund/list','RefundList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(11,4,'商品列表','product:list',1,'/product/list','ProductList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(12,5,'商家列表','merchant:list',1,'/merchant/list','MerchantList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(13,6,'活动列表','activity:list',1,'/activity/list','ActivityList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(14,7,'优惠券列表','coupon:list',1,'/coupon/list','CouponList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(15,8,'管理员管理','admin:list',1,'/system/admin','AdminList','',1,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(16,8,'角色管理','role:list',1,'/system/role','RoleList','',2,1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(17,8,'权限管理','permission:list',1,'/system/permission','PermissionList','',3,1,'2026-07-01 19:53:49','2026-07-01 19:53:49');
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_coupon_template`
--

DROP TABLE IF EXISTS `platform_coupon_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_coupon_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` varchar(100) NOT NULL COMMENT '优惠券名称',
  `type` tinyint NOT NULL COMMENT '类型：1满减券 2折扣券',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠金额（满减券）',
  `min_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低使用金额',
  `total_count` int DEFAULT '0' COMMENT '发放总量',
  `remaining_count` int DEFAULT '0' COMMENT '剩余数量',
  `per_user_limit` int DEFAULT '1' COMMENT '每人限领数量',
  `start_time` datetime DEFAULT NULL COMMENT '领取开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '领取结束时间',
  `description` varchar(500) DEFAULT NULL COMMENT '使用说明',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='平台优惠券模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_coupon_template`
--

LOCK TABLES `platform_coupon_template` WRITE;
/*!40000 ALTER TABLE `platform_coupon_template` DISABLE KEYS */;
INSERT INTO `platform_coupon_template` VALUES (1,'满300减30优惠券',1,30.00,300.00,10000,10000,2,'2026-07-01 19:54:36','2026-07-31 19:54:36','全场满300元减30元，每人限领2张',1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(2,'满500减50优惠券',1,50.00,500.00,5000,5000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36','全场满500元减50元，每人限领1张',1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(3,'满1000减100优惠券',1,100.00,1000.00,2000,2000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36','全场满1000元减100元，每人限领1张',1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(4,'新人专享50元券',1,50.00,200.00,50000,50000,1,'2026-07-01 19:54:36','2026-09-29 19:54:36','新用户专享，满200减50',1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(5,'全场9折优惠券',2,0.10,100.00,3000,3000,1,'2026-07-01 19:54:36','2026-07-16 19:54:36','全场9折优惠，满100元可用',1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(6,'VIP专属8折券',2,0.20,500.00,1000,1000,1,'2026-07-01 19:54:36','2026-07-31 19:54:36','VIP会员专属8折券，满500可用',1,'2026-07-01 19:54:36','2026-07-01 19:54:36');
/*!40000 ALTER TABLE `platform_coupon_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_group_template`
--

DROP TABLE IF EXISTS `platform_group_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_group_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` varchar(200) NOT NULL COMMENT '活动名称',
  `required_num` int NOT NULL DEFAULT '3' COMMENT '成团人数',
  `discount_rate` decimal(5,2) DEFAULT NULL COMMENT '折扣比例',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `group_duration` int DEFAULT '24' COMMENT '成团有效期(小时)',
  `description` varchar(500) DEFAULT NULL COMMENT '活动描述',
  `banner` varchar(255) DEFAULT NULL COMMENT '活动banner',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='平台拼团活动模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_group_template`
--

LOCK TABLES `platform_group_template` WRITE;
/*!40000 ALTER TABLE `platform_group_template` DISABLE KEYS */;
INSERT INTO `platform_group_template` VALUES (1,'3人成团享优惠',3,0.85,'2026-07-01 19:54:36','2026-07-31 19:54:36',24,'3人成团即可享受85折优惠',NULL,1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(2,'5人超值拼团',5,0.75,'2026-07-01 19:54:36','2026-07-31 19:54:36',48,'5人成团享受75折超值优惠',NULL,1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(3,'2人情侣拼团',2,0.90,'2026-07-01 19:54:36','2026-07-31 19:54:36',12,'2人成团享受9折优惠，情侣专属',NULL,1,'2026-07-01 19:54:36','2026-07-01 19:54:36');
/*!40000 ALTER TABLE `platform_group_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_seckill_template`
--

DROP TABLE IF EXISTS `platform_seckill_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_seckill_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模板ID',
  `name` varchar(200) NOT NULL COMMENT '活动名称',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `discount_rate` decimal(5,2) DEFAULT NULL COMMENT '折扣比例(如0.8表示8折)',
  `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT '最大优惠金额',
  `description` varchar(500) DEFAULT NULL COMMENT '活动描述',
  `banner` varchar(255) DEFAULT NULL COMMENT '活动banner',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='平台秒杀活动模板表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_seckill_template`
--

LOCK TABLES `platform_seckill_template` WRITE;
/*!40000 ALTER TABLE `platform_seckill_template` DISABLE KEYS */;
INSERT INTO `platform_seckill_template` VALUES (1,'618年中大促秒杀','2026-06-30 19:54:36','2026-07-04 19:54:36',0.70,500.00,'618年中大促，精选商品限时秒杀，最高优惠500元',NULL,1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(2,'每日10点秒杀','2026-07-01 20:54:36','2026-07-31 19:54:36',0.80,300.00,'每天10点准时开抢，限时秒杀不容错过',NULL,1,'2026-07-01 19:54:36','2026-07-01 19:54:36'),(3,'新品首发秒杀','2026-07-03 19:54:36','2026-07-08 19:54:36',0.75,200.00,'新品首发限时秒杀，抢先体验新品',NULL,1,'2026-07-01 19:54:36','2026-07-01 19:54:36');
/*!40000 ALTER TABLE `platform_seckill_template` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `points_record`
--

DROP TABLE IF EXISTS `points_record`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `points_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '积分记录ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `points` int NOT NULL COMMENT '积分变动数量',
  `type` tinyint DEFAULT NULL COMMENT '类型：1获取，2消费，3过期',
  `source` varchar(100) DEFAULT NULL COMMENT '来源描述',
  `order_no` varchar(50) DEFAULT NULL COMMENT '关联订单号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='积分记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `points_record`
--

LOCK TABLES `points_record` WRITE;
/*!40000 ALTER TABLE `points_record` DISABLE KEYS */;
/*!40000 ALTER TABLE `points_record` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `merchant_id` bigint NOT NULL COMMENT '商家ID',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `name` varchar(200) NOT NULL COMMENT '商品名称',
  `sub_title` varchar(500) DEFAULT NULL COMMENT '副标题',
  `brand` varchar(100) DEFAULT NULL COMMENT '品牌',
  `image_url` varchar(255) DEFAULT NULL COMMENT '主图URL',
  `detail_images` varchar(1000) DEFAULT NULL COMMENT '详情图片，逗号分隔',
  `price` decimal(10,2) NOT NULL COMMENT '售价',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `has_group_buy` int DEFAULT '0' COMMENT '是否开启拼团 0-关闭 1-开启',
  `group_price` decimal(10,2) DEFAULT NULL COMMENT '拼团价',
  `group_num` int DEFAULT '2' COMMENT '拼团人数',
  `stock` int NOT NULL DEFAULT '0' COMMENT '库存',
  `sales_count` int DEFAULT '0' COMMENT '销量',
  `description` text COMMENT '商品详情',
  `status` tinyint DEFAULT '1' COMMENT '状态：0下架 1上架 2售罄',
  `is_hot` tinyint DEFAULT '0' COMMENT '是否热销：0否 1是',
  `is_new` tinyint DEFAULT '0' COMMENT '是否新品：0否 1是',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_sales_count` (`sales_count`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,1,11,'iPhone 15 Pro Max','A17 Pro芯片 钛金属设计','Apple','https://picsum.photos/400/400?random=1','[]',9999.00,10999.00,0,NULL,2,57,49,'iPhone 15 Pro Max 256GB 深空黑',1,1,1,0,'2026-07-01 19:54:19','2026-07-03 20:39:17'),(2,1,21,'MacBook Pro 14英寸','M3 Pro芯片 专业级性能','Apple','https://picsum.photos/400/400?random=2','[]',14999.00,16499.00,0,NULL,2,60,25,'MacBook Pro 14寸 M3 Pro 18+512GB',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(3,1,12,'iPad Pro 12.9英寸','M2芯片 Liquid视网膜XDR屏','Apple','https://picsum.photos/400/400?random=3','[]',9299.00,10299.00,0,NULL,2,100,35,'iPad Pro 12.9寸 M2 256GB',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(4,1,13,'Apple Watch Series 9','S9芯片 精准健康监测','Apple','https://picsum.photos/400/400?random=4','[]',2999.00,3199.00,0,NULL,2,150,70,'Apple Watch Series 9 GPS款 45mm',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(5,1,14,'AirPods Pro 2代','主动降噪 自适应音频','Apple','https://picsum.photos/400/400?random=5','[]',1899.00,2099.00,0,NULL,2,200,90,'AirPods Pro 第二代 USB-C',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(6,1,21,'Mac mini M2','小巧精致 性能强劲','Apple','https://picsum.photos/400/400?random=6','[]',4499.00,4999.00,0,NULL,2,80,30,'Mac mini M2 8+256GB',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(7,1,11,'iPhone 15','灵动岛 A16芯片','Apple','https://picsum.photos/400/400?random=7','[]',5999.00,6499.00,0,NULL,2,119,56,'iPhone 15 128GB 蓝色',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(8,1,14,'AirPods Max','头戴式降噪耳机','Apple','https://picsum.photos/400/400?random=8','[]',3999.00,4399.00,0,NULL,2,100,40,'AirPods Max 银色',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(9,2,31,'优衣库圆领T恤','纯棉舒适 多色可选','UNIQLO','https://picsum.photos/400/400?random=9','[]',99.00,149.00,0,NULL,2,500,280,'优衣库男士圆领T恤 纯棉基础款',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(10,2,31,'优衣库牛仔裤','修身剪裁 经典款式','UNIQLO','https://picsum.photos/400/400?random=10','[]',199.00,299.00,0,NULL,2,400,200,'优衣库男士牛仔裤 直筒版型',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(11,2,32,'优衣库连衣裙','夏季新款 简约时尚','UNIQLO','https://picsum.photos/400/400?random=11','[]',249.00,349.00,0,NULL,2,300,150,'优衣库女士连衣裙 通勤款',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(12,2,31,'优衣库衬衫','商务休闲 易于搭配','UNIQLO','https://picsum.photos/400/400?random=12','[]',149.00,249.00,0,NULL,2,350,160,'优衣库男士长袖衬衫',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(13,2,31,'优衣库卫衣','加绒保暖 休闲百搭','UNIQLO','https://picsum.photos/400/400?random=13','[]',199.00,299.00,0,NULL,2,300,140,'优衣库连帽卫衣',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(14,2,32,'优衣库女款针织衫','柔软舒适 春秋必备','UNIQLO','https://picsum.photos/400/400?random=14','[]',179.00,279.00,0,NULL,2,250,120,'优衣库女士针织开衫',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(15,2,33,'优衣库运动短裤','速干透气 运动舒适','UNIQLO','https://picsum.photos/400/400?random=15','[]',99.00,149.00,0,NULL,2,400,180,'优衣库男士运动短裤',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(16,2,31,'优衣库保暖内衣','HeatTech发热技术','UNIQLO','https://picsum.photos/400/400?random=16','[]',149.00,199.00,0,NULL,2,450,200,'优衣库HeatTech保暖内衣套装',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(17,3,11,'HUAWEI Mate 60 Pro+','麒麟9000S 卫星通话','华为','https://picsum.photos/400/400?random=17','[]',8999.00,9999.00,0,NULL,2,148,62,'华为Mate60 Pro+ 16GB+1TB 砚黑',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(18,3,11,'HUAWEI Pura 70 Ultra','超聚光伸缩镜头 影像旗舰','华为','https://picsum.photos/400/400?random=18','[]',9999.00,10999.00,0,NULL,2,80,25,'华为Pura70 Ultra 16GB+512GB',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(19,3,12,'华为 MatePad Pro 13.2','鸿蒙系统 生产力工具','华为','https://picsum.photos/400/400?random=19','[]',5499.00,5999.00,0,NULL,2,100,40,'华为MatePad Pro 13.2英寸',1,1,0,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(20,3,14,'华为 FreeBuds Pro 3','主动降噪 Hi-Res音质','华为','https://picsum.photos/400/400?random=20','[]',1299.00,1499.00,0,NULL,2,299,121,'华为FreeBuds Pro 3 星河蓝',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(21,3,13,'华为 Watch GT 4','14天续航 专业健康监测','华为','https://picsum.photos/400/400?random=21','[]',1488.00,1688.00,0,NULL,2,200,80,'华为Watch GT 4 46mm',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(22,3,11,'华为 MateBook X Pro','超轻薄 3.1K原色屏','华为','https://picsum.photos/400/400?random=22','[]',11999.00,12999.00,0,NULL,2,60,15,'华为MateBook X Pro 2024款',1,0,0,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(23,3,11,'华为 nova 12 Pro','前置6000万 追焦双摄','华为','https://picsum.photos/400/400?random=23','[]',3999.00,4499.00,0,NULL,2,250,90,'华为nova 12 Pro 256GB',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(24,4,11,'小米14 Ultra','徕卡专业影像 骁龙8 Gen3','小米','https://picsum.photos/400/400?random=24','[]',6499.00,6999.00,0,NULL,2,200,80,'小米14 Ultra 徕卡光学Summilux镜头',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(25,4,3,'小米电视 S Pro 75英寸','Mini LED 高画质','小米','https://picsum.photos/400/400?random=25','[]',4999.00,5999.00,0,NULL,2,100,30,'小米电视 S Pro 75英寸 Mini LED',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(26,4,13,'小米手环 8 Pro','大屏长续航 运动健康','小米','https://picsum.photos/400/400?random=26','[]',379.00,429.00,0,NULL,2,500,200,'小米手环8 Pro 黑色',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(27,4,3,'米家空气净化器 4 Pro','除甲醛 智能互联','小米','https://picsum.photos/400/400?random=27','[]',1499.00,1699.00,0,NULL,2,150,60,'米家空气净化器4 Pro',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(28,4,4,'小米保温杯','316不锈钢 大容量便携','小米','https://picsum.photos/400/400?random=28','[]',89.00,129.00,0,NULL,2,800,300,'小米保温杯 500ml',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(29,4,21,'RedmiBook Pro 15','标压处理器 高性能轻薄本','小米','https://picsum.photos/400/400?random=29','[]',4999.00,5499.00,0,NULL,2,120,40,'RedmiBook Pro 15 2024款',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(30,4,4,'小米电动牙刷 T700','声波震动 智能洁齿','小米','https://picsum.photos/400/400?random=30','[]',299.00,349.00,0,NULL,2,300,120,'小米电动牙刷T700',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(31,4,13,'Redmi Watch 4','大屏 AMOLED 智能手表','小米','https://picsum.photos/400/400?random=31','[]',599.00,699.00,0,NULL,2,250,90,'Redmi Watch 4',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(32,5,41,'名创优品香薰蜡烛','天然植物精油 持久留香','MINISO','https://picsum.photos/400/400?random=32','[]',39.90,59.90,0,NULL,2,600,250,'香薰蜡烛 100g 多种香型',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(33,5,41,'可爱毛绒玩偶','柔软亲肤 送礼自用','MINISO','https://picsum.photos/400/400?random=33','[]',29.90,49.90,0,NULL,2,1000,450,'可爱毛绒玩偶 20cm',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(34,5,41,'收纳整理盒三件套','桌面收纳 整洁有序','MINISO','https://picsum.photos/400/400?random=34','[]',49.90,79.90,0,NULL,2,400,180,'收纳盒三件套 透明可视',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(35,5,42,'保湿补水面膜 10片装','深层补水 肌肤焕亮','MINISO','https://picsum.photos/400/400?random=35','[]',59.90,89.90,0,NULL,2,500,220,'补水面膜 10片装',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(36,5,41,'保温杯 350ml','迷你便携 304不锈钢','MINISO','https://picsum.photos/400/400?random=36','[]',39.90,59.90,0,NULL,2,700,280,'MINISO保温杯 350ml',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(37,5,43,'MINISO笔记本套装','简约设计 文具礼盒','MINISO','https://picsum.photos/400/400?random=37','[]',24.90,39.90,0,NULL,2,800,320,'MINISO笔记本套装 3本装',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(38,5,42,'名创优品护手霜套装','滋润保湿 迷你便携','MINISO','https://picsum.photos/400/400?random=38','[]',19.90,29.90,0,NULL,2,600,280,'护手霜套装 3支装',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(39,6,51,'三只松鼠每日坚果 750g','8种坚果 科学配比','三只松鼠','https://picsum.photos/400/400?random=39','[]',89.90,129.90,0,NULL,2,499,301,'每日坚果 750g 30包',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(40,6,51,'三只松鼠夏威夷果','奶油味 开口易剥','三只松鼠','https://picsum.photos/400/400?random=40','[]',39.90,59.90,0,NULL,2,600,250,'夏威夷果 265g 奶油味',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(41,6,51,'三只松鼠辣条大礼包','网红零食 怀旧味道','三只松鼠','https://picsum.photos/400/400?random=41','[]',29.90,49.90,0,NULL,2,800,400,'辣条大礼包 520g',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(42,6,51,'三只松鼠碧根果','奶油味 醇香酥脆','三只松鼠','https://picsum.photos/400/400?random=42','[]',45.90,65.90,0,NULL,2,400,180,'碧根果 210g 奶油味',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(43,6,51,'三只松鼠水果干组合','芒果草莓 酸甜可口','三只松鼠','https://picsum.photos/400/400?random=43','[]',59.90,89.90,0,NULL,2,350,150,'水果干组合 400g',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(44,6,51,'三只松鼠牛肉干','香辣味 嚼劲十足','三只松鼠','https://picsum.photos/400/400?random=44','[]',69.90,99.90,0,NULL,2,300,120,'牛肉干 200g 香辣味',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(45,6,52,'三只松鼠开心果','盐焗味 自然开口','三只松鼠','https://picsum.photos/400/400?random=45','[]',49.90,69.90,0,NULL,2,450,190,'开心果 265g 盐焗味',1,1,0,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(46,7,41,'完美日记小细跟口红','丝绒哑光 高级质感','完美日记','https://picsum.photos/400/400?random=46','[]',99.00,129.00,0,NULL,2,399,221,'小细跟口红 3.6g 多色可选',1,1,0,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(47,7,41,'完美日记动物眼影盘','12色大盘 日常百搭','完美日记','https://picsum.photos/400/400?random=47','[]',129.00,169.00,0,NULL,2,301,152,'动物眼影盘 12g 瓦塔吉限定',1,1,1,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(48,7,42,'完美日记氨基酸洗面奶','温和清洁 补水保湿','完美日记','https://picsum.photos/400/400?random=48','[]',59.90,79.90,0,NULL,2,500,200,'氨基酸洗面奶 150ml',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(49,7,42,'完美日记天鹅绒唇釉','哑光丝绒 持久不脱妆','完美日记','https://picsum.photos/400/400?random=49','[]',79.90,99.90,0,NULL,2,450,180,'天鹅绒唇釉 3.5g',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(50,7,41,'完美日记气垫BB霜','遮瑕保湿 打造裸妆','完美日记','https://picsum.photos/400/400?random=50','[]',119.00,159.00,0,NULL,2,349,131,'气垫BB霜 15g*2',1,0,1,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(51,7,42,'完美日记名片香水','淡香持久 约会必备','完美日记','https://picsum.photos/400/400?random=51','[]',89.00,129.00,0,NULL,2,200,80,'名片香水 15ml',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(52,8,33,'李宁篮球鞋 闪击8','实战减震 耐磨防滑','李宁','https://picsum.photos/400/400?random=52','[]',599.00,799.00,0,NULL,2,300,150,'李宁闪击8篮球鞋 专业实战',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(53,8,71,'李宁运动T恤','速干透气 运动舒适','李宁','https://picsum.photos/400/400?random=53','[]',149.00,249.00,0,NULL,2,500,280,'李宁运动T恤 男款',1,1,1,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(54,8,33,'李宁羽毛球拍','碳素超轻 攻防兼备','李宁','https://picsum.photos/400/400?random=54','[]',399.00,599.00,0,NULL,2,200,90,'李宁羽毛球拍 碳纤维',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(55,8,72,'李宁跑鞋 赤兔6','轻量竞速 专业跑步','李宁','https://picsum.photos/400/400?random=55','[]',499.00,699.00,0,NULL,2,400,200,'李宁赤兔6跑鞋',1,1,1,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(56,8,71,'李宁运动裤','速干透气 弹力舒适','李宁','https://picsum.photos/400/400?random=56','[]',199.00,299.00,0,NULL,2,350,160,'李宁运动长裤 男款',1,0,0,0,'2026-07-01 19:54:19','2026-07-02 17:53:54'),(57,8,33,'李宁双肩背包','大容量 多隔层','李宁','https://picsum.photos/400/400?random=57','[]',179.00,279.00,0,NULL,2,250,110,'李宁双肩背包 30L',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(58,8,33,'李宁卫衣','加绒保暖 休闲运动','李宁','https://picsum.photos/400/400?random=58','[]',299.00,449.00,0,NULL,2,300,130,'李宁套头卫衣',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(59,9,33,'Nike Air Jordan 1','经典篮球鞋 时尚百搭','Nike','https://picsum.photos/400/400?random=59','[]',1299.00,1599.00,0,NULL,2,150,80,'Air Jordan 1 MID 黑红',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(60,9,33,'Nike Air Force 1','小白鞋经典 永恒时尚','Nike','https://picsum.photos/400/400?random=60','[]',799.00,899.00,0,NULL,2,299,181,'Air Force 1 07 白色',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(61,9,33,'Nike Pro运动T恤','紧身速干 专业运动','Nike','https://picsum.photos/400/400?random=61','[]',229.00,299.00,0,NULL,2,499,251,'Nike Pro男子紧身T恤',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(62,9,33,'Nike Pegasus 40','缓震跑步鞋 日常训练','Nike','https://picsum.photos/400/400?random=62','[]',899.00,1099.00,0,NULL,2,250,120,'Nike Pegasus 40 男子跑鞋',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(63,9,33,'Nike运动短裤','速干透气 运动自如','Nike','https://picsum.photos/400/400?random=63','[]',199.00,259.00,0,NULL,2,400,200,'Nike男子运动短裤',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(64,9,33,'Nike双肩包','大容量 背负舒适','Nike','https://picsum.photos/400/400?random=64','[]',349.00,449.00,0,NULL,2,200,90,'Nike男子双肩背包',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(65,9,33,'Nike篮球','室内外通用 耐磨耐打','Nike','https://picsum.photos/400/400?random=65','[]',199.00,299.00,0,NULL,2,300,140,'Nike标准7号篮球',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(66,10,71,'三体全集 套装3册','刘慈欣科幻巅峰之作','当当','https://picsum.photos/400/400?random=66','[]',83.00,168.00,0,NULL,2,500,320,'三体全集1-3 正版精装',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(67,10,71,'活着 余华','人生必读经典文学','当当','https://picsum.photos/400/400?random=67','[]',21.00,45.00,0,NULL,2,799,501,'活着 余华代表作',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(68,10,71,'百年孤独','诺贝尔文学奖经典','当当','https://picsum.photos/400/400?random=68','[]',39.50,79.00,0,NULL,2,600,280,'百年孤独 加西亚·马尔克斯',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(69,10,71,'新华字典 第12版','权威工具书 学习必备','当当','https://picsum.photos/400/400?random=69','[]',19.90,32.80,0,NULL,2,997,603,'新华字典 第12版 商务印书馆',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(70,10,71,'晨光中性笔12支装','顺滑书写 考试必备','晨光','https://picsum.photos/400/400?random=70','[]',19.90,29.90,0,NULL,2,1000,450,'晨光中性笔 12支 黑色',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(71,10,71,'得力笔记本A5 5本装','优质纸张 书写流畅','得力','https://picsum.photos/400/400?random=71','[]',29.90,49.90,0,NULL,2,800,380,'得力笔记本 A5 5本装',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(72,10,71,'小王子','儿童文学经典','当当','https://picsum.photos/400/400?random=72','[]',19.90,39.80,0,NULL,2,700,350,'小王子 圣埃克苏佩里',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(73,11,61,'爱他美奶粉 3段 800g','德国原装 宝宝健康','爱他美','https://picsum.photos/400/400?random=73','[]',258.00,328.00,0,NULL,2,400,220,'爱他美经典版 3段 800g',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(74,11,61,'帮宝适纸尿裤 L码','超薄干爽 整夜安睡','帮宝适','https://picsum.photos/400/400?random=74','[]',99.00,149.00,0,NULL,2,600,350,'帮宝适超薄干爽 L码 72片',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(75,11,61,'费雪海马安抚玩偶','声光安抚 哄睡神器','费雪','https://picsum.photos/400/400?random=75','[]',129.00,169.00,0,NULL,2,300,150,'费雪声光安抚小海马',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(76,11,61,'惠氏启赋奶粉 2段','亲和人体 宝宝易吸收','惠氏','https://picsum.photos/400/400?random=76','[]',388.00,488.00,0,NULL,2,300,140,'惠氏启赋蓝钻 2段 900g',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(77,11,61,'婴儿湿巾 80抽x5包','手口可用 柔软亲肤','好奇','https://picsum.photos/400/400?random=77','[]',49.90,79.90,0,NULL,2,500,280,'婴儿手口湿巾 80抽*5包',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(78,11,61,'好孩子婴儿推车','轻便折叠 一键收车','好孩子','https://picsum.photos/400/400?random=78','[]',899.00,1299.00,0,NULL,2,150,60,'好孩子婴儿推车 轻便型',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(79,11,61,'飞鹤奶粉 1段 900g','新鲜生牛乳 宝宝辅食','飞鹤','https://picsum.photos/400/400?random=79','[]',308.00,398.00,0,NULL,2,350,160,'飞鹤星飞帆 1段 900g',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(80,12,51,'良品铺子每日坚果 750g','8种坚果 科学配比','良品铺子','https://picsum.photos/400/400?random=80','[]',89.90,129.00,0,NULL,2,500,280,'每日坚果 30包 750g',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(81,12,51,'良品铺子猪肉脯 200g','自然片 越嚼越香','良品铺子','https://picsum.photos/400/400?random=81','[]',39.90,59.90,0,NULL,2,600,320,'猪肉脯 自然片 200g',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(82,12,51,'良品铺子芒果干 108g','厚切大片 酸甜可口','良品铺子','https://picsum.photos/400/400?random=82','[]',25.90,39.90,0,NULL,2,799,451,'芒果干 108g',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(83,12,51,'良品铺子鸭脖 190g','卤味零食 麻辣鲜香','良品铺子','https://picsum.photos/400/400?random=83','[]',32.90,49.90,0,NULL,2,500,250,'鸭脖 190g 麻辣味',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(84,12,51,'良品铺子手撕面包 1kg','早餐糕点 营养美味','良品铺子','https://picsum.photos/400/400?random=84','[]',29.90,49.90,0,NULL,2,700,380,'手撕面包 1kg',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(85,12,51,'良品铺子夏威夷果 238g','奶油味 开口易剥','良品铺子','https://picsum.photos/400/400?random=85','[]',45.90,65.90,0,NULL,2,400,180,'夏威夷果 238g 奶油味',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(86,12,51,'良品铺子牛板筋 150g','烧烤味 嚼劲十足','良品铺子','https://picsum.photos/400/400?random=86','[]',35.90,55.90,0,NULL,2,450,200,'牛板筋 150g 烧烤味',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(87,13,61,'宜家拉克边桌','白色简约 多场景适用','宜家','https://picsum.photos/400/400?random=87','[]',79.00,129.00,0,NULL,2,400,220,'拉克边桌 白色 55x55cm',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(88,13,61,'宜家波昂扶手椅','桦木贴面 舒适体验','宜家','https://picsum.photos/400/400?random=88','[]',499.00,699.00,0,NULL,2,150,60,'波昂扶手椅 桦木贴面',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(89,13,61,'宜家被套枕套套装','纯棉舒适 亲肤透气','宜家','https://picsum.photos/400/400?random=89','[]',149.00,249.00,0,NULL,2,300,150,'被套枕套套装 双人',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(90,13,61,'宜家卡瓦科砧板','竹制环保 耐用易清洗','宜家','https://picsum.photos/400/400?random=90','[]',29.90,49.90,0,NULL,2,500,280,'卡瓦科砧板 竹制 2件套',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(91,13,61,'宜家特提亚工作灯','可调节臂 高品质照明','宜家','https://picsum.photos/400/400?random=91','[]',99.00,149.00,0,NULL,2,250,120,'特提亚工作灯 银色',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(92,13,61,'宜家考肯密封罐','玻璃材质 密封保鲜','宜家','https://picsum.photos/400/400?random=92','[]',39.90,59.90,0,NULL,2,600,320,'考肯密封罐 玻璃 3件套',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(93,13,61,'宜家记忆棉枕头','人体工学 舒适支撑','宜家','https://picsum.photos/400/400?random=93','[]',129.00,199.00,0,NULL,2,350,160,'记忆棉枕头',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(94,14,33,'安踏KT8篮球鞋','汤普森签名 专业实战','安踏','https://picsum.photos/400/400?random=94','[]',599.00,799.00,0,NULL,2,250,120,'安踏KT8 汤普森战靴',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(95,14,33,'安踏氢跑4 跑步鞋','轻量透气 缓震舒适','安踏','https://picsum.photos/400/400?random=95','[]',349.00,499.00,0,NULL,2,400,200,'安踏氢跑4跑鞋',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(96,14,33,'安踏运动T恤','速干透气 运动舒适','安踏','https://picsum.photos/400/400?random=96','[]',129.00,199.00,0,NULL,2,499,281,'安踏速干T恤 男款',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(97,14,33,'安踏运动套装','短袖短裤 运动必备','安踏','https://picsum.photos/400/400?random=97','[]',299.00,449.00,0,NULL,2,300,140,'安踏运动套装 男款',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(98,14,33,'安踏足球鞋','碎钉设计 人工草地适用','安踏','https://picsum.photos/400/400?random=98','[]',299.00,429.00,0,NULL,2,200,80,'安踏足球鞋 AG碎钉',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(99,14,33,'安踏双肩背包','大容量 多隔层设计','安踏','https://picsum.photos/400/400?random=99','[]',159.00,249.00,0,NULL,2,300,150,'安踏双肩背包',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(100,14,33,'安踏运动长裤','束脚卫裤 时尚运动','安踏','https://picsum.photos/400/400?random=100','[]',199.00,299.00,0,NULL,2,350,160,'安踏运动长裤 男款',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(101,15,42,'兰蔻小黑瓶精华 50ml','精华肌底 肌肤焕亮','兰蔻','https://picsum.photos/400/400?random=101','[]',1080.00,1280.00,0,NULL,2,200,120,'兰蔻小黑瓶 50ml',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(102,15,42,'兰蔻粉水 400ml','清滢柔肤 补水保湿','兰蔻','https://picsum.photos/400/400?random=102','[]',480.00,580.00,0,NULL,2,300,180,'兰蔻粉水 400ml',1,1,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(103,15,42,'兰蔻196口红','朱砂橘色 高级显白','兰蔻','https://picsum.photos/400/400?random=103','[]',320.00,380.00,0,NULL,2,400,250,'兰蔻菁纯口红 196',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(104,15,42,'兰蔻菁纯眼霜 20ml','抗皱紧致 眼周焕亮','兰蔻','https://picsum.photos/400/400?random=104','[]',1180.00,1380.00,0,NULL,2,150,70,'兰蔻菁纯眼霜 20ml',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(105,15,42,'兰蔻极光水 150ml','净澈焕肤 细腻透亮','兰蔻','https://picsum.photos/400/400?random=105','[]',830.00,980.00,0,NULL,2,200,90,'兰蔻极光水 150ml',1,0,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(106,15,42,'兰蔻奇迹香水 30ml','女士淡香 优雅迷人','兰蔻','https://picsum.photos/400/400?random=106','[]',580.00,680.00,0,NULL,2,250,110,'兰蔻奇迹香水 30ml',1,1,0,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(107,15,42,'兰蔻小白管防晒 50ml','轻透不油腻 防晒黑','兰蔻','https://picsum.photos/400/400?random=107','[]',480.00,560.00,0,NULL,2,300,140,'兰蔻小白管防晒 50ml',1,0,1,0,'2026-07-01 19:54:19','2026-07-01 19:54:19'),(108,1,11,'iPhone 18',NULL,'apple','https://picsum.photos/400/400?random=108','',9700.00,10000.00,0,NULL,2,104,5,'',1,0,0,0,'2026-07-02 18:14:54','2026-07-03 20:39:06');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_sku`
--

DROP TABLE IF EXISTS `product_sku`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_sku` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'SKU ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `merchant_id` bigint DEFAULT NULL COMMENT '商家ID',
  `sku_code` varchar(100) DEFAULT NULL COMMENT 'SKU编码',
  `spec_values` varchar(500) DEFAULT NULL COMMENT '规格值',
  `price` decimal(10,2) NOT NULL COMMENT 'SKU价格',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `stock` int NOT NULL DEFAULT '0' COMMENT '库存',
  `locked_stock` int DEFAULT '0' COMMENT '锁定库存',
  `sales_count` int DEFAULT '0' COMMENT '销量',
  `weight` decimal(10,2) DEFAULT '0.00' COMMENT '重量(kg)',
  `image` varchar(255) DEFAULT NULL COMMENT 'SKU图片',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1正常',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_merchant_id` (`merchant_id`),
  KEY `idx_sku_code` (`sku_code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品SKU表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_sku`
--

LOCK TABLES `product_sku` WRITE;
/*!40000 ALTER TABLE `product_sku` DISABLE KEYS */;
INSERT INTO `product_sku` VALUES (1,1,1,'IPHONE256','256GB',9999.00,10999.00,27,0,0,0.00,NULL,1,'2026-07-01 20:40:08','2026-07-03 20:04:00'),(2,1,1,'IPHONE512','512GB',10999.00,12999.00,30,0,0,0.00,NULL,1,'2026-07-01 20:41:51','2026-07-01 20:41:51'),(3,108,1,'01','红色256',8000.00,10000.00,36,0,0,0.00,NULL,1,'2026-07-02 18:16:18','2026-07-02 18:16:18'),(4,108,1,'02','红色512',12000.00,10000.00,33,0,0,0.00,NULL,1,'2026-07-02 18:16:43','2026-07-02 18:16:43'),(5,108,1,'03','红色1t',9700.00,10000.00,35,0,0,0.00,NULL,1,'2026-07-03 16:45:37','2026-07-03 19:07:47');
/*!40000 ALTER TABLE `product_sku` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refund`
--

DROP TABLE IF EXISTS `refund`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refund` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '退款ID',
  `refund_no` varchar(50) NOT NULL COMMENT '退款单号',
  `order_id` bigint NOT NULL COMMENT '订单ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `refund_amount` decimal(10,2) NOT NULL COMMENT '退款金额',
  `refund_reason` varchar(500) DEFAULT NULL COMMENT '退款原因',
  `voucher_images` varchar(1000) DEFAULT NULL COMMENT '凭证图片，逗号分隔',
  `refund_type` tinyint NOT NULL COMMENT '类型：1仅退款 2退货退款',
  `original_order_status` tinyint DEFAULT NULL COMMENT '申请退款时的原订单状态，用于拒绝时恢复',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态：0待审核 1待退货 2已拒绝 3已完成 4已取消 5退货中',
  `merchant_remark` varchar(500) DEFAULT NULL COMMENT '商家备注/拒绝原因',
  `admin_remark` varchar(500) DEFAULT NULL COMMENT '平台备注',
  `return_logistics_company` varchar(100) DEFAULT NULL COMMENT '退货物流公司',
  `return_tracking_no` varchar(100) DEFAULT NULL COMMENT '退货物流单号',
  `return_ship_time` datetime DEFAULT NULL COMMENT '退货发货时间',
  `return_receive_time` datetime DEFAULT NULL COMMENT '商家确认收货时间',
  `apply_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `refund_time` datetime DEFAULT NULL COMMENT '退款完成时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `refund_no` (`refund_no`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='退款记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refund`
--

LOCK TABLES `refund` WRITE;
/*!40000 ALTER TABLE `refund` DISABLE KEYS */;
INSERT INTO `refund` VALUES (1,'R202607012109105007',6,3,9499.00,'其他',NULL,1,NULL,2,'hh',NULL,NULL,NULL,NULL,NULL,'2026-07-01 21:09:10','2026-07-01 21:09:51',NULL),(2,'R202607012140501172',6,3,9499.00,'其他',NULL,1,NULL,3,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-01 21:40:50','2026-07-01 21:41:23','2026-07-01 21:41:23'),(3,'R202607012141468418',5,3,9999.00,'其他',NULL,1,NULL,2,'q\'q',NULL,NULL,NULL,NULL,NULL,'2026-07-01 21:41:47','2026-07-01 21:42:04',NULL),(4,'R202607012200380406',5,3,9999.00,'其他',NULL,1,1,3,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-01 22:00:38','2026-07-01 22:00:51','2026-07-01 22:00:51'),(5,'R202607012201496845',2,3,1299.00,'其他',NULL,1,1,3,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-01 22:01:50','2026-07-01 22:03:03','2026-07-01 22:03:03'),(6,'R202607012202182620',1,3,5999.00,'其他',NULL,1,1,3,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-01 22:02:18','2026-07-01 22:03:01','2026-07-01 22:03:01'),(7,'R202607012233137526',7,3,8999.00,'买错/不想要了',NULL,1,1,3,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-01 22:33:14','2026-07-01 22:33:27','2026-07-01 22:33:27'),(8,'R202607022332401473',18,3,8999.00,'买错/不想要了',NULL,1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-02 23:32:41',NULL,NULL),(9,'R202607022332449936',17,3,9999.00,'买错/不想要了',NULL,1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-02 23:32:44',NULL,NULL),(10,'R202607022332472512',16,3,9999.00,'买错/不想要了',NULL,1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-02 23:32:47',NULL,NULL),(11,'R202607022332564853',14,3,229.00,'买错/不想要了',NULL,1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-02 23:32:56',NULL,NULL),(12,'R202607022333008081',13,3,739.00,'买错/不想要了',NULL,1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-02 23:33:00',NULL,NULL),(13,'R202607030132305106',24,3,29.90,'其他',NULL,1,1,0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 01:32:30',NULL,NULL),(14,'R202607032006192211',4,2,9999.00,'1',NULL,1,1,3,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-03 20:06:20','2026-07-03 20:06:49','2026-07-03 20:06:49');
/*!40000 ALTER TABLE `refund` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `name` varchar(50) NOT NULL COMMENT '角色名',
  `code` varchar(50) NOT NULL COMMENT '角色编码',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用 1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'超级管理员','SUPER_ADMIN','拥有系统全部权限',1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(2,'运营','OPERATOR','负责日常运营管理',1,'2026-07-01 19:53:49','2026-07-01 19:53:49'),(3,'客服','CS','处理订单售后',1,'2026-07-01 19:53:49','2026-07-01 19:53:49');
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `permission_id` bigint NOT NULL COMMENT '权限ID',
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `idx_permission_id` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色-权限关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seckill_activity`
--

DROP TABLE IF EXISTS `seckill_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seckill_activity` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `merchant_id` bigint DEFAULT '0',
  `product_id` bigint DEFAULT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `seckill_price` decimal(10,2) DEFAULT NULL COMMENT '秒杀价',
  `original_price` decimal(10,2) DEFAULT NULL COMMENT '原价',
  `total_stock` int DEFAULT NULL COMMENT '总库存',
  `available_stock` int DEFAULT NULL COMMENT '剩余库存',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `description` varchar(500) DEFAULT NULL,
  `banner` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_time` (`start_time`,`end_time`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_merchant_id` (`merchant_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seckill_activity`
--

LOCK TABLES `seckill_activity` WRITE;
/*!40000 ALTER TABLE `seckill_activity` DISABLE KEYS */;
INSERT INTO `seckill_activity` VALUES (1,'夏季大促',0,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-01 16:00:00','2026-07-15 16:00:00',0,NULL,NULL,'2026-07-02 18:56:51','2026-07-03 15:44:48'),(2,'iPhone 18 秒杀活动',1,108,NULL,8000.00,10000.00,2,2,'2026-07-02 16:00:00','2026-07-04 16:06:00',1,'',NULL,'2026-07-02 22:08:40','2026-07-03 16:02:31'),(3,'MacBook Pro 14英寸 秒杀活动',1,2,NULL,10000.00,14999.00,2,2,'2026-07-03 00:00:00','2026-07-04 16:00:00',1,'',NULL,'2026-07-03 15:43:31','2026-07-03 16:01:57'),(4,'Mac mini M2 秒杀活动',1,6,NULL,4000.00,4499.00,1,1,'2026-07-03 00:00:00','2026-07-04 16:05:00',1,'',NULL,'2026-07-03 16:03:31','2026-07-03 16:22:18'),(6,'iPad Pro 12.9英寸 秒杀活动',1,3,NULL,7439.00,9299.00,1,1,'2026-07-03 00:00:00','2026-07-05 00:00:00',1,'',NULL,'2026-07-03 16:11:33','2026-07-03 20:16:36'),(7,'iPhone 15 Pro Max 秒杀活动',1,1,NULL,7999.00,10999.00,1,1,'2026-07-03 00:00:00','2026-07-05 00:00:00',1,'',NULL,'2026-07-03 16:22:42','2026-07-03 20:17:26'),(8,'AirPods Max 秒杀活动',1,8,NULL,3199.00,4399.00,1,1,'2026-07-03 00:00:00','2026-07-06 00:00:00',1,'',NULL,'2026-07-03 20:43:41','2026-07-03 20:43:41');
/*!40000 ALTER TABLE `seckill_activity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seckill_order`
--

DROP TABLE IF EXISTS `seckill_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seckill_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `seckill_id` bigint NOT NULL COMMENT '秒杀参与ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `order_id` bigint DEFAULT NULL COMMENT '订单ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `quantity` int NOT NULL DEFAULT '1' COMMENT '数量',
  `seckill_price` decimal(10,2) NOT NULL COMMENT '秒杀价',
  `status` tinyint DEFAULT '0' COMMENT '状态：0待支付 1已支付 2已取消',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_seckill_id` (`seckill_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='秒杀订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seckill_order`
--

LOCK TABLES `seckill_order` WRITE;
/*!40000 ALTER TABLE `seckill_order` DISABLE KEYS */;
/*!40000 ALTER TABLE `seckill_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_log`
--

DROP TABLE IF EXISTS `stock_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `product_id` bigint NOT NULL COMMENT '商品ID',
  `sku_id` bigint DEFAULT NULL COMMENT 'SKU ID',
  `type` tinyint NOT NULL COMMENT '类型：1入库 2出库 3扣减 4恢复',
  `quantity` int NOT NULL COMMENT '变动数量',
  `before_stock` int DEFAULT NULL COMMENT '变动前库存',
  `after_stock` int DEFAULT NULL COMMENT '变动后库存',
  `order_no` varchar(50) DEFAULT NULL COMMENT '关联订单号',
  `operator` varchar(100) DEFAULT NULL COMMENT '操作人',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_type` (`type`),
  KEY `idx_order_no` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='库存变动日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_log`
--

LOCK TABLES `stock_log` WRITE;
/*!40000 ALTER TABLE `stock_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `status` tinyint DEFAULT '1' COMMENT '状态：0禁用，1启用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'user01','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de','user01@example.com','13800000001','用户小王',NULL,1,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(2,'user02','$2a$10$y8ORy02ONq8Ddah/lB8Uh./ojwebVUD2v9tNZuYFZOflwwusX66de','user02@example.com','13800000002','用户小李',NULL,1,'2026-07-01 19:58:14','2026-07-01 19:58:14'),(3,'test001','$2a$10$YR6zumwJCO4Stztez0uaeerh6mppa4SlOuXLHGQUM0DAUI9wJq9ZO','test001@example.com','13800880033','一一',NULL,1,'2026-07-01 19:58:14','2026-07-03 01:15:05'),(4,'test004','$2a$10$OvakaNwx6bUAkB1aTDG/kuKb357Gys41M0eMjwTqUi6DvCLexyHFm',NULL,NULL,'test004',NULL,1,'2026-07-02 18:35:03','2026-07-02 18:35:03');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_coupon`
--

DROP TABLE IF EXISTS `user_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_coupon` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `template_id` bigint NOT NULL COMMENT '模板ID',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT '优惠券码',
  `name` varchar(100) NOT NULL COMMENT '优惠券名称（快照）',
  `type` tinyint NOT NULL COMMENT '类型',
  `discount_amount` decimal(10,2) DEFAULT NULL COMMENT '优惠金额',
  `min_amount` decimal(10,2) DEFAULT '0.00' COMMENT '最低使用金额',
  `status` tinyint DEFAULT '0' COMMENT '状态：0未使用 1已使用 2已过期',
  `receive_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
  `use_time` datetime DEFAULT NULL COMMENT '使用时间',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间',
  `order_no` varchar(50) DEFAULT NULL COMMENT '使用订单号',
  `lock_order_no` varchar(50) DEFAULT NULL COMMENT '锁定订单号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_template_id` (`template_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户优惠券表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_coupon`
--

LOCK TABLES `user_coupon` WRITE;
/*!40000 ALTER TABLE `user_coupon` DISABLE KEYS */;
INSERT INTO `user_coupon` VALUES (1,3,1,'C1782907422561841','Apple满500减50',1,50.00,500.00,0,'2026-07-01 20:03:43',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-01 20:03:42'),(2,3,2,'C1782909791261639','Apple满3000减300',1,300.00,3000.00,0,'2026-07-01 20:43:11',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-01 20:43:11'),(3,3,3,'C1782909791308409','iPhone专属500券',1,500.00,5000.00,0,'2026-07-01 20:43:11','2026-07-01 21:03:21','2026-07-31 19:54:36','O202607012103182467','O202607012103182467','2026-07-01 20:43:11'),(4,3,9,'C1782909791312591','Mate系列专属券',1,200.00,4000.00,0,'2026-07-01 20:43:11',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-01 20:43:11'),(5,3,12,'C1782909791317749','小米14系列专属300券',1,300.00,5000.00,0,'2026-07-01 20:43:11',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-01 20:43:11'),(6,3,17,'C1782916366291570','完美日记满99减15',1,15.00,99.00,1,'2026-07-01 22:32:46','2026-07-01 22:32:59','2026-07-31 19:54:36','O202607012232585908','O202607012232585908','2026-07-01 22:32:46'),(7,3,18,'C1782916366303383','完美日记满199减40',1,40.00,199.00,0,'2026-07-01 22:32:46',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-01 22:32:46'),(8,3,17,'C1782918556823505','完美日记满99减15',1,15.00,99.00,0,'2026-07-01 23:09:17',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-01 23:09:16'),(9,3,4,'C1782977824093913','优衣库满199减20',1,20.00,199.00,0,'2026-07-02 15:37:04',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 15:37:04'),(10,3,5,'C1782977827403298','优衣库满399减50',1,50.00,399.00,0,'2026-07-02 15:37:07',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 15:37:07'),(11,4,1,'C1782980195611265','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(12,1,1,'C1782980195612362','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(13,10,1,'C1782980195628492','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(14,2,1,'C1782980195628307','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(15,6,1,'C1782980195628660','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(16,7,1,'C1782980195636696','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(17,11,1,'C1782980195636939','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(18,13,1,'C1782980195638206','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(19,5,1,'C178298019563895','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(20,12,1,'C1782980195638533','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(21,9,1,'C1782980195638479','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(22,14,1,'C1782980195638857','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(23,8,1,'C1782980195639330','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(24,15,1,'C178298019563943','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(25,19,1,'C1782980195639612','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(26,17,1,'C1782980195639818','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(27,16,1,'C1782980195641786','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(28,18,1,'C1782980195641684','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(29,20,1,'C1782980195644747','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(30,21,1,'C1782980195644466','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(31,22,1,'C178298019564882','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(32,23,1,'C1782980195649555','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(33,24,1,'C1782980195650586','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(34,26,1,'C1782980195652286','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(35,25,1,'C1782980195654197','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(36,27,1,'C1782980195654724','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(37,29,1,'C1782980195656694','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(38,31,1,'C1782980195659773','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(39,30,1,'C1782980195660277','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(40,32,1,'C1782980195660724','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(41,33,1,'C1782980195662478','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(42,34,1,'C1782980195664924','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(43,35,1,'C1782980195666406','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(44,37,1,'C1782980195666733','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(45,36,1,'C1782980195668443','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(46,40,1,'C1782980195670565','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(47,38,1,'C1782980195674297','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(48,39,1,'C1782980195674491','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(49,41,1,'C1782980195674367','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(50,42,1,'C1782980195674230','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(51,44,1,'C1782980195674947','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(52,45,1,'C1782980195679440','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(53,43,1,'C1782980195679311','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(54,46,1,'C1782980195679336','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(55,47,1,'C1782980195684634','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(56,48,1,'C1782980195684694','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(57,49,1,'C178298019568432','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(58,50,1,'C1782980195689199','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(59,28,1,'C1782980195695885','Apple满500减50',1,50.00,500.00,0,'2026-07-02 16:16:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 16:16:35'),(60,3,36,'C1782994275614101','满100减去10',1,10.00,100.00,1,'2026-07-02 20:11:16','2026-07-02 20:11:50','2026-08-04 16:00:00','O202607022011477423','O202607022011477423','2026-07-02 20:11:15'),(61,3,21,'C1782994294852352','Nike满500减50',1,50.00,500.00,1,'2026-07-02 20:11:35','2026-07-02 20:11:50','2026-07-31 19:54:36','O202607022011477423','O202607022011477423','2026-07-02 20:11:34'),(62,3,22,'C1782994294858966','Nike满1000减120',1,120.00,1000.00,0,'2026-07-02 20:11:35',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-02 20:11:34'),(63,1,36,'C1783068186431773','满100减去10',1,10.00,100.00,1,'2026-07-03 16:43:06','2026-07-03 16:43:22','2026-08-04 16:00:00','O202607031643196512','O202607031643196512','2026-07-03 16:43:06'),(64,1,2,'C1783068186507783','Apple满3000减300',1,300.00,3000.00,1,'2026-07-03 16:43:07','2026-07-03 16:43:22','2026-07-31 19:54:36','O202607031643196512','O202607031643196512','2026-07-03 16:43:06'),(65,1,3,'C1783068186517339','iPhone专属500券',1,500.00,5000.00,0,'2026-07-03 16:43:07',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-03 16:43:06'),(66,1,9,'C1783068186521142','Mate系列专属券',1,200.00,4000.00,0,'2026-07-03 16:43:07',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-03 16:43:06'),(67,1,12,'C1783068186523990','小米14系列专属300券',1,300.00,5000.00,0,'2026-07-03 16:43:07',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-03 16:43:06'),(68,1,23,'C1783072536204641','当当满99减10',1,10.00,99.00,0,'2026-07-03 17:55:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-03 17:55:36'),(69,1,24,'C1783072536233288','当当满199减30',1,30.00,199.00,0,'2026-07-03 17:55:36',NULL,'2026-07-31 19:54:36',NULL,NULL,'2026-07-03 17:55:36');
/*!40000 ALTER TABLE `user_coupon` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-03 20:57:46
