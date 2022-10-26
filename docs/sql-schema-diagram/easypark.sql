-- phpMyAdmin SQL Dump
-- version 5.1.1deb5ubuntu1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 29, 2022 at 10:19 PM
-- Server version: 8.0.31-0ubuntu0.22.04.1
-- PHP Version: 8.1.2-1ubuntu2.6

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
-- Table structure for table `Addresses`
--

CREATE TABLE `Addresses` (
  `address_id` int NOT NULL,
  `street` varchar(30) NOT NULL,
  `city` varchar(30) NOT NULL,
  `region` varchar(30) NOT NULL,
  `country` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Cars`
--

CREATE TABLE `Cars` (
  `car_id` int NOT NULL,
  `license_plate` varchar(15) NOT NULL,
  `owner` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Occupancy`
--

CREATE TABLE `Occupancy` (
  `entry_id` int NOT NULL,
  `sensor_id` int NOT NULL,
  `occupied` int NOT NULL DEFAULT '0',
  `car_id` int NOT NULL DEFAULT '-1',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Payments`
--

CREATE TABLE `Payments` (
  `payment_id` int NOT NULL,
  `sensor_id` int NOT NULL,
  `car_id` int NOT NULL,
  `total_sum` double NOT NULL,
  `is_resolved` tinyint(1) NOT NULL DEFAULT '0',
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Schedules`
--

CREATE TABLE `Schedules` (
  `schedule_id` int NOT NULL,
  `start_hour` time NOT NULL,
  `stop_hour` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Sensors`
--

CREATE TABLE `Sensors` (
  `sensor_id` int NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  `address_id` int DEFAULT NULL,
  `zone_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `Zones`
--

CREATE TABLE `Zones` (
  `zone_id` int NOT NULL,
  `zone_name` varchar(30) NOT NULL,
  `hour_rate` double NOT NULL,
  `day_rate` double DEFAULT NULL,
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
-- Indexes for dumped tables
--

--
-- Indexes for table `Addresses`
--
ALTER TABLE `Addresses`
  ADD PRIMARY KEY (`address_id`);

--
-- Indexes for table `Cars`
--
ALTER TABLE `Cars`
  ADD PRIMARY KEY (`car_id`);

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
-- Indexes for table `Schedules`
--
ALTER TABLE `Schedules`
  ADD PRIMARY KEY (`schedule_id`);

--
-- Indexes for table `Sensors`
--
ALTER TABLE `Sensors`
  ADD PRIMARY KEY (`sensor_id`),
  ADD KEY `sensor_address_fk` (`address_id`),
  ADD KEY `sensor_zone_fk` (`zone_id`);

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
-- AUTO_INCREMENT for table `Addresses`
--
ALTER TABLE `Addresses`
  MODIFY `address_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Cars`
--
ALTER TABLE `Cars`
  MODIFY `car_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Occupancy`
--
ALTER TABLE `Occupancy`
  MODIFY `entry_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Payments`
--
ALTER TABLE `Payments`
  MODIFY `payment_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Schedules`
--
ALTER TABLE `Schedules`
  MODIFY `schedule_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Sensors`
--
ALTER TABLE `Sensors`
  MODIFY `sensor_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Zones`
--
ALTER TABLE `Zones`
  MODIFY `zone_id` int NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

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
-- Constraints for table `Sensors`
--
ALTER TABLE `Sensors`
  ADD CONSTRAINT `sensor_address_fk` FOREIGN KEY (`address_id`) REFERENCES `Addresses` (`address_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
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
