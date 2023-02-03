CREATE TABLE `EMPLOYEE` (
 `EmployeeID` int(11) NOT NULL AUTO_INCREMENT,
 `LastName` varchar(25) NOT NULL,
 `FirstName` varchar(25) NOT NULL,
 `CellPhone` varchar(12) NOT NULL,
 `ExperienceLevel` varchar(15) NOT NULL,
 PRIMARY KEY (`EmployeeID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1

GG_SERVICE	CREATE TABLE `GG_SERVICE` (
 `ServiceID` int(11) NOT NULL AUTO_INCREMENT,
 `ServiceDescription` varchar(100) NOT NULL,
 `CostPerHour` decimal(6,2) DEFAULT NULL,
 PRIMARY KEY (`ServiceID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1

OWNED_PROPERTY	CREATE TABLE `OWNED_PROPERTY` (
 `PropertyID` int(11) NOT NULL AUTO_INCREMENT,
 `PropertyName` varchar(50) NOT NULL,
 `PropertyType` varchar(50) NOT NULL,
 `Street` varchar(35) NOT NULL,
 `City` varchar(35) NOT NULL,
 `State` varchar(2) NOT NULL,
 `Zip` varchar(10) NOT NULL,
 `OwnerID` int(11) NOT NULL,
 PRIMARY KEY (`PropertyID`),
 KEY `OwnerID` (`OwnerID`),
 CONSTRAINT `OWNED_PROPERTY_ibfk_1` FOREIGN KEY (`OwnerID`) REFERENCES `OWNER` (`OwnerID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1

OWNER	CREATE TABLE `OWNER` (
 `OwnerID` int(11) NOT NULL AUTO_INCREMENT,
 `OwnerName` varchar(50) NOT NULL,
 `OwnerEmail` varchar(100) NOT NULL,
 `OwnerType` varchar(12) NOT NULL,
 PRIMARY KEY (`OwnerID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1

PROPERTY_SERVICE	CREATE TABLE `PROPERTY_SERVICE` (
 `PropertyServiceID` int(11) NOT NULL AUTO_INCREMENT,
 `PropertyID` int(11) NOT NULL,
 `ServiceID` int(11) NOT NULL,
 `ServiceDate` date NOT NULL,
 `EmployeeID` int(11) NOT NULL,
 `HoursWorked` decimal(4,2) DEFAULT NULL,
 PRIMARY KEY (`PropertyServiceID`),
 KEY `EmployeeID` (`EmployeeID`),
 KEY `PropertyID` (`PropertyID`),
 KEY `ServiceID` (`ServiceID`),
 CONSTRAINT `PROPERTY_SERVICE_ibfk_1` FOREIGN KEY (`EmployeeID`) REFERENCES `EMPLOYEE` (`EmployeeID`) ON UPDATE CASCADE,
 CONSTRAINT `PROPERTY_SERVICE_ibfk_2` FOREIGN KEY (`PropertyID`) REFERENCES `OWNED_PROPERTY` (`PropertyID`) ON UPDATE CASCADE,
 CONSTRAINT `PROPERTY_SERVICE_ibfk_3` FOREIGN KEY (`ServiceID`) REFERENCES `GG_SERVICE` (`ServiceID`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1