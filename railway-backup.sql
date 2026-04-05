-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: trafficschool
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `trafficschool`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `trafficschool` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `trafficschool`;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `last_name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK47bvqemyk6vlm0w7crc3opdd4` (`email`),
  UNIQUE KEY `UKmi8vkhus4xbdbqcac2jm4spvd` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,_binary '','2026-03-31 16:35:56.355913','admin@trafficschool.com','Admin','2026-04-05 16:10:56.033325','User','$2a$10$CAMJKdY1PvTUYUYAN4WK/.Ibvk6jghOlDSc6qUVVnZz/fpqZE/77K','admin');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `answer`
--

DROP TABLE IF EXISTS `answer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `answer` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `correct` bit(1) NOT NULL,
  `question_id` bigint DEFAULT NULL,
  `selected_answer` varchar(255) DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  `exam_session_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FKo2at6q1x26opbv4enm3is310f` (`exam_session_id`),
  CONSTRAINT `FKo2at6q1x26opbv4enm3is310f` FOREIGN KEY (`exam_session_id`) REFERENCES `exam_session` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `answer`
--

LOCK TABLES `answer` WRITE;
/*!40000 ALTER TABLE `answer` DISABLE KEYS */;
/*!40000 ALTER TABLE `answer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_session`
--

DROP TABLE IF EXISTS `exam_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_session` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `expires_at` datetime(6) DEFAULT NULL,
  `finished` bit(1) NOT NULL,
  `questions_json` text,
  `starts_at` datetime(6) DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_session`
--

LOCK TABLES `exam_session` WRITE;
/*!40000 ALTER TABLE `exam_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `exam_session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `excel_imports`
--

DROP TABLE IF EXISTS `excel_imports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `excel_imports` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `dry_run` bit(1) NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `uploaded_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `excel_imports`
--

LOCK TABLES `excel_imports` WRITE;
/*!40000 ALTER TABLE `excel_imports` DISABLE KEYS */;
/*!40000 ALTER TABLE `excel_imports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_token`
--

DROP TABLE IF EXISTS `login_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_token` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `email` varchar(255) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `token` varchar(255) NOT NULL,
  `used` bit(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKlrv8gdes2xrluyamavi0rj5r7` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_token`
--

LOCK TABLES `login_token` WRITE;
/*!40000 ALTER TABLE `login_token` DISABLE KEYS */;
INSERT INTO `login_token` VALUES (4,'2026-04-04 23:04:13.193349','Fahrikuzey@hotmail.com','2026-04-04 23:09:13.193322','e4de4867-bb71-4c2a-b249-48e25afd56f0',_binary ''),(6,'2026-04-04 23:33:56.656414','fk@excetra.se','2026-04-04 23:38:56.656397','bbe70b14-6229-4bb3-b93d-2b7db0aad452',_binary ''),(9,'2026-04-05 18:09:38.032819','Fahrikuzey@hotmail.com','2026-04-05 18:14:38.032801','b4cb3085-1190-4f8c-a5d7-bf7313c7c210',_binary '');
/*!40000 ALTER TABLE `login_token` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `packages`
--

DROP TABLE IF EXISTS `packages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `packages` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `active` bit(1) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `package_type` enum('DAY','MONTH','WEEK') NOT NULL,
  `price` decimal(15,2) NOT NULL,
  `validity_days` int NOT NULL,
  `validity_hours` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `packages`
--

LOCK TABLES `packages` WRITE;
/*!40000 ALTER TABLE `packages` DISABLE KEYS */;
INSERT INTO `packages` VALUES (1,_binary '\0','24 hours full access to all quizzes and exams','1 Day Access','DAY',99.00,1,24),(2,_binary '','7 days full access to all quizzes and exams','1 Week Access','WEEK',349.00,7,168),(3,_binary '','30 days full access to all quizzes and exams','1 Month Access','MONTH',899.00,30,720);
/*!40000 ALTER TABLE `packages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` varchar(32) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `callback_identifier` varchar(36) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `error_code` varchar(50) DEFAULT NULL,
  `error_message` varchar(255) DEFAULT NULL,
  `package_id` bigint NOT NULL,
  `paid_at` datetime(6) DEFAULT NULL,
  `payer_alias` varchar(15) NOT NULL,
  `payment_reference` varchar(50) DEFAULT NULL,
  `status` enum('CANCELLED','CREATED','DECLINED','ERROR','PAID','PENDING','EXPIRED') NOT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES ('0B1840A5230E4FB295EDEACF1781AAC6',899.00,'660ea6be-7cdf-4873-831e-e7175e2cf82e','2026-04-04 21:08:05.235238',NULL,'Payment expired - timeout exceeded',3,NULL,'46733976425',NULL,'EXPIRED','2026-04-04 22:05:50.110665','2026-04-04 21:13:05',4),('0F7A615D3FF748A591A8E33F63A0E1D8',899.00,'6c57fc1f-0958-4c75-bc32-a00def5b7ecb','2026-04-04 21:07:10.219938',NULL,'Payment expired - timeout exceeded',3,NULL,'46733976425',NULL,'EXPIRED','2026-04-04 22:05:50.110782','2026-04-04 21:12:10',4),('1833355B424046A5BD95331F51B3C057',899.00,'f5df9408-8e4b-4981-8a27-938b340be106','2026-04-04 21:18:20.045700',NULL,'Payment expired - timeout exceeded',3,NULL,'46733976425',NULL,'EXPIRED','2026-04-04 22:05:50.110843','2026-04-04 21:23:20',4),('4069CE8B813748B591310D21DF4B90DC',899.00,'b49a7a59-f710-4ff2-ac39-608c3985835a','2026-04-04 21:07:04.665539',NULL,'Payment expired - timeout exceeded',3,NULL,'46733976425',NULL,'EXPIRED','2026-04-04 22:05:50.110909','2026-04-04 21:12:05',4),('518CBE20DBC64F16A923D86F3D866AB0',899.00,'58eae3bc-a21f-4097-8b31-e1ddd65660a2','2026-04-04 18:41:14.285212',NULL,NULL,3,'2026-04-04 18:41:14.249258','46701234567','TEST-REF-1','PAID','2026-04-04 18:41:14.285236',NULL,1),('87EC5C6CBE1B457EAD065DA15E14957F',899.00,'0d18c9e8-bfee-4541-a35c-0e875987e0dc','2026-04-04 21:23:21.507986',NULL,NULL,3,'2026-04-04 21:23:26.741950','46733976425','4875BF7EA4044FEBA3D52DDE249D15E1','PAID','2026-04-04 21:23:30.374738',NULL,4),('A8A9DBAAFE0F46E9B70AC7087CD15CC8',899.00,'1c98f874-e97f-4a71-a4f2-7a2fa935b23f','2026-04-04 21:07:16.526799',NULL,'Payment expired - timeout exceeded',3,NULL,'46733976425',NULL,'EXPIRED','2026-04-04 22:05:50.110966','2026-04-04 21:12:17',4),('EFBC88A330554A2B8EBBCA824CBD6E12',899.00,'1ad40427-c681-4ac0-87d4-f25b76f46167','2026-04-05 16:09:57.628006',NULL,NULL,3,'2026-04-05 16:10:03.093055','46733976425','3990B699B35D4B1E9532A1575529C0B0','PAID','2026-04-05 16:10:06.340613','2026-04-05 16:14:58',1);
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `question`
--

DROP TABLE IF EXISTS `question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `question` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `a` int NOT NULL,
  `adr` int NOT NULL,
  `am` int NOT NULL,
  `apv` int NOT NULL,
  `b` int NOT NULL,
  `be` int NOT NULL,
  `c` int NOT NULL,
  `ce` int NOT NULL,
  `correct_answer` varchar(255) DEFAULT NULL,
  `d` int NOT NULL,
  `de` int NOT NULL,
  `excel_id` int DEFAULT NULL,
  `explanation_for_student` longtext,
  `image` varchar(255) DEFAULT NULL,
  `lang` varchar(255) DEFAULT NULL,
  `question` varchar(255) DEFAULT NULL,
  `sfi` varchar(255) DEFAULT NULL,
  `subject` int NOT NULL,
  `ta1i1` int NOT NULL,
  `ta1i2` int NOT NULL,
  `ta1i3` int NOT NULL,
  `ta1i4` int NOT NULL,
  `ta1i5` int NOT NULL,
  `tra1` int NOT NULL,
  `vtl` int NOT NULL,
  `wrong_answer1` varchar(255) DEFAULT NULL,
  `wrong_answer2` varchar(255) DEFAULT NULL,
  `wrong_answer3` varchar(255) DEFAULT NULL,
  `ykbc` int NOT NULL,
  `ykbd` int NOT NULL,
  `yrs` int NOT NULL,
  `excel_import_file_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK91huhhoaecghv6sw1ojw3vuen` (`excel_import_file_id`),
  CONSTRAINT `FK91huhhoaecghv6sw1ojw3vuen` FOREIGN KEY (`excel_import_file_id`) REFERENCES `excel_imports` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `question`
--

LOCK TABLES `question` WRITE;
/*!40000 ALTER TABLE `question` DISABLE KEYS */;
INSERT INTO `question` VALUES (1,1,0,1,0,1,1,1,1,'Ett körfält behöver inte anges med vägmarkering.',1,1,1,'Ett körfält är en del av vägen där ett fordon kan köra i bredd. Det kan finnas markerade linjer som visar körfälten, men det är inte alltid ett krav. För att förstå detta kan det vara bra att tänka på en stor väg utan linjer – där finns ändå utrymme för fordon att köra i bredd.','test.jpg','SE','Vilket påstående om körfält är korrekt?','Vad stämmer om körfält?',1,1,0,0,0,0,0,0,'Vägrenen är ett körfält.','Ett körfält måste alltid anges med väg markering.','Ett körfält gäller endast för motorfordon.',1,1,0,NULL),(2,1,0,1,0,1,1,1,1,'Jag måste göra om både kunskapsprovet och körprovet om körkortet återkallas under prövotiden.',1,1,2,'Prövotiden är en extra säkerhetsregel för nya förare som varar i två år efter att du tagit körkort. Om ditt körkort blir återkallat under den tiden måste du börja om från början och göra om både teoriprovet och uppkörningen. Det här finns för att hjälpa nya förare att köra säkert och utveckla goda vanor tidigt.','test.jpg','SE','Du har körkort med prövotid. Vad gäller?','Vad gäller om jag har körkort med prövotid?',2,1,0,0,0,0,0,1,'Jag behöver enbart göra om körprovet om körkortet återkallas under prövotiden','Körkortet återkallas i två månader om man bötfälls för felparkering.','Jag får automatiskt tillbaka körkortet efter prövotiden om det återkallas.',1,1,0,NULL),(3,1,0,1,0,1,1,1,1,'Lastbil som har en totalvikt på högst 3.5 ton.',1,1,3,'En lätt lastbil är ett fordon för att transportera gods som inte får väga mer än 3,5 ton i totalvikt. Det är ungefär som en större personbil i viktklass. Skillnaden mellan lätt och tung lastbil är viktig, eftersom regler och körkortskrav skiljer sig åt.','test.jpg','SE','Vad innebär begreppet lätt lastbil?','Vad betyder lätt lastbil?',3,1,0,0,0,0,0,1,'Lastbil som har en maxlastvikt på högst 3.5 ton','Lastbil som har en bruttovikt på högst 3.5 ton.','Lastbil som har en tjänstevikt på högst 3.5 ton.',1,1,0,NULL),(4,1,0,1,0,1,1,1,1,'Lastbil med totalvikt på 3.1 ton.',1,1,4,'Med B-körkort får du köra personbilar och lätta lastbilar som har en totalvikt på högst 3,5 ton. Totalvikt betyder bilens egenvikt plus högsta tillåtna last. Om fordonet väger mer än 3,5 ton krävs ett körkort med högre behörighet, som C1. Många transportbilar och lätta lastbilar i vardagen ligger under denna gräns.','test.jpg','SE','Vilket fordon får du köra med behörighet B?','Vilka fordon får jag köra med körkort B?',4,1,0,0,0,0,0,1,'Personbil med tillkopplad tungt släpfordon','Buss godkänd för 10 passagerare.','Motorcykel med sidovagn',1,1,0,NULL),(5,1,0,1,0,1,1,1,1,'Kolmonoxid',1,1,5,'Kolmonoxid är en farlig gas som saknar både lukt och smak, vilket gör den svår att upptäcka. Den binder sig till blodets hemoglobin och minskar syretransporten i kroppen, vilket kan leda till allvarliga problem för hjärt- och kärlsystemet, såsom syrebrist i vitala organ. Det är därför viktigt att vara uppmärksam på god ventilation, särskilt i slutna utrymmen med motorfordon. Ett bra sätt att komma ihåg detta är att tänka på att kolmonoxid är tyst men farlig, vilket gör säkerhet extra viktig.','test.jpg','SE','Vilken avgas saknar lukt och smak och påverkar hjärt- och kärlsystem?','Vilken gas luktar inte, smakar inte och påverkar hjärta och blodkärl?',5,1,0,0,0,0,0,1,'Koldioxid','Kolväten','Kväveoxid',1,1,0,NULL),(6,1,0,1,0,1,1,1,1,'När jag kör motorn på tomgång i ett garage med dålig ventilation.',1,1,6,'Kolmonoxid är en farlig gas som inte syns eller luktar. Den bildas när motorn går, och i ett trångt utrymme utan ventilation kan den snabbt fylla luften och orsaka förgiftning. Därför ska du aldrig låta bilen stå på tomgång i ett stängt utrymme, som ett garage. Utomhus är risken mycket mindre eftersom gasen sprids i luften.','test.jpg','SE','När är risken störst att du drabbas av kolmonoxid förgiftning?','När är det störst risk att jag får kolmonoxidförgiftning?',1,1,0,0,0,0,0,1,'När jag kör sakta i en trafikkö inom tätbebyggt område.','När jag kör med fönstren öppna i låg hastighet.','När jag parkerar bilen med motorn avstängd i ett välventilerat garage.',1,1,0,NULL),(7,1,0,1,0,1,1,1,1,'Sätta på fläkten och stänga fönstren.',1,1,7,'När bagageluckan inte går att stänga är det viktigt att tänka på hur luften rör sig i bilen. Om du bara kör utan att göra något kan avgaser från bilen sugas in i kupén, och det är såklart inte bra! För att lösa detta kan du använda bilens ventilationssystem. Sätt fläkten på hög styrka. Det betyder att frisk luft utifrån dras in och skapar ett litet tryck i bilen, som trycker ut luften genom springor och gör att avgaserna inte kan komma in. Håll fönstren stängda, för om de är öppna fungerar trycket inte lika bra.','test.jpg','SE','Du kör en bil och har lastat en cykel i bagageutrymmet. Hur ska du göra för att undvika att få avgaser in i bilen?','Hur undviker jag att avgaser kommer in i bilen när jag kör med en cykel i bagaget?',2,1,0,0,0,0,0,1,'Stänga av fläkten och veva ner fönstren en bit.','Stänga av luftkonditionering och stänga fönstren.','Öppna fönster både fram och bak för att jämna ut lufttrycket.',1,1,0,NULL),(8,1,0,1,0,1,1,1,1,'Koldioxid',1,1,8,'Koldioxid bildas när bensin och diesel förbränns och är den gas i avgaserna som bidrar mest till växthuseffekten. Den gör att jordens temperatur stiger, vilket leder till klimatförändringar. Andra ämnen i avgaserna kan skada hälsa och miljö, men koldioxid har störst påverkan på klimatet.','test.jpg','SE','Vilket ämne i avgaserna bidrar mest till att öka växthuseffekten?','Vilket ämne i avgaserna gör växthuseffekten större?',3,1,0,0,0,0,0,1,'Kolväten','Kolmonoxid','Svaveldioxid',1,1,0,NULL),(9,1,0,1,0,1,1,1,1,'Koldioxid',1,1,9,'En katalysator tar bort många skadliga ämnen i avgaserna, som kolmonoxid och kväveoxider. Men den kan inte minska koldioxid, eftersom det alltid bildas när bränslet förbränns. För att minska koldioxidutsläpp måste du köra miljövänligt och tänka på din bränsleförbrukning. Katalysatorn hjälper, men inte mot koldioxid!','test.jpg','SE','Du kör en personbil med katalysator. Vilket ämne i avgaserna minskas inte av katalysatorn?','Vilket ämne i avgaserna minskar inte med katalysator?',4,1,0,0,0,0,0,1,'Kolmonoxid (koloxid)','Kväveoxid','Kolväten',1,1,0,NULL),(10,1,0,1,0,1,1,1,1,'Kolväten',1,1,10,'Kolväten är farliga ämnen i avgaser som kan orsaka cancer. De bildas när bränslet inte bränns upp helt i motorn. Katalysatorn i bilen hjälper till att minska mängden kolväten, men det är ändå viktigt att hålla motorn i bra skick och köra miljövänligt för att minska utsläppen.','test.jpg','SE','Vilket ämne i trafikens avgaser är mest cancer framkallande?','Vilket ämne i avgaserna orsakar mest cancer?',5,1,0,0,0,0,0,1,'Kolmonoxid','Kväveoxid','Svaveloxid',1,1,0,NULL);
/*!40000 ALTER TABLE `question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `result`
--

DROP TABLE IF EXISTS `result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `result` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `finished_at` datetime(6) DEFAULT NULL,
  `passed` bit(1) NOT NULL,
  `score` int NOT NULL,
  `exam_session_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKrncolalutajtae8tqoe63e4eo` (`exam_session_id`),
  CONSTRAINT `FKccmj5nj41pwpshb3j2tr435g8` FOREIGN KEY (`exam_session_id`) REFERENCES `exam_session` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `result`
--

LOCK TABLES `result` WRITE;
/*!40000 ALTER TABLE `result` DISABLE KEYS */;
/*!40000 ALTER TABLE `result` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cancelled` bit(1) NOT NULL,
  `end_date` datetime(6) NOT NULL,
  `package_id` bigint NOT NULL,
  `package_name` varchar(255) NOT NULL,
  `package_price` decimal(15,2) NOT NULL,
  `payment_id` varchar(255) NOT NULL,
  `purchase_date` datetime(6) NOT NULL,
  `start_date` datetime(6) NOT NULL,
  `user_id` bigint NOT NULL,
  `validity_days` int NOT NULL,
  `validity_hours` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES (1,_binary '\0','2026-05-04 23:23:30.232981',3,'1 Month Access',899.00,'87EC5C6CBE1B457EAD065DA15E14957F','2026-04-04 23:23:30.232950','2026-04-04 23:23:30.232975',4,30,720),(2,_binary '\0','2026-05-05 18:10:06.187382',3,'1 Month Access',899.00,'EFBC88A330554A2B8EBBCA824CBD6E12','2026-04-05 18:10:06.187376','2026-04-05 18:10:06.187382',1,30,720);
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `personal_number` varchar(255) NOT NULL,
  `phone_number` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'USER',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UK6dotkott2kjsp8vw4d0m25fb7` (`email`),
  UNIQUE KEY `UK6ff9eqia6nd9gavmrxp1e93di` (`personal_number`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'2026-04-04 19:24:45.020456','Robert@transportteori.se','Robert','Roos','199001011234','0701234567','USER'),(4,'2026-04-04 22:03:23.637290','fk@excetra.se','Fahri','ks','200010195097','0733976425','USER');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-05 16:13:38
