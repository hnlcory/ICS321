/********************************************************************************/
/*																				*/
/*	Kroenke and Auer - Database Concepts (7th Edition) Chapter 03				*/
/*																				*/
/*  Garden Glory Database Data													*/
/*																				*/
/*	These are the MYSQL 5.6 SQL code solutions									*/
/*																				*/
/********************************************************************************/

# Note that null is entered for auto_increment fields

/*****   OWNER DATA   ***********************************************************/

INSERT INTO OWNER VALUES(
	null,'Mary Jones', 'Mary.Jones@somewhere.com', 'Individual');
INSERT INTO OWNER VALUES(
	null,'DT Enterprises', 'DTE@dte.com', 'Corporation');
INSERT INTO OWNER VALUES(
	null,'Sam Douglas', 'Sam.Douglas@somewhere.com', 'Individual');
INSERT INTO OWNER VALUES(
	null,'UNY Enterprises', 'UNYE@unye.com', 'Corporation');
INSERT INTO OWNER VALUES(
	null,'Doug Samuels', 'Doug.Samuels@somewhere.com', 'Individual');

-- SELECT * FROM OWNER;

/*****   PROPERTY   *************************************************************/

INSERT INTO OWNED_PROPERTY VALUES(
	null,'Eastlake Building', 'Office', '123 Eastlake', 'Seattle', 'WA', '98119', 2);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Elm St Apts', 'Apartments', '4 East Elm', 'Lynwood', 'WA', '98223', 1);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Jefferson Hill', 'Office', '42 West 7th St', 'Bellevue', 'WA', '98007', 2);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Lake View Apts', 'Apartments', '1265 32nd Avenue', 'Redmond', 'WA', '98052', 3);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Kodak Heights Apts', 'Apartments', '65 32nd Avenue', 'Redmond', 'WA', '98052', 4);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Jones House', 'Private Residence', '1456 48th St', 'Bellevue', 'WA', '98007', 1);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Douglas House', 'Private Residence', '1567 51st St', 'Bellevue', 'WA', '98007', 3);
INSERT INTO OWNED_PROPERTY VALUES(
	null,'Samuels House', 'Private Residence', '567 151st St', 'Redmond', 'WA', '98052', 5);

-- SELECT * FROM OWNED_PROPERTY;

/*****   EMPLOYEE   *************************************************************/

INSERT INTO EMPLOYEE VALUES(
	null,'Smith', 'Sam', '206-254-1234', 'Master');
INSERT INTO EMPLOYEE VALUES(
	null,'Evanston', 'John','206-254-2345', 'Senior');
INSERT INTO EMPLOYEE VALUES(
	null,'Murray', 'Dale', '425-545-7654', 'Junior');
INSERT INTO EMPLOYEE VALUES(
	null,'Murphy', 'Jerry', '425-545-8765', 'Master');
INSERT INTO EMPLOYEE VALUES(
	null,'Fontaine', 'Joan', '206-254-3456', 'Senior');

-- SELECT * FROM EMPLOYEE;

/*****   GG_SERVICE   **************************************************************/

INSERT INTO GG_SERVICE VALUES(null,'Mow Lawn', 25.00);
INSERT INTO GG_SERVICE VALUES(null,'Plant Annuals', 25.00);
INSERT INTO GG_SERVICE VALUES(null,'Weed Garden', 30.00);
INSERT INTO GG_SERVICE VALUES(null,'Trim Hedge', 45.00);
INSERT INTO GG_SERVICE VALUES(null,'Prune Small Tree', 60.00);
INSERT INTO GG_SERVICE VALUES(null,'Trim Medium Tree',100.00);
INSERT INTO GG_SERVICE VALUES(null,'Trim Large Tree', 125.00);


-- SELECT * FROM GG_SERVICE;

/*****   PROPERTY_SERVICE   **************************************************************/

INSERT INTO PROPERTY_SERVICE VALUES(null,1, 2, '2014-05-05', 1, 4.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,3, 2, '2014-05-08', 3, 4.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,2, 1, '2014-05-08', 2, 2.75);
INSERT INTO PROPERTY_SERVICE VALUES(null,6, 1, '2014-05-10', 5, 2.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,5, 4, '2014-05-12', 4, 7.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,8, 1, '2014-05-15', 4, 2.75);
INSERT INTO PROPERTY_SERVICE VALUES(null,4, 4, '2014-05-19', 1, 1.00);
INSERT INTO PROPERTY_SERVICE VALUES(null,7, 1, '2014-05-21', 2, 2.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,6, 3, '2014-06-03', 5, 2.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,5, 7, '2014-06-08', 4, 10.50);
INSERT INTO PROPERTY_SERVICE VALUES(null,8, 3, '2014-06-12', 4, 2.75);
INSERT INTO PROPERTY_SERVICE VALUES(null,4, 5, '2014-06-15', 1, 5.00);
INSERT INTO PROPERTY_SERVICE VALUES(null,7, 3, '2014-06-19', 2, 4.00);




-- SELECT * FROM PROPERTY_SERVICE;







/****************************************************************************************/
