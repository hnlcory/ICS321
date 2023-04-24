-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 23, 2023 at 07:37 PM
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

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`coryl321`@`localhost` PROCEDURE `ADD_PLACE` (IN `campus1` VARCHAR(10), IN `cuisine1` VARCHAR(25), IN `place1` VARCHAR(50), OUT `error` INT, OUT `msg` VARCHAR(200))   BEGIN
    DECLARE msg2 VARCHAR(100) DEFAULT '';
    DECLARE cuisine2 VARCHAR(25) DEFAULT '';
    DECLARE place2 VARCHAR(50) DEFAULT '';    
    DECLARE valid INT(11) DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET msg=CONCAT(msg,' -- SQLEXCEPTION - ROLL BACK - nothing was inserted.');
        ROLLBACK;
    END;
    SET error = '0';
    SET valid = (SELECT COUNT(*) FROM CAMPUSES WHERE CAMPUS=campus1);
    IF (valid = 0) THEN    /* Validate campus1 */
        SET msg = CONCAT(campus1,' is not a designated campus');
        SET error = '1';
    END IF;
    START TRANSACTION;
    IF (error='0') THEN
        SET cuisine2 = (SELECT CUISINE FROM PLACE_CUISINES WHERE PLACE=place1); /* get cuisine2 if place1 in PLACES already */
        SET valid = (SELECT COUNT(*) FROM CUISINES WHERE CUISINE=cuisine1); /* confirm cuisine1 valid if it exists */
        IF (valid = 0 AND cuisine2 IS NULL) THEN
            SET msg = CONCAT('Cuisine does not exist or ',cuisine1,' is not a valid cuisine');
            SET error = '2';
        ELSEIF (valid = 1 AND cuisine2 IS NOT NULL AND cuisine1 <> cuisine2) THEN
            SET msg = CONCAT(place1,' exists as a ',cuisine2,' not a ',cuisine1,' cuisine');
            SET error = '3';
        ELSEIF (valid = 1 AND cuisine2 IS NULL) THEN
            SET msg = CONCAT('Unable to insert ',place1,', ',cuisine2,' into PLACE_CUISINES');

            INSERT INTO PLACE_CUISINES SET PLACE=place1, CUISINE=cuisine1;
            SET msg2 = CONCAT('Added ',place1,' as ',cuisine1,' to PLACE_CUISINES. ');
        END IF;
    END IF;
    IF (error='0') THEN
        IF (cuisine2 IS NULL) THEN 
            SET cuisine2 = cuisine1; /*setting this just makes the next SELECT statement easier*/
        END IF;
        SET place2 = (SELECT PLACE FROM CAMPUS_PLACES NATURAL JOIN PLACE_CUISINES WHERE CAMPUS=campus1 AND CUISINE=cuisine2);
        IF (place2 IS NOT NULL) THEN
            SET msg = CONCAT(place2,' is already the designated favorite ',cuisine2,' for ',campus1);
            SET error='4';
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
        END IF;
    END IF;
    IF (error='0') THEN
        SET msg = CONCAT('Unable to insert ',place1,' for ',campus1);
  
        INSERT INTO CAMPUS_PLACES SET CAMPUS=campus1, PLACE=place1;
        SET msg = CONCAT(msg2,place1,' has been entered as the favorite ',cuisine2,' at ',campus1);
    END IF;
    COMMIT;
END$$

DELIMITER ;

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
