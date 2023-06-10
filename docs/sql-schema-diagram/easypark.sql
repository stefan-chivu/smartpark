-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jun 10, 2023 at 11:43 AM
-- Server version: 8.0.33-0ubuntu0.22.04.2
-- PHP Version: 8.1.2-1ubuntu2.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `easypark`
--

-- --------------------------------------------------------

--
-- Table structure for table `Cars`
--

CREATE TABLE `Cars` (
  `car_id` int NOT NULL,
  `license_plate` varchar(15) NOT NULL,
  `owner` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `is_electric` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Cars`
--

INSERT INTO `Cars` (`car_id`, `license_plate`, `owner`, `is_electric`) VALUES
(-1, '_UNKNOWN', NULL, 0),
(12, 'TM21CXC', 'GR9aV6xe9RN0fm4Xjl689ttfgH52', 0),
(20, 'TM67KVU', 'GR9aV6xe9RN0fm4Xjl689ttfgH52', 0),
(21, 'TM01CHV', 'GR9aV6xe9RN0fm4Xjl689ttfgH52', 1),
(24, 'TM01CHD', 'afEktfTpqQdEw0zoWnGKaSwE1C52', 0),
(25, 'TM21CXV', 'RI0UoGaig3OPhzrg3cTNEiD4X6e2', 0),
(26, 'TM21CXA', 'SOT36ooIG9hEGCZyjkME6j4tOXf2', 0),
(31, 'TM22ABC', 'aEZHo4sSDONvCD4rpxnndXd1C6B3', 0),
(32, 'RTTTT', 'T2pMvFOwe4O4n7vR34Col8N0GL52', 0),
(33, '00v77hb', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `Occupancy`
--

CREATE TABLE `Occupancy` (
  `entry_id` int NOT NULL,
  `sensor_id` int NOT NULL,
  `occupied` tinyint(1) NOT NULL DEFAULT '0',
  `car_id` int NOT NULL DEFAULT '-1',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Occupancy`
--

INSERT INTO `Occupancy` (`entry_id`, `sensor_id`, `occupied`, `car_id`, `timestamp`) VALUES
(100, 1, 0, -1, '2023-01-07 18:12:52'),
(101, 2, 0, -1, '2023-01-07 18:13:28'),
(108, 10, 0, -1, '2023-01-09 21:25:41'),
(109, 11, 0, -1, '2023-01-09 21:26:45'),
(110, 11, 1, -1, '2023-01-09 21:35:07'),
(111, 15, 0, -1, '2023-01-12 15:15:59'),
(114, 10, 1, -1, '2023-01-13 15:16:38'),
(115, 20, 0, -1, '2023-01-13 15:18:16'),
(116, 20, 1, -1, '2023-01-13 15:23:29'),
(118, 25, 0, -1, '2023-03-10 09:43:29'),
(119, 55, 0, -1, '2023-03-28 12:32:44'),
(120, 5, 0, -1, '2023-03-28 14:39:54'),
(121, 90, 0, -1, '2023-04-03 15:24:45'),
(127, 9, 0, -1, '2023-04-06 10:53:07'),
(129, 19, 0, -1, '2023-05-10 15:26:50'),
(130, 1, 1, -1, '2023-05-11 08:16:17'),
(132, 3, 1, -1, '2023-05-25 20:01:01'),
(134, 5, 1, -1, '2023-05-25 20:07:19'),
(136, 1, 0, -1, '2023-05-29 10:43:53'),
(137, 1, 1, 33, '2023-05-29 10:43:56'),
(138, 1, 0, 33, '2023-05-29 10:44:03'),
(139, 1, 1, -1, '2023-05-29 10:44:28'),
(140, 1, 0, -1, '2023-05-29 10:45:05'),
(141, 1, 1, -1, '2023-05-29 10:45:11'),
(142, 1, 0, -1, '2023-05-29 10:45:12'),
(143, 1, 1, -1, '2023-05-29 10:45:14'),
(144, 1, 0, -1, '2023-05-29 10:45:32'),
(145, 1, 1, -1, '2023-05-29 10:45:40'),
(146, 1, 0, -1, '2023-05-29 10:45:42'),
(147, 1, 1, -1, '2023-05-29 10:45:51'),
(148, 1, 0, -1, '2023-05-29 10:45:53'),
(149, 1, 1, -1, '2023-05-29 10:46:04'),
(150, 1, 0, -1, '2023-05-29 10:46:46'),
(151, 1, 1, -1, '2023-05-29 10:46:50'),
(152, 1, 0, -1, '2023-05-29 10:47:23'),
(153, 1, 1, -1, '2023-05-29 10:47:25'),
(154, 1, 0, -1, '2023-05-29 12:34:32'),
(155, 1, 1, -1, '2023-05-29 12:34:45'),
(156, 1, 0, -1, '2023-05-29 12:34:52'),
(157, 1, 1, -1, '2023-05-29 12:35:53'),
(158, 1, 0, -1, '2023-05-29 12:36:03'),
(159, 1, 1, -1, '2023-05-29 14:38:51'),
(161, 1, 1, -1, '2023-05-29 14:39:07'),
(162, 1, 0, -1, '2023-05-29 14:39:18'),
(163, 1, 1, -1, '2023-05-29 14:39:26'),
(164, 1, 0, -1, '2023-05-29 14:39:32'),
(165, 1, 1, -1, '2023-05-29 14:39:46'),
(166, 1, 0, -1, '2023-05-29 14:39:52'),
(167, 1, 1, -1, '2023-05-29 14:40:15'),
(168, 1, 0, -1, '2023-05-29 14:40:33'),
(169, 1, 1, -1, '2023-05-29 14:42:50'),
(170, 1, 0, -1, '2023-05-29 14:43:06'),
(171, 1, 1, -1, '2023-05-29 15:13:24'),
(172, 1, 0, -1, '2023-05-29 15:13:44'),
(173, 1, 1, -1, '2023-05-29 15:15:57'),
(174, 1, 0, -1, '2023-05-29 15:16:59'),
(175, 1, 1, -1, '2023-05-29 15:22:43'),
(178, 112, 0, -1, '2023-06-01 18:06:31'),
(180, 66, 0, -1, '2023-06-01 18:22:42'),
(182, 88, 0, -1, '2023-06-02 20:18:19'),
(184, 60, 0, -1, '2023-06-07 14:41:13'),
(188, 91, 0, -1, '2023-06-08 14:33:18'),
(189, 92, 0, -1, '2023-06-08 14:33:51'),
(190, 93, 0, -1, '2023-06-08 14:34:29'),
(193, 111, 1, 20, '2023-06-08 14:38:45'),
(196, 95, 0, -1, '2023-06-08 15:11:37'),
(197, 89, 0, -1, '2023-06-10 11:23:01'),
(198, 86, 0, -1, '2023-06-10 11:36:01');

-- --------------------------------------------------------

--
-- Table structure for table `Payments`
--

CREATE TABLE `Payments` (
  `payment_id` int NOT NULL,
  `sensor_id` int NOT NULL,
  `car_id` int NOT NULL,
  `total_sum` double NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `parking_start` timestamp NOT NULL,
  `parking_end` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Payments`
--

INSERT INTO `Payments` (`payment_id`, `sensor_id`, `car_id`, `total_sum`, `timestamp`, `parking_start`, `parking_end`) VALUES
(1, 1, 21, 13.5, '2023-04-03 15:51:56', '2023-04-03 12:31:33', '2023-04-03 15:31:58'),
(2, 5, 20, 12, '2023-04-04 12:54:07', '2023-04-04 11:32:29', '2023-04-04 12:52:14'),
(3, 2, 21, 0.4, '2023-06-08 12:37:17', '2023-04-04 11:35:22', '2023-04-04 11:44:21'),
(4, 15, 20, 130, '2023-06-08 12:38:33', '2023-04-03 14:44:34', '2023-04-04 16:44:57'),
(5, 5, 12, 0.1, '2023-06-08 12:39:48', '2023-06-08 12:39:31', '2023-06-08 12:45:32'),
(6, 112, 20, 38, '2023-06-08 14:56:48', '2023-06-04 23:39:47', '2023-06-08 03:39:47'),
(7, 80, 12, 3.5666666666666664, '2023-06-08 15:12:29', '2023-06-08 15:41:39', '2023-06-08 17:28:39');

-- --------------------------------------------------------

--
-- Table structure for table `Reservations`
--

CREATE TABLE `Reservations` (
  `id` int NOT NULL,
  `spot_id` int NOT NULL,
  `reserved_by` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Reservations`
--

INSERT INTO `Reservations` (`id`, `spot_id`, `reserved_by`) VALUES
(82, 9, 'GR9aV6xe9RN0fm4Xjl689ttfgH52'),
(73, 12, 'GR9aV6xe9RN0fm4Xjl689ttfgH52'),
(65, 60, 'GR9aV6xe9RN0fm4Xjl689ttfgH52');

-- --------------------------------------------------------

--
-- Table structure for table `Schedules`
--

CREATE TABLE `Schedules` (
  `schedule_id` int NOT NULL,
  `start_hour` time NOT NULL,
  `stop_hour` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Schedules`
--

INSERT INTO `Schedules` (`schedule_id`, `start_hour`, `stop_hour`) VALUES
(1, '08:00:00', '20:00:00'),
(2, '08:00:00', '14:00:00'),
(3, '00:00:00', '24:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `Sensors`
--

CREATE TABLE `Sensors` (
  `sensor_id` int NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `is_electric` tinyint(1) NOT NULL DEFAULT '0',
  `zone_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Sensors`
--

INSERT INTO `Sensors` (`sensor_id`, `latitude`, `longitude`, `is_electric`, `zone_id`) VALUES
(1, 45.7970338, 21.3022766, 1, 3),
(2, 45.796629093122114, 21.301662102341652, 0, 1),
(3, 45.802165585326115, 21.294618286192417, 0, 2),
(5, 45.803945, 21.2926583, 1, 3),
(9, 45.804840837371074, 21.294178068637848, 0, 2),
(10, 45.74765163478096, 21.226254478096962, 0, 2),
(11, 45.74752342327914, 21.225605383515358, 0, 2),
(12, 45.7564900316142, 21.232276372611523, 0, 1),
(15, 45.749214247282964, 21.22599296271801, 0, 4),
(19, 45.75357056778051, 21.227175146341324, 0, 2),
(20, 45.748406626100625, 21.233068965375423, 0, 2),
(25, 45.74863356602583, 21.233370043337345, 0, 2),
(55, 45.75856912075095, 21.225799173116684, 0, 1),
(56, 45.75711764960517, 21.232334040105343, 0, 4),
(60, 45.80362944044794, 21.29252079874277, 1, 4),
(66, 45.8028949, 21.2956536, 0, 3),
(80, 45.803765236011664, 21.292686760425568, 0, 2),
(86, 45.80231003258427, 21.28836538642645, 1, 1),
(88, 45.50802833311133, 22.350177504122257, 0, 4),
(89, 45.80680313697565, 21.287319995462894, 0, 2),
(90, 45.747633853641375, 21.22629269957542, 0, 3),
(91, 45.740892521935024, 21.233324445784092, 1, 2),
(92, 45.741061462931874, 21.23155117034912, 0, 2),
(93, 45.74125099446674, 21.234009750187397, 0, 2),
(95, 45.8042462441409, 21.29336703568697, 1, 4),
(99, 45.507939281444905, 22.34861209988594, 0, 1),
(111, 45.80425348961545, 21.293349601328373, 0, 1),
(112, 45.80377575372654, 21.296805627644062, 0, 2);

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `uid` varchar(30) NOT NULL,
  `email` varchar(320) NOT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `first_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `last_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `license_plate` varchar(20) NOT NULL DEFAULT '',
  `home_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `work_address` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `onboarding_complete` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Users`
--

INSERT INTO `Users` (`uid`, `email`, `is_admin`, `first_name`, `last_name`, `license_plate`, `home_address`, `work_address`, `onboarding_complete`) VALUES
('aEZHo4sSDONvCD4rpxnndXd1C6B3', 'newacc@gmail.com', 0, '', '', '', '', '', 1),
('afEktfTpqQdEw0zoWnGKaSwE1C52', 'test_email@domain.com', 0, 'test', 'last', '', '', '{\"street\":\"Bulevardul Vasile Pârvan 2\",\"city\":\"Timișoara\",\"region\":\"Județul Timiș\",\"country\":\"Romania\"}', 1),
('GR9aV6xe9RN0fm4Xjl689ttfgH52', 'stefan.chivu1@yahoo.com', 1, 'Stefan', 'Chivu', 'TM67KVU', '{\"street\":\"Strada Macesului, 21\",\"city\":\"Giarmata-Vii\",\"region\":\"Timis\",\"country\":\"Romania\"}', '{\"street\":\"Strada Memorandului 76\",\"city\":\"Timișoara\",\"region\":\"Județul Timiș\",\"country\":\"Romania\"}', 1),
('gzwkNdjHghQgamnQ0vSOCK9Z5s72', 'user@test.com', 0, 'User', 'Test', '', '', '{\"street\":\"Strada Florimund Mercy 9\",\"city\":\"Timișoara\",\"region\":\"Județul Timiș\",\"country\":\"Romania\"}', 0),
('IlqhekOXBsaFwyH45YFnjp1DYgZ2', 'test@email.com', 0, 'gigi', 'bec', '', '{\"street\":\"Splaiul Nicolae Titulescu 16\",\"city\":\"Timișoara\",\"region\":\"Județul Timiș\",\"country\":\"Romania\"}', '{\"street\":\"Calea Sever Bocu 308B\",\"city\":\"Timișoara\",\"region\":\"Județul Timiș\",\"country\":\"Romania\"}', 1),
('RI0UoGaig3OPhzrg3cTNEiD4X6e2', 'test@gmail.com', 0, 'FirstN', '', '', '', '{\"street\":\"Bulevardul Vasile Pârvan 2\",\"city\":\"Timișoara\",\"region\":\"Județul Timiș\",\"country\":\"Romania\"}', 1),
('SOT36ooIG9hEGCZyjkME6j4tOXf2', 'test1@gmail.com', 0, 'Stefan', '', '', '', '', 1),
('T2pMvFOwe4O4n7vR34Col8N0GL52', 'test@gmail1.com', 0, '', '', '', '', '', 1);

-- --------------------------------------------------------

--
-- Table structure for table `Zones`
--

CREATE TABLE `Zones` (
  `zone_id` int NOT NULL,
  `zone_name` varchar(30) NOT NULL,
  `hour_rate` double NOT NULL,
  `day_rate` double DEFAULT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'RON',
  `is_private` tinyint(1) NOT NULL DEFAULT '0',
  `total_spots` int DEFAULT NULL,
  `mon_schedule_id` int NOT NULL,
  `tue_schedule_id` int NOT NULL,
  `wed_schedule_id` int NOT NULL,
  `thu_schedule_id` int NOT NULL,
  `fri_schedule_id` int NOT NULL,
  `sat_schedule_id` int NOT NULL,
  `sun_schedule_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `Zones`
--

INSERT INTO `Zones` (`zone_id`, `zone_name`, `hour_rate`, `day_rate`, `currency`, `is_private`, `total_spots`, `mon_schedule_id`, `tue_schedule_id`, `wed_schedule_id`, `thu_schedule_id`, `fri_schedule_id`, `sat_schedule_id`, `sun_schedule_id`) VALUES
(1, 'Zona Rosie', 3, 15, 'RON', 0, NULL, 1, 1, 1, 1, 1, 2, 2),
(2, 'Zona Galbena', 2, 10, 'RON', 0, NULL, 1, 1, 1, 1, 1, 2, 2),
(3, 'DevVariateZoneDaily', 1, 24, 'EUR', 0, NULL, 1, 2, 3, 1, 2, 2, 1),
(4, 'Zona Verde', 5, NULL, 'RON', 0, NULL, 1, 1, 1, 1, 1, 1, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Cars`
--
ALTER TABLE `Cars`
  ADD PRIMARY KEY (`car_id`),
  ADD UNIQUE KEY `license_plate` (`license_plate`),
  ADD KEY `owner` (`owner`);

--
-- Indexes for table `Occupancy`
--
ALTER TABLE `Occupancy`
  ADD PRIMARY KEY (`entry_id`),
  ADD KEY `sensor_id_fk` (`sensor_id`),
  ADD KEY `car_id_fk` (`car_id`);

--
-- Indexes for table `Payments`
--
ALTER TABLE `Payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `pay_car_id_fk` (`car_id`),
  ADD KEY `pay_sensor_id` (`sensor_id`);

--
-- Indexes for table `Reservations`
--
ALTER TABLE `Reservations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `spot_id` (`spot_id`,`reserved_by`),
  ADD KEY `fk_reserved_by_uid` (`reserved_by`);

--
-- Indexes for table `Schedules`
--
ALTER TABLE `Schedules`
  ADD PRIMARY KEY (`schedule_id`);

--
-- Indexes for table `Sensors`
--
ALTER TABLE `Sensors`
  ADD PRIMARY KEY (`sensor_id`),
  ADD KEY `sensor_zone_fk` (`zone_id`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`uid`);

--
-- Indexes for table `Zones`
--
ALTER TABLE `Zones`
  ADD PRIMARY KEY (`zone_id`),
  ADD KEY `mon_schedule_fk` (`mon_schedule_id`),
  ADD KEY `tue_schedule_fk` (`tue_schedule_id`),
  ADD KEY `wed_schedule_fk` (`wed_schedule_id`),
  ADD KEY `thu_schedule_fk` (`thu_schedule_id`),
  ADD KEY `fri_schedule_fk` (`fri_schedule_id`),
  ADD KEY `sat_schedule_fk` (`sat_schedule_id`),
  ADD KEY `sun_schedule_fk` (`sun_schedule_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Cars`
--
ALTER TABLE `Cars`
  MODIFY `car_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `Occupancy`
--
ALTER TABLE `Occupancy`
  MODIFY `entry_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=199;

--
-- AUTO_INCREMENT for table `Payments`
--
ALTER TABLE `Payments`
  MODIFY `payment_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `Reservations`
--
ALTER TABLE `Reservations`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- AUTO_INCREMENT for table `Schedules`
--
ALTER TABLE `Schedules`
  MODIFY `schedule_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Sensors`
--
ALTER TABLE `Sensors`
  MODIFY `sensor_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

--
-- AUTO_INCREMENT for table `Zones`
--
ALTER TABLE `Zones`
  MODIFY `zone_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Cars`
--
ALTER TABLE `Cars`
  ADD CONSTRAINT `fk_car_owner_uid` FOREIGN KEY (`owner`) REFERENCES `Users` (`uid`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `Occupancy`
--
ALTER TABLE `Occupancy`
  ADD CONSTRAINT `car_id_fk` FOREIGN KEY (`car_id`) REFERENCES `Cars` (`car_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `sensor_id_fk` FOREIGN KEY (`sensor_id`) REFERENCES `Sensors` (`sensor_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Payments`
--
ALTER TABLE `Payments`
  ADD CONSTRAINT `pay_car_id_fk` FOREIGN KEY (`car_id`) REFERENCES `Cars` (`car_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `pay_sensor_id` FOREIGN KEY (`sensor_id`) REFERENCES `Sensors` (`sensor_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Reservations`
--
ALTER TABLE `Reservations`
  ADD CONSTRAINT `fk_reserved_by_uid` FOREIGN KEY (`reserved_by`) REFERENCES `Users` (`uid`) ON DELETE CASCADE ON UPDATE RESTRICT,
  ADD CONSTRAINT `fk_reserved_spot_id` FOREIGN KEY (`spot_id`) REFERENCES `Sensors` (`sensor_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `Sensors`
--
ALTER TABLE `Sensors`
  ADD CONSTRAINT `sensor_zone_fk` FOREIGN KEY (`zone_id`) REFERENCES `Zones` (`zone_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `Zones`
--
ALTER TABLE `Zones`
  ADD CONSTRAINT `fri_schedule_fk` FOREIGN KEY (`fri_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `mon_schedule_fk` FOREIGN KEY (`mon_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `sat_schedule_fk` FOREIGN KEY (`sat_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `sun_schedule_fk` FOREIGN KEY (`sun_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `thu_schedule_fk` FOREIGN KEY (`thu_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `tue_schedule_fk` FOREIGN KEY (`tue_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `wed_schedule_fk` FOREIGN KEY (`wed_schedule_id`) REFERENCES `Schedules` (`schedule_id`) ON DELETE RESTRICT ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
