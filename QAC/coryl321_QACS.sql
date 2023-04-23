-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 23, 2023 at 01:23 PM
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
-- Database: `coryl321_QACS`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`coryl321`@`localhost` PROCEDURE `ADD_SALE` (IN `customer_id` INT, IN `employee_id` INT, IN `sale_date` DATE, IN `item_id` INT, IN `tax_rate` DECIMAL(6,3), INOUT `sale_id` INT, OUT `sub_total` DECIMAL(8,2), OUT `total` DECIMAL(8,2), OUT `err` INT, OUT `msg` VARCHAR(500))   BEGIN
/* customer_id, employee_id, sale_date, item_id, tax_rate, sale_id, sub_total, total, err, msg */
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET msg=CONCAT(msg,' (c=',customer_id,',e=',employee_id,',d=',sale_date,',s=',sale_id,',i=',item_id,')');
        SET msg=CONCAT(msg, ' ROLL BACK - new invoice not started');
    END;
    SET err = 0;
    SET msg = '';
    IF(customer_id>0 AND employee_id>0) THEN
        SET err = 99;
		SET msg = CONCAT('Error 99 inserting SALE. CustomerID: ',customer_id,' or EmployeeID: ',employee_id,' does not exist.');
/* insert new sale into SALE table */    
        INSERT INTO SALE (CustomerID, EmployeeID, SaleDate) VALUES (customer_id,employee_id,sale_date);
/* retrieve auto-incremented SaleID field after insert*/    
        SET sale_id = (SELECT LAST_INSERT_ID()); /* shit doesnt work SELECT LAST_INSERT_ID() */
        SET err = 0;
        SET msg = '';    
    END IF;
/* get item price from ITEM table */
    SET @itemPrice = (SELECT ItemPrice FROM ITEM WHERE ItemID=item_id); /* replace SELECT 0 */
    IF(@itemPrice IS NULL) THEN
        SET err = 66;
		SET msg = CONCAT('Error 66 Item ',item_id,' does not exist.');
    ELSE
        SET err = 44;
		SET msg = CONCAT('Error 44 SaleID ',sale_id,' does not exist.');
/* insert item into SALE_ITEM table */
        INSERT INTO SALE_ITEM (SaleID, ItemID, ItemPrice) VALUES (sale_id,item_id,@itemPrice);
        SET err = 0;
        SET msg = '';
        SET sub_total = (SELECT SUM(ItemPrice) FROM SALE_ITEM WHERE SaleID=sale_id); /* replace SELECT 0 */
        SET @tax = sub_total * (tax_rate / 100);
        SET total = sub_total + @tax;
/* update sub_total, tax and total in SALE record  */
       	UPDATE SALE SET SubTotal=sub_total,Tax=@tax, Total=total WHERE SaleID=sale_id; 
        SET msg = CONCAT(msg,' Sale: ',sale_id,' SubTotal: ',FORMAT(sub_total,2),', Tax: ',FORMAT(@tax,3),', Total: ',FORMAT(total,2),' updated.');
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `CUSTOMER`
--

CREATE TABLE `CUSTOMER` (
  `CustomerID` int(11) NOT NULL,
  `LastName` varchar(25) NOT NULL DEFAULT '',
  `FirstName` varchar(25) NOT NULL DEFAULT '',
  `Address` varchar(35) NOT NULL DEFAULT '',
  `ZIP` varchar(10) NOT NULL DEFAULT '',
  `Phone` varchar(12) NOT NULL DEFAULT '',
  `Email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `CUSTOMER`
--

INSERT INTO `CUSTOMER` (`CustomerID`, `LastName`, `FirstName`, `Address`, `ZIP`, `Phone`, `Email`) VALUES
(1, 'Shire', 'Robert', '6225 Evanston Ave N', '98103', '206-524-2433', 'Robert.Shire@somewhere.com'),
(2, 'Goodyear', 'Katherine', '7335 11th Ave NE', '98105', '206-524-3544', 'Katherine.Goodyear@somewhere.com'),
(3, 'Bancroft', 'Chris', '12605 NE 6th Street', '98005', '425-635-9788', 'Chris.Bancroft@somewhere.com'),
(4, 'Griffith', 'John', '335 Aloha Street', '98109', '206-524-4655', 'John.Griffith@somewhere.com'),
(5, 'Tierney', 'Doris', '14510 NE 4th Street', '98005', '425-635-8677', 'Doris.Tierney@somewhere.com'),
(6, 'Anderson', 'Donna', '1410 Hillcrest Parkway', '98273', '360-538-7566', 'Donna.Anderson@elsewhere.com'),
(7, 'Svane', 'Jack', '3211 42nd Street', '98115', '206-524-5766', 'Jack.Svane@somewhere.com'),
(8, 'Walsh', 'Denesha', '6712 24th Avenue NE', '98053', '425-635-7566', 'Denesha.Walsh@somewhere.com'),
(9, 'Enquist', 'Craig', '534 15th Street', '98225', '360-538-6455', 'Craig.Enquist@elsewhere.com'),
(10, 'Anderson', 'Rose', '6823 17th Ave NE', '98105', '206-524-6877', 'Rose.Anderson@elsewhere.com');

-- --------------------------------------------------------

--
-- Table structure for table `EMPLOYEE`
--

CREATE TABLE `EMPLOYEE` (
  `EmployeeID` int(11) NOT NULL,
  `LastName` varchar(25) NOT NULL DEFAULT '',
  `FirstName` varchar(25) NOT NULL DEFAULT '',
  `Phone` varchar(12) NOT NULL DEFAULT '',
  `Email` varchar(100) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `EMPLOYEE`
--

INSERT INTO `EMPLOYEE` (`EmployeeID`, `LastName`, `FirstName`, `Phone`, `Email`) VALUES
(1, 'Stuart', 'Anne', '206-527-0010', 'Anne.Stuart@QACS.com'),
(2, 'Stuart', 'George', '206-527-0011', 'George.Stuart@QACS.com'),
(3, 'Stuart', 'Mary', '206-527-0012', 'Mary.Stuart@QACS.com'),
(4, 'Orange', 'William', '206-527-0013', 'William.Orange@QACS.com'),
(5, 'Griffith', 'John', '206-527-0014', 'John.Griffith@QACS.com');

-- --------------------------------------------------------

--
-- Table structure for table `ITEM`
--

CREATE TABLE `ITEM` (
  `ItemID` int(11) NOT NULL,
  `ItemDescription` varchar(255) NOT NULL,
  `PurchaseDate` date NOT NULL,
  `ItemCost` decimal(9,2) NOT NULL,
  `ItemPrice` decimal(9,2) NOT NULL,
  `VendorID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ITEM`
--

INSERT INTO `ITEM` (`ItemID`, `ItemDescription`, `PurchaseDate`, `ItemCost`, `ItemPrice`, `VendorID`) VALUES
(1, 'Antique Desk', '2013-11-07', 1800.00, 3000.00, 2),
(2, 'Antique Desk Chair', '2013-11-10', 300.00, 500.00, 4),
(3, 'Dining Table Linens', '2013-11-14', 600.00, 1000.00, 1),
(4, 'Candles', '2013-11-14', 30.00, 50.00, 1),
(5, 'Candles', '2013-11-14', 27.00, 45.00, 1),
(6, 'Desk Lamp', '2013-11-14', 150.00, 250.00, 3),
(7, 'Dining Table Linens', '2013-11-14', 450.00, 750.00, 1),
(8, 'Book Shelf', '2013-11-21', 150.00, 250.00, 5),
(9, 'Antique Chair', '2013-11-21', 750.00, 1250.00, 6),
(10, 'Antique Chair', '2013-11-21', 1050.00, 1750.00, 6),
(11, 'Antique Candle Holders', '2013-11-28', 210.00, 350.00, 2),
(12, 'Antique Desk', '2014-01-05', 1920.00, 3200.00, 2),
(13, 'Antique Desk', '2014-01-05', 2100.00, 3500.00, 2),
(14, 'Antique Desk Chair', '2014-01-06', 285.00, 475.00, 9),
(15, 'Antique Desk Chair', '2014-01-06', 339.00, 565.00, 9),
(16, 'Desk Lamp', '2014-01-06', 150.00, 250.00, 10),
(17, 'Desk Lamp', '2014-01-06', 150.00, 250.00, 10),
(18, 'Desk Lamp', '2014-01-06', 144.00, 240.00, 3),
(19, 'Antique Dining Table', '2014-01-10', 3000.00, 5000.00, 7),
(20, 'Antique Sideboard', '2014-01-11', 2700.00, 4500.00, 8),
(21, 'Dining Table Chairs', '2014-01-11', 5100.00, 8500.00, 9),
(22, 'Dining Table Linens', '2014-01-12', 450.00, 750.00, 1),
(23, 'Dining Table Linens', '2014-01-12', 480.00, 800.00, 1),
(24, 'Candles', '2014-01-17', 30.00, 50.00, 1),
(25, 'Candles', '2014-01-17', 36.00, 60.00, 1);

-- --------------------------------------------------------

--
-- Table structure for table `SALE`
--

CREATE TABLE `SALE` (
  `SaleID` int(11) NOT NULL,
  `CustomerID` int(11) NOT NULL,
  `EmployeeID` int(11) NOT NULL,
  `SaleDate` date NOT NULL,
  `SubTotal` decimal(15,2) DEFAULT NULL,
  `Tax` decimal(15,2) DEFAULT NULL,
  `Total` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `SALE`
--

INSERT INTO `SALE` (`SaleID`, `CustomerID`, `EmployeeID`, `SaleDate`, `SubTotal`, `Tax`, `Total`) VALUES
(1, 1, 1, '2013-12-14', 3500.00, 290.50, 3790.50),
(2, 2, 1, '2013-12-15', 1000.00, 83.00, 1083.00),
(3, 3, 1, '2013-12-15', 50.00, 4.15, 54.15),
(4, 4, 3, '2013-12-23', 45.00, 3.74, 48.74),
(5, 1, 5, '2014-01-05', 250.00, 20.75, 270.75),
(6, 5, 5, '2014-01-10', 750.00, 62.25, 812.25),
(7, 6, 4, '2014-01-12', 250.00, 20.75, 270.75),
(8, 2, 1, '2014-01-15', 3000.00, 249.00, 3249.00),
(9, 5, 5, '2014-01-25', 350.00, 29.05, 379.05),
(10, 7, 1, '2014-02-04', 14250.00, 1182.75, 15432.75),
(11, 8, 5, '2014-02-04', 250.00, 20.75, 270.75),
(12, 5, 4, '2014-02-07', 50.00, 4.15, 54.15),
(13, 9, 2, '2014-02-07', 4500.00, 373.50, 4873.50),
(14, 10, 3, '2014-02-11', 3675.00, 305.03, 3980.03),
(15, 2, 2, '2014-02-11', 800.00, 66.40, 866.40);

-- --------------------------------------------------------

--
-- Table structure for table `SALE_ITEM`
--

CREATE TABLE `SALE_ITEM` (
  `SaleID` int(11) NOT NULL,
  `SaleItemID` int(11) NOT NULL DEFAULT '1',
  `ItemID` int(11) NOT NULL,
  `ItemPrice` decimal(9,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `SALE_ITEM`
--

INSERT INTO `SALE_ITEM` (`SaleID`, `SaleItemID`, `ItemID`, `ItemPrice`) VALUES
(1, 1, 1, 3000.00),
(1, 2, 2, 500.00),
(2, 1, 3, 1000.00),
(3, 1, 4, 50.00),
(4, 1, 5, 45.00),
(5, 1, 6, 250.00),
(6, 1, 7, 750.00),
(7, 1, 8, 250.00),
(8, 1, 9, 1250.00),
(8, 2, 10, 1750.00),
(9, 1, 11, 350.00),
(10, 1, 19, 5000.00),
(10, 2, 21, 8500.00),
(10, 3, 22, 750.00),
(11, 1, 17, 250.00),
(12, 1, 24, 50.00),
(13, 1, 20, 4500.00),
(14, 1, 12, 3200.00),
(14, 2, 14, 475.00),
(15, 1, 23, 800.00);

--
-- Triggers `SALE_ITEM`
--
DELIMITER $$
CREATE TRIGGER `SET_SaleItemID` BEFORE INSERT ON `SALE_ITEM` FOR EACH ROW BEGIN
    SET @maxSaleItemID = (SELECT MAX(SaleItemID) FROM SALE_ITEM WHERE SaleID=NEW.SaleID);
    IF(@maxSaleItemID IS NOT NULL) THEN
        SET NEW.SaleItemID = @maxSaleItemID + 1;
    ELSE
    	SET NEW.SaleItemID = 1;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `VENDOR`
--

CREATE TABLE `VENDOR` (
  `VendorID` int(11) NOT NULL,
  `CompanyName` varchar(100) NOT NULL DEFAULT '',
  `ContactLastName` varchar(25) NOT NULL DEFAULT '',
  `ContactFirstName` varchar(25) NOT NULL DEFAULT '',
  `Address` varchar(35) NOT NULL DEFAULT '',
  `ZIP` varchar(10) NOT NULL DEFAULT '',
  `Phone` varchar(12) NOT NULL DEFAULT '',
  `Fax` varchar(12) NOT NULL DEFAULT '',
  `Email` varchar(100) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `VENDOR`
--

INSERT INTO `VENDOR` (`VendorID`, `CompanyName`, `ContactLastName`, `ContactFirstName`, `Address`, `ZIP`, `Phone`, `Fax`, `Email`) VALUES
(1, 'Linens and Things', 'Huntington', 'Anne', '1515 NW Market Street', '98107', '206-325-6755', '206-329-9675', 'LAT@business.com'),
(2, 'European Specialties', 'Tadema', 'Ken', '6123 15th Avenue NW', '98107', '206-325-7866', '206-329-9786', 'ES@business.com'),
(3, 'Lamps and Lighting', 'Swanson', 'Sally', '506 Prospect Street', '98109', '206-325-8977', '206-329-9897', 'LAL@business.com'),
(4, '', 'Lee', 'Andrew', '1102 3rd Street', '98033', '425-746-5433', '', 'Andrew.Lee@somewhere.com'),
(5, '', 'Harrison', 'Denise', '533 10th Avenue', '98033', '425-746-4322', '', 'Denise.Harrison@somewhere.com'),
(6, 'New York Brokerage', 'Smith', 'Mark', '621 Roy Street', '98109', '206-325-9088', '206-329-9908', 'NYB@business.com'),
(7, '', 'Walsh', 'Denesha', '6712 24th Avenue NE', '98053', '425-635-7566', '', 'Denesha.Walsh@somewhere.com'),
(8, '', 'Bancroft', 'Chris', '12605 NE 6th Street', '98005', '425-635-9788', '425-639-9978', 'Chris.Bancroft@somewhere.com'),
(9, 'Specialty Antiques', 'Nelson', 'Fred', '2512 Lucky Street', '94110', '415-422-2121', '415-429-9212', 'SA@business.com'),
(10, 'General Antiques', 'Garner', 'Patty', '2515 Lucky Street', '94110', '415-422-3232', '415-429-9323', 'GA@business.com');

-- --------------------------------------------------------

--
-- Table structure for table `ZIPCODE`
--

CREATE TABLE `ZIPCODE` (
  `City` varchar(35) NOT NULL,
  `State` varchar(2) NOT NULL,
  `ZIP` varchar(10) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ZIPCODE`
--

INSERT INTO `ZIPCODE` (`City`, `State`, `ZIP`) VALUES
('San Francisco', 'CA', '94110'),
('Bellevue', 'WA', '98005'),
('Kirkland', 'WA', '98033'),
('Redmond', 'WA', '98053'),
('Seattle', 'WA', '98103'),
('Seattle', 'WA', '98105'),
('Seattle', 'WA', '98107'),
('Seattle', 'WA', '98109'),
('Seattle', 'WA', '98115'),
('Bellingham', 'WA', '98225'),
('Mt. Vernon', 'WA', '98273');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `CUSTOMER`
--
ALTER TABLE `CUSTOMER`
  ADD PRIMARY KEY (`CustomerID`),
  ADD KEY `ZIP` (`ZIP`);

--
-- Indexes for table `EMPLOYEE`
--
ALTER TABLE `EMPLOYEE`
  ADD PRIMARY KEY (`EmployeeID`);

--
-- Indexes for table `ITEM`
--
ALTER TABLE `ITEM`
  ADD PRIMARY KEY (`ItemID`),
  ADD KEY `VendorID` (`VendorID`);

--
-- Indexes for table `SALE`
--
ALTER TABLE `SALE`
  ADD PRIMARY KEY (`SaleID`),
  ADD KEY `CustomerID` (`CustomerID`),
  ADD KEY `EmployeeID` (`EmployeeID`);

--
-- Indexes for table `SALE_ITEM`
--
ALTER TABLE `SALE_ITEM`
  ADD PRIMARY KEY (`SaleID`,`SaleItemID`),
  ADD KEY `ItemID` (`ItemID`);

--
-- Indexes for table `VENDOR`
--
ALTER TABLE `VENDOR`
  ADD PRIMARY KEY (`VendorID`),
  ADD KEY `ZIP` (`ZIP`);

--
-- Indexes for table `ZIPCODE`
--
ALTER TABLE `ZIPCODE`
  ADD PRIMARY KEY (`ZIP`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `CUSTOMER`
--
ALTER TABLE `CUSTOMER`
  MODIFY `CustomerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `EMPLOYEE`
--
ALTER TABLE `EMPLOYEE`
  MODIFY `EmployeeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ITEM`
--
ALTER TABLE `ITEM`
  MODIFY `ItemID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `SALE`
--
ALTER TABLE `SALE`
  MODIFY `SaleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `VENDOR`
--
ALTER TABLE `VENDOR`
  MODIFY `VendorID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `CUSTOMER`
--
ALTER TABLE `CUSTOMER`
  ADD CONSTRAINT `CUSTOMER_ibfk_1` FOREIGN KEY (`ZIP`) REFERENCES `ZIPCODE` (`ZIP`);

--
-- Constraints for table `ITEM`
--
ALTER TABLE `ITEM`
  ADD CONSTRAINT `ITEM_ibfk_1` FOREIGN KEY (`VendorID`) REFERENCES `VENDOR` (`VendorID`);

--
-- Constraints for table `SALE`
--
ALTER TABLE `SALE`
  ADD CONSTRAINT `SALE_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `CUSTOMER` (`CustomerID`),
  ADD CONSTRAINT `SALE_ibfk_2` FOREIGN KEY (`EmployeeID`) REFERENCES `EMPLOYEE` (`EmployeeID`);

--
-- Constraints for table `SALE_ITEM`
--
ALTER TABLE `SALE_ITEM`
  ADD CONSTRAINT `SALE_ITEM_ibfk_1` FOREIGN KEY (`ItemID`) REFERENCES `ITEM` (`ItemID`),
  ADD CONSTRAINT `SALE_ITEM_ibfk_2` FOREIGN KEY (`SaleID`) REFERENCES `SALE` (`SaleID`);

--
-- Constraints for table `VENDOR`
--
ALTER TABLE `VENDOR`
  ADD CONSTRAINT `VENDOR_ibfk_1` FOREIGN KEY (`ZIP`) REFERENCES `ZIPCODE` (`ZIP`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
