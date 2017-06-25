/*
Navicat MySQL Data Transfer

Source Server         : Mysql_local
Source Server Version : 50621
Source Host           : localhost:3306
Source Database       : world

Target Server Type    : MYSQL
Target Server Version : 50621
File Encoding         : 65001

Date: 2017-06-13 01:42:36
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for wp_cbpc_wxwall_luckyuser
-- ----------------------------
DROP TABLE IF EXISTS `wp_cbpc_wxwall_luckyuser`;
CREATE TABLE `wp_cbpc_wxwall_luckyuser` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `address_detail` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `openid` varchar(255) DEFAULT NULL,
  `rec_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
