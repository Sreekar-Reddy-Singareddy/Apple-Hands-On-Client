CREATE DATABASE  IF NOT EXISTS `sreekar_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */;
USE `sreekar_db`;
-- MySQL dump 10.13  Distrib 8.0.13, for macos10.14 (x86_64)
--
-- Host: 127.0.0.1    Database: sreekar_db
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `exam_data`
--

DROP TABLE IF EXISTS `exam_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `exam_data` (
  `exam_code` int(10) NOT NULL,
  `exam_date` datetime NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `question` int(10) NOT NULL,
  `instructions` int(10) NOT NULL,
  `supplied` int(10) NOT NULL,
  PRIMARY KEY (`exam_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_data`
--

LOCK TABLES `exam_data` WRITE;
/*!40000 ALTER TABLE `exam_data` DISABLE KEYS */;
INSERT INTO `exam_data` VALUES (1111,'2018-01-01 12:00:00','00:00:00','12:30:00',2,1,3);
/*!40000 ALTER TABLE `exam_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_status`
--

DROP TABLE IF EXISTS `exam_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `exam_status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `emp_id` int(10) NOT NULL,
  `started_at` time NOT NULL,
  `ends_at` time NOT NULL,
  `exam_date` datetime NOT NULL,
  `exam_code` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `exam_code_idx` (`exam_code`),
  KEY `emp_id_idx` (`emp_id`),
  CONSTRAINT `emp_id` FOREIGN KEY (`emp_id`) REFERENCES `trainees_data` (`emp_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `exam_code` FOREIGN KEY (`exam_code`) REFERENCES `exam_data` (`exam_code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_status`
--

LOCK TABLES `exam_status` WRITE;
/*!40000 ALTER TABLE `exam_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_data`
--

DROP TABLE IF EXISTS `file_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `file_data` (
  `file_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `type` varchar(10) NOT NULL,
  `description` varchar(150) DEFAULT 'NA',
  PRIMARY KEY (`file_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_data`
--

LOCK TABLES `file_data` WRITE;
/*!40000 ALTER TABLE `file_data` DISABLE KEYS */;
INSERT INTO `file_data` VALUES (1,'sr_ins.pdf','INS','This is the file!'),(2,'5 LB.pdf','QPR','This is the file!'),(3,'sr_supplies.zip','SUP','This is the file!'),(4,'no_file','NA','NA');
/*!40000 ALTER TABLE `file_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trainees_data`
--

DROP TABLE IF EXISTS `trainees_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `trainees_data` (
  `emp_id` int(10) NOT NULL,
  `ip_add` varchar(15) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email_id` varchar(120) NOT NULL,
  `batch_code` varchar(100) NOT NULL,
  PRIMARY KEY (`emp_id`),
  UNIQUE KEY `ip_add_UNIQUE` (`ip_add`),
  UNIQUE KEY `email_id_UNIQUE` (`email_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trainees_data`
--

LOCK TABLES `trainees_data` WRITE;
/*!40000 ALTER TABLE `trainees_data` DISABLE KEYS */;
INSERT INTO `trainees_data` VALUES (762208,'','sai sreekar reddy','sreekar.singareddy@infosys.com','');
/*!40000 ALTER TABLE `trainees_data` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-01-09 18:46:05
