-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 23, 2023 at 03:02 PM
-- Server version: 5.7.37
-- PHP Version: 8.1.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `coryl321_CAMPUS`
--

-- --------------------------------------------------------

--
-- Table structure for table `CAMPUSES`
--

CREATE TABLE `CAMPUSES` (
  `CAMPUS` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `CAMPUS_PLACES`
--

CREATE TABLE `CAMPUS_PLACES` (
  `CAMPUS` varchar(10) NOT NULL,
  `PLACE` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `CAMPUS_PLACES`
--
DELIMITER $$
CREATE TRIGGER `CAMPUS_PLACES_VALIDATOR` BEFORE INSERT ON `CAMPUS_PLACES` FOR EACH ROW BEGIN
	/* CAMPUS, PLACE are incoming parameters */
	/*INSERT INTO CAMPUS_PLACES (CAMPUS, PLACE) VALUES ('UHM', 'Joes Diner');*/
	SET @exists = (SELECT COUNT(*) FROM CAMPUSES WHERE CAMPUS = NEW.CAMPUS);
	IF @exists = 0 THEN
		SET @msg = CONCAT(NEW.CAMPUS, ' is not a valid campus');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
	END IF;
    SET @cuisine = (SELECT CUISINE FROM PLACE_CUISINES WHERE PLACE=NEW.PLACE);
	IF @cuisine IS NULL THEN
		SET @msg = CONCAT(NEW.PLACE, ' is not in the database');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END IF;
    SET @place = (SELECT PLACE FROM (CAMPUSES JOIN CUISINES) NATURAL JOIN PLACE_CUISINES NATURAL JOIN CAMPUS_PLACES
		WHERE CAMPUS=NEW.CAMPUS AND CUISINE=@cuisine);
    IF @place IS NOT NULL THEN
		SET @msg = CONCAT(@place, ' is already the designated favorite', @cuisine,' for ',NEW.CAMPUS);
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `CUISINES`
--

CREATE TABLE `CUISINES` (
  `CUISINE` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `ORIGINAL`
--

CREATE TABLE `ORIGINAL` (
  `CAMPUS` varchar(10) NOT NULL,
  `CUISINE` varchar(25) NOT NULL,
  `PLACE` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `PLACE_CUISINES`
--

CREATE TABLE `PLACE_CUISINES` (
  `PLACE` varchar(50) NOT NULL,
  `CUISINE` varchar(25) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `PLACE_CUISINES`
--
DELIMITER $$
CREATE TRIGGER `PLACE_CUISINES_VALIDATOR` BEFORE UPDATE ON `PLACE_CUISINES` FOR EACH ROW BEGIN
/* Input: NEW.PLACE, NEW.CUISINE */
    SET @placel = (SELECT PLACE FROM CAMPUS_PLACES NATURAL JOIN PLACE_CUISINES
                    WHERE CUISINE = NEW.CUISINE 
                    AND CAMPUS IN (SELECT CAMPUS FROM CAMPUS_PLACES WHERE PLACE = NEW.PLACE) LIMIT 1);
    SET @placel = NULLIF(@placel, '');

    IF @placel IS NOT NULL THEN
        SET @campusl = (SELECT CAMPUS FROM CAMPUS_PLACES 
                        WHERE PLACE = @placel 
                        AND CAMPUS IN (SELECT CAMPUS FROM CAMPUS_PLACES WHERE PLACE = NEW.PLACE) LIMIT 1);
        SET @msg = CONCAT(NEW.PLACE, ' is a favorite at ', @campus1, ' and ', @campusl, ' already has ', @placel, ' as its favorite ', NEW.CUISINE, ' place');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @msg;
    END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `CAMPUSES`
--
ALTER TABLE `CAMPUSES`
  ADD PRIMARY KEY (`CAMPUS`);

--
-- Indexes for table `CAMPUS_PLACES`
--
ALTER TABLE `CAMPUS_PLACES`
  ADD PRIMARY KEY (`CAMPUS`,`PLACE`),
  ADD KEY `FK_CAMPUS_PLACES_PLACE_CUISINES` (`PLACE`);

--
-- Indexes for table `CUISINES`
--
ALTER TABLE `CUISINES`
  ADD PRIMARY KEY (`CUISINE`);

--
-- Indexes for table `ORIGINAL`
--
ALTER TABLE `ORIGINAL`
  ADD PRIMARY KEY (`CAMPUS`,`CUISINE`);

--
-- Indexes for table `PLACE_CUISINES`
--
ALTER TABLE `PLACE_CUISINES`
  ADD PRIMARY KEY (`PLACE`),
  ADD KEY `FK_PLACE_CUISINES_CUISINES` (`CUISINE`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `CAMPUS_PLACES`
--
ALTER TABLE `CAMPUS_PLACES`
  ADD CONSTRAINT `FK_CAMPUS_PLACES_CAMPUSES` FOREIGN KEY (`CAMPUS`) REFERENCES `CAMPUSES` (`CAMPUS`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_CAMPUS_PLACES_PLACE_CUISINES` FOREIGN KEY (`PLACE`) REFERENCES `PLACE_CUISINES` (`PLACE`) ON UPDATE CASCADE;

--
-- Constraints for table `PLACE_CUISINES`
--
ALTER TABLE `PLACE_CUISINES`
  ADD CONSTRAINT `FK_PLACE_CUISINES_CUISINES` FOREIGN KEY (`CUISINE`) REFERENCES `CUISINES` (`CUISINE`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
