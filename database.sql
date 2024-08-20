CREATE DATABASE  IF NOT EXISTS `pussalla_it` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `pussalla_it`;
-- MySQL dump 10.13  Distrib 8.0.34, for Win64 (x86_64)
--
-- Host: 220.247.246.76    Database: pussalla_it
-- ------------------------------------------------------
-- Server version	8.0.34

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
-- Table structure for table `tbl_addonitem`
--

DROP TABLE IF EXISTS `tbl_addonitem`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_addonitem` (
  `idtbl_assetinitiateupgrade` int NOT NULL AUTO_INCREMENT,
  `IdString` varchar(45) DEFAULT NULL,
  `TktNo` varchar(45) DEFAULT NULL,
  `SN` varchar(45) DEFAULT NULL,
  `upgradeNote` varchar(500) DEFAULT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `upgradeCost` double DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  `IsActive` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`idtbl_assetinitiateupgrade`),
  KEY `add_user_idx_idx` (`EnterBy`),
  KEY `add_asst_idx_idx` (`IdString`),
  CONSTRAINT `add_asst_idx` FOREIGN KEY (`IdString`) REFERENCES `tbl_inventory` (`InvIdString`),
  CONSTRAINT `add_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_admingroup`
--

DROP TABLE IF EXISTS `tbl_admingroup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_admingroup` (
  `admingroup` varchar(20) NOT NULL,
  `superviser` varchar(45) DEFAULT NULL,
  `notification_to` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`admingroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_appversion`
--

DROP TABLE IF EXISTS `tbl_appversion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_appversion` (
  `idtbl_appversion` int NOT NULL AUTO_INCREMENT,
  `appVerison` varchar(45) DEFAULT NULL,
  `rlcDate` datetime DEFAULT NULL,
  `rlcNote` varchar(250) DEFAULT NULL,
  `rlcNoteHader` varchar(50) DEFAULT NULL,
  `rlcURL` varchar(5000) DEFAULT NULL,
  `publishBy` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`idtbl_appversion`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_assettype`
--

DROP TABLE IF EXISTS `tbl_assettype`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_assettype` (
  `TypeOf` varchar(45) NOT NULL,
  `IsActive` varchar(45) DEFAULT NULL,
  `AdminGroup` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`TypeOf`),
  KEY `admin_group_Idx_idx` (`AdminGroup`),
  CONSTRAINT `admin_group_Idx` FOREIGN KEY (`AdminGroup`) REFERENCES `tbl_admingroup` (`admingroup`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_dpt`
--

DROP TABLE IF EXISTS `tbl_dpt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_dpt` (
  `dpt` varchar(45) NOT NULL,
  `AdminGroup` varchar(20) NOT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  PRIMARY KEY (`dpt`),
  KEY `admin_group_Idx_idx` (`AdminGroup`),
  KEY `dpt_user_idx_idx` (`EnterBy`),
  CONSTRAINT `dpt_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_inventory`
--

DROP TABLE IF EXISTS `tbl_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_inventory` (
  `ID` int NOT NULL,
  `InvIdString` varchar(45) NOT NULL,
  `SerialNumber` varchar(45) DEFAULT NULL,
  `Location` varchar(45) DEFAULT NULL,
  `Dpt` varchar(45) DEFAULT NULL,
  `AdminGroup` varchar(20) DEFAULT NULL,
  `Descriptions` varchar(500) DEFAULT NULL,
  `Typeof` varchar(45) DEFAULT NULL,
  `StatusOf` varchar(45) DEFAULT NULL,
  `Remarks` varchar(500) DEFAULT NULL,
  `RecMobile` varchar(10) DEFAULT NULL,
  `UserName` varchar(45) DEFAULT NULL,
  `SignatureImage` mediumblob,
  `SignatureRef` varchar(45) DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  PRIMARY KEY (`InvIdString`),
  KEY `inv_dpt_idx_idx` (`Dpt`),
  KEY `inv_user_idx_idx` (`EnterBy`),
  KEY `inv_admingrp_idx_idx` (`AdminGroup`),
  KEY `Inv_typof_idx_idx` (`Typeof`),
  CONSTRAINT `inv_admingrp_idx` FOREIGN KEY (`AdminGroup`) REFERENCES `tbl_admingroup` (`admingroup`),
  CONSTRAINT `inv_dpt_idx` FOREIGN KEY (`Dpt`) REFERENCES `tbl_dpt` (`dpt`),
  CONSTRAINT `Inv_typof_idx` FOREIGN KEY (`Typeof`) REFERENCES `tbl_assettype` (`TypeOf`),
  CONSTRAINT `inv_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_inventoryold`
--

DROP TABLE IF EXISTS `tbl_inventoryold`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_inventoryold` (
  `tbl_inventoryoldcol` int NOT NULL AUTO_INCREMENT,
  `InvIdString` varchar(45) DEFAULT NULL,
  `SerialNumber` varchar(45) DEFAULT NULL,
  `Location` varchar(45) DEFAULT NULL,
  `Dpt` varchar(45) DEFAULT NULL,
  `AdminGroup` varchar(20) DEFAULT NULL,
  `Descriptions` varchar(500) DEFAULT NULL,
  `Typeof` varchar(45) DEFAULT NULL,
  `StatusOf` varchar(45) DEFAULT NULL,
  `Remarks` varchar(500) DEFAULT NULL,
  `RecMobile` varchar(10) DEFAULT NULL,
  `UserName` varchar(45) DEFAULT NULL,
  `SignatureImage` mediumblob,
  `SignatureRef` varchar(45) DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  PRIMARY KEY (`tbl_inventoryoldcol`),
  KEY `invo_asst_Idx_idx` (`InvIdString`),
  KEY `invo_usr_idx_idx` (`EnterBy`),
  KEY `inv_admngrp_idx_idx` (`AdminGroup`),
  KEY `invo_dpt_idx_idx` (`Dpt`),
  KEY `invo_typof_idx_idx` (`Typeof`),
  CONSTRAINT `invo_admngrp_idx` FOREIGN KEY (`AdminGroup`) REFERENCES `tbl_admingroup` (`admingroup`),
  CONSTRAINT `invo_asst_Idx` FOREIGN KEY (`InvIdString`) REFERENCES `tbl_inventory` (`InvIdString`),
  CONSTRAINT `invo_dpt_idx` FOREIGN KEY (`Dpt`) REFERENCES `tbl_dpt` (`dpt`),
  CONSTRAINT `invo_typof_idx` FOREIGN KEY (`Typeof`) REFERENCES `tbl_assettype` (`TypeOf`),
  CONSTRAINT `invo_usr_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_itemcategory`
--

DROP TABLE IF EXISTS `tbl_itemcategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_itemcategory` (
  `StockID` varchar(45) NOT NULL,
  `Location` varchar(45) DEFAULT NULL,
  `Category` varchar(45) DEFAULT NULL,
  `Name` varchar(45) DEFAULT NULL,
  `QTY` double DEFAULT NULL,
  `UOM` varchar(45) DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  PRIMARY KEY (`StockID`),
  KEY `itc_user_idx_idx` (`EnterBy`),
  CONSTRAINT `itc_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_itemiissuerecord`
--

DROP TABLE IF EXISTS `tbl_itemiissuerecord`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_itemiissuerecord` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `StockID` varchar(45) DEFAULT NULL,
  `Dpt` varchar(45) DEFAULT NULL,
  `Location` varchar(45) DEFAULT NULL,
  `Remarks` varchar(100) DEFAULT NULL,
  `Types` varchar(45) DEFAULT NULL,
  `QTY` double DEFAULT NULL,
  `StockInHand` double DEFAULT NULL,
  `UOM` varchar(5) DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `isr_stockid_Idx_idx` (`StockID`),
  KEY `isr_dpt_idx_idx` (`Dpt`),
  KEY `isr_user_idx_idx` (`EnterBy`),
  CONSTRAINT `isr_dpt_idx` FOREIGN KEY (`Dpt`) REFERENCES `tbl_dpt` (`dpt`),
  CONSTRAINT `isr_stockid_Idx` FOREIGN KEY (`StockID`) REFERENCES `tbl_itemcategory` (`StockID`),
  CONSTRAINT `isr_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=605 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_itemloclist`
--

DROP TABLE IF EXISTS `tbl_itemloclist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_itemloclist` (
  `locationID` varchar(45) NOT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  PRIMARY KEY (`locationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_locations`
--

DROP TABLE IF EXISTS `tbl_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_locations` (
  `locationId` int NOT NULL AUTO_INCREMENT,
  `Location` varchar(45) DEFAULT NULL,
  `Dpt` varchar(45) DEFAULT NULL,
  `AdminGroup` varchar(20) DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`locationId`),
  KEY `dpt_idx_idx` (`Dpt`),
  KEY `dpt_admgrp_idx_idx` (`AdminGroup`),
  CONSTRAINT `dpt_admgrp_idx` FOREIGN KEY (`AdminGroup`) REFERENCES `tbl_admingroup` (`admingroup`),
  CONSTRAINT `dpt_Idx` FOREIGN KEY (`Dpt`) REFERENCES `tbl_dpt` (`dpt`)
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_smsnotificationalert`
--

DROP TABLE IF EXISTS `tbl_smsnotificationalert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_smsnotificationalert` (
  `idtbl_notificationalert` int NOT NULL AUTO_INCREMENT,
  `AdminGroup` varchar(20) DEFAULT NULL,
  `SMSNumber` varchar(45) DEFAULT NULL,
  `JobRole` varchar(45) DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  PRIMARY KEY (`idtbl_notificationalert`),
  KEY `smsnt_admgrp_idx_idx` (`AdminGroup`),
  KEY `smsnt_user_idx_idx` (`EnterBy`),
  CONSTRAINT `smsnt_admgrp_idx` FOREIGN KEY (`AdminGroup`) REFERENCES `tbl_admingroup` (`admingroup`),
  CONSTRAINT `smsnt_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_ticket`
--

DROP TABLE IF EXISTS `tbl_ticket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_ticket` (
  `tktId` int NOT NULL,
  `TktNotificationTo` varchar(45) DEFAULT NULL,
  `IdString` varchar(45) NOT NULL,
  `AssingTo` varchar(45) DEFAULT NULL,
  `AdminGroup` varchar(20) DEFAULT NULL,
  `AssetID` varchar(45) DEFAULT NULL,
  `SN` varchar(45) DEFAULT NULL,
  `Location` varchar(45) DEFAULT NULL,
  `Dpt` varchar(45) DEFAULT NULL,
  `TktPriority` varchar(45) DEFAULT NULL,
  `TkDetails` varchar(500) DEFAULT NULL,
  `TicketStatus` varchar(45) DEFAULT NULL,
  `TktDeliveryDate` date DEFAULT NULL,
  `TkDeliveryTime` time DEFAULT NULL,
  `TktTechWork` varchar(400) DEFAULT NULL,
  `TkCompleteDate` date DEFAULT NULL,
  `TkCompleteTime` time DEFAULT NULL,
  `TkSubmitDate` date DEFAULT NULL,
  `TkSubmitTime` time DEFAULT NULL,
  `TkSubmitBy` int DEFAULT NULL,
  `TktFB` varchar(500) DEFAULT NULL,
  `TktFBDate` date DEFAULT NULL,
  `TktFBTime` time DEFAULT NULL,
  PRIMARY KEY (`IdString`),
  KEY `AssetID_idx_idx` (`AssetID`),
  KEY `tkt_admingroup_idx_idx` (`AdminGroup`),
  KEY `tkt_userId_idx_idx` (`TkSubmitBy`),
  KEY `tkt_dpt_idx_idx` (`Dpt`),
  CONSTRAINT `AssetID_idx` FOREIGN KEY (`AssetID`) REFERENCES `tbl_inventory` (`InvIdString`),
  CONSTRAINT `tkt_admingroup_idx` FOREIGN KEY (`AdminGroup`) REFERENCES `tbl_admingroup` (`admingroup`),
  CONSTRAINT `tkt_dpt_idx` FOREIGN KEY (`Dpt`) REFERENCES `tbl_dpt` (`dpt`),
  CONSTRAINT `tkt_userId_idx` FOREIGN KEY (`TkSubmitBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_tkteventlog`
--

DROP TABLE IF EXISTS `tbl_tkteventlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_tkteventlog` (
  `idtbl_tkteventlog` int NOT NULL AUTO_INCREMENT,
  `TktIdString` varchar(45) NOT NULL,
  `TktLogHeader` varchar(45) DEFAULT NULL,
  `TktEvent` text,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` int DEFAULT NULL,
  PRIMARY KEY (`idtbl_tkteventlog`,`TktIdString`),
  KEY `tkt_idx_idx` (`TktIdString`),
  KEY `tel_user_idx_idx` (`EnterBy`),
  CONSTRAINT `tel_idx` FOREIGN KEY (`TktIdString`) REFERENCES `tbl_ticket` (`IdString`),
  CONSTRAINT `tel_user_idx` FOREIGN KEY (`EnterBy`) REFERENCES `tbl_userlist` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tbl_userlist`
--

DROP TABLE IF EXISTS `tbl_userlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tbl_userlist` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `UserName` varchar(45) NOT NULL,
  `UserType` varchar(45) DEFAULT NULL,
  `Password` varchar(45) NOT NULL,
  `Name` varchar(45) NOT NULL,
  `Email` varchar(45) DEFAULT NULL,
  `Mobile` varchar(45) DEFAULT NULL,
  `Dpt` varchar(45) DEFAULT NULL,
  `IsActive` int DEFAULT NULL,
  `AutoLogin` varchar(45) DEFAULT NULL,
  `AndroidID` varchar(45) DEFAULT NULL,
  `admingroup` varchar(20) DEFAULT NULL,
  `EnterDate` date DEFAULT NULL,
  `EnterTime` time DEFAULT NULL,
  `EnterBy` varchar(20) DEFAULT NULL,
  `stockLoc` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  KEY `uls_admigrp_idx_idx` (`admingroup`),
  KEY `uls_sto_loc_idx` (`stockLoc`),
  CONSTRAINT `uls_admigrp_idx` FOREIGN KEY (`admingroup`) REFERENCES `tbl_admingroup` (`admingroup`),
  CONSTRAINT `uls_sto_loc` FOREIGN KEY (`stockLoc`) REFERENCES `tbl_itemloclist` (`locationID`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-08-20  7:45:44
