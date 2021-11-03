
/*1. Create a database called MusicMania. 
a. The DB should have 2 data files (MusicMania.mdf and MusicMania.ndf) created in the 
C:\Temp directory. The .mdf file should have an initial size of 25MB and the .ndf should 
have an initial size of 10MB. Both should grow by 25% and have a maximum size of 
Unlimited (.mdf) and 50MB (.ndf) respectively. 
b. The DB should have 2 log files (MusicMania.ldf and MusicMania2.ldf) created in the 
C:\Temp directory. The first .ldf should have an initial size of 35MB and the second .ldf 
should have an initial size of 15MB. Both files should grow by 5MB at a time and the first 
.ldf should have a maximum size of 10GB and the second file should have a maximum 
size of 300MB. */

USE master
GO
CREATE DATABASE MusicMania
ON
(NAME = MusicMania_data, 
FILENAME = 'C:\Temp Directory\MusicMania_data.mdf',
SIZE = 25MB,
MAXSIZE = UNLIMITED, 
FILEGROWTH = 25%
),

(NAME = MusicMania_data2, 
 FILENAME = 'C:\Temp Directory\MusicMania_data2.ndf',
 SIZE = 10MB, 
 MAXSIZE =50MB, 
 FILEGROWTH = 25%
 )
  LOG ON 
 (NAME = MusicMania_log,
 FILENAME = 'C:\Temp Directory\MusicMania_log.ldf',
 SIZE = 35MB,
 MAXSIZE = 10GB,
 FILEGROWTH = 5MB
);

ALTER DATABASE MusicMania
ADD LOG FILE
(NAME = MusicMania_log2,
FILENAME = 'C:\Temp Directory\MusicMania_log2.ldf',
SIZE = 15MB,
MAXSIZE = 300MB, 
FILEGROWTH = 5MB
)

/* Create four schemas in the MusicMania database called Artists, Music, Labels and Sales. Be 
sure to separate each CREATE SCHEMA command with a GO command. */

USE MusicMania
GO

CREATE SCHEMA Artists 
GO

CREATE SCHEMA Music
GO

CREATE SCHEMA Labels
GO

CREATE SCHEMA Sales
GO

/*Create the following tables in the database. You must choose the best data type to use 
depending on the type of data being stored in each field. You must also assign one of the 
schemas created in step 2 to each table. You can do this either during the CREATE TABLE 
stage or using an ALTER TABLE command. (On the next page). Do NOT create the primary and 
foreign key constraints in the CREATE TABLE definitions. */

CREATE TABLE Artists.Artist (
ArtistID INT IDENTITY NOT NULL, 
FirstName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL, 
BandName NVARCHAR (50) NOT NULL,
AGE SMALLINT,
Email NVARCHAR (25),
DOB DATE NOT NULL
)

ALTER TABLE Artists.Artist
ADD CONSTRAINT DF_Artists_Artist_BandName DEFAULT ('Solo Artist') FOR BandName

CREATE TABLE Artists.ArtistAddress (
ArtistAddressID INT IDENTITY NOT NULL, 
ArtistID INT NOT NULL,
AddressID INT NOT NULL
)

CREATE TABLE Artists.Address (
AddressID INT IDENTITY NOT NULL, 
AddressLine1 VARCHAR(60) NOT NULL, 
AddressLine2 VARCHAR(60) NULL, 
City VARCHAR(20) NOT NULL, 
ProvState VARCHAR(3),
Country VARCHAR(3), 
PostalZipCode VARCHAR(10) 
)

ALTER TABLE Artists.Address
ADD CONSTRAINT DF_Artists_Address_Country DEFAULT ('USA') FOR Country

CREATE TABLE Music.Album (
AlbumID INT IDENTITY NOT NULL, 
Name NVARCHAR(50) NOT NULL, 
Genre VARCHAR(50) NOT NULL, 
ReleaseDate DATE NOT NULL, 
ListPrice SMALLMONEY NOT NULL, 
LabelID INT NOT NULL, 
ArtistID INT NOT NULL
)

ALTER TABLE Music.Album
ADD CONSTRAINT DF_Music_Album_Genre DEFAULT ('Rock') FOR Genre,
    CONSTRAINT DF_Music_Album_ReleaseDate DEFAULT (GETDATE()) FOR ReleaseDate 

CREATE TABLE Music.Song (
SongID INT IDENTITY NOT NULL, 
SongName NVARCHAR(40) NOT NULL, 
SongLength INT NOT NULL,
AlbumID INT NOT NULL
)

CREATE TABLE Labels.Label (
LabelID INT IDENTITY NOT NULL, 
Name NVARCHAR(30) NOT NULL
)

CREATE TABLE Sales.OrderHeader (
OrderID INT IDENTITY NOT NULL, 
OrderDate DATE NOT NULL, 
ShipDate DATE NULL, 
TaxAmount INT NOT NULL, 
PLID INT NOT NULL
)

CREATE TABLE Sales.PurchaseLocation (
PLID INT IDENTITY NOT NULL, 
LocationName NVARCHAR (100) NOT NULL
)

CREATE TABLE Sales.OrderDetail (
OrderDetailID INT IDENTITY NOT NULL, 
OrderQuantity INT NOT NULL, 
SalesPrice SMALLMONEY NOT NULL, 
Discount SMALLMONEY, 
OrderID INT NOT NULL, 
AlbumID INT NOT NULL
)

ALTER TABLE Sales.OrderDetail
ADD CONSTRAINT DF_Sales_OrderDetail_Discount DEFAULT (0.00) FOR Discount

--*4. Create the primary key constraints for all tables as noted in step 3 (PK)ALTER TABLE Artists.Artist
	ADD CONSTRAINT PK_Artists_ArtistID PRIMARY KEY (ArtistID)

ALTER TABLE Artists.ArtistAddress
	ADD CONSTRAINT PK_Artists_ArtistAddressID PRIMARY KEY (ArtistAddressID)

ALTER TABLE Artists.Address
    ADD CONSTRAINT PK_Artists_AddressID PRIMARY KEY (AddressID) 

ALTER TABLE Music.Album
    ADD CONSTRAINT PK_Music_Album_AlbumID PRIMARY KEY (AlbumID) 

ALTER TABLE Music.Song
    ADD CONSTRAINT PK_Music_Song_SongID PRIMARY KEY (SongID)

ALTER TABLE Labels.Label
    ADD CONSTRAINT PK_Labels_Label_LabelID PRIMARY KEY (LabelID)

ALTER TABLE Sales.OrderHeader
    ADD CONSTRAINT PK_Sales_OrderHeader_OrderID PRIMARY KEY (OrderID)
	
ALTER TABLE Sales.PurchaseLocation
    ADD CONSTRAINT PK_Sales_PurchaseLocation_PLID PRIMARY KEY (PLID)

ALTER TABLE Sales.OrderDetail
    ADD CONSTRAINT PK_Sales_OrderDetail_OrderDetailID PRIMARY KEY (OrderDetailID)

/*5. Create the foreign key constraints between the tables to enable data integrity as noted in step 3 
(FK). They are as follows: 

--a. Label.LabelID (PK) -> Album.LabelID (FK)*/ 
ALTER TABLE Music.Album
	ADD CONSTRAINT FK_Music_Album_LabelID FOREIGN KEY (LabelID)
		REFERENCES Labels.Label(LabelID)
		
--b. Artist.ArtistID (PK) -> Album.ArtistID (FK) 
ALTER TABLE Music.Album
	ADD CONSTRAINT FK_Music_Album_ArtistID FOREIGN KEY (ArtistID)
		REFERENCES Artists.Artist(ArtistID)

--c. Artist.ArtistID (PK) -> ArtistAddress.ArtistID (FK) 
ALTER TABLE Artists.ArtistAddress
	ADD CONSTRAINT FK_Artists_ArtistAddress_ArtistID FOREIGN KEY (ArtistID)
		REFERENCES Artists.Artist(ArtistID)

--d. Address.AddressID (PK) -> ArtistAddress.AddressID (FK) 
ALTER TABLE Artists.ArtistAddress
	ADD CONSTRAINT FK_Artists_ArtistAddress_AddressID FOREIGN KEY (AddressID)
		REFERENCES Artists.Address(AddressID)
			   
--e. Album.AlbumID (PK) -> Song.AlbumID (FK) 
ALTER TABLE Music.Song
    ADD CONSTRAINT FK_Music_Song_AlbumID FOREIGN KEY (AlbumID)
	 REFERENCES Music.Album(AlbumID)
	 	 
--f. OrderHeader.OrderID (PK) -> OrderDetail.OrderID (FK) 
ALTER TABLE Sales.OrderDetail
  ADD CONSTRAINT FK_Sales_OrderDetail_OrderID FOREIGN KEY (OrderID)
   REFERENCES Sales.OrderHeader(OrderID)

--g. PurchaseLocation.PLID (PK) -> OrderHeader.PLID (FK) 
ALTER TABLE Sales.OrderHeader 
  ADD CONSTRAINT FK_Sales_OrderHeader_PLID FOREIGN KEY (PLID)
   REFERENCES Sales.PurchaseLocation (PLID)

--h. Album.AlbumID (PK) -> OrderDetail.AlbumID (FK) */ALTER TABLE Sales.OrderDetail  ADD CONSTRAINT FK_Sales_OrderDetail_AlbumID FOREIGN KEY (AlbumID)    REFERENCES Music.Album (AlbumID)/*Create the following CHECK constraints. 
a. Create a check constraint on the OrderDetail table that prevents the OrderQuantity field 
from being less than 0. */
ALTER TABLE Sales.OrderDetail
  ADD CONSTRAINT CK_Sales_OrderDetail_OrderQuantity CHECK (OrderQuantity > 0)

--b. Create a check constraint on the OrderHeader table that prevents the TaxAmount field from being greater than 40%. 
ALTER TABLE Sales.OrderHeader
  ADD CONSTRAINT CK_Sales_OrderHeader_TaxAamount CHECK (TaxAmount <= 40)  --c. Create a check constraint on the Album table that prevents the ReleaseDate field from being set to a date older --then January 1, 1905 and newer then December 31, 2050. */ALTER TABLE Music.Album
  ADD CONSTRAINT CK_Music_Album_ReleaseDate CHECK (ReleaseDate >= '1905-01-01' AND ReleaseDate < '2050-12-31')--7. Create a UNIQUE constraint on the Song.SongName field. Nobody can have the same song names.
ALTER TABLE Music.Song 
 ADD CONSTRAINT UQ_Music_Song_SongName UNIQUE (SongName)

 /*We will need a small amount of sample data to be able to see results of the queries that are 
required for the lab. You may use the GUI to do this step to help speed up the process. This is 
the ONLY step that the GUI is allowed. 
a. Add 3 records into the Label table. 
b. Add 5 records into the Artist table. 
c. Add 5 records into the Address table. 
d. Add 5 records to the ArtistAddress table to associate an artist with an address. 
e. Add 5 records into the Album table. 
f. Add 6 records into the Song table. 
g. Add 2 records to the PurchaseLocation table. 
h. Add 6 records to the OrderHeader table. 
i. Add at least 6 records to the OrderDetail table. 

--GUI was used to add records to the table */

--9. Write a query that shows the all records from the Album table whose release date is between January 1, 2007 and today. SELECT * FROM Music.AlbumWHERE ReleaseDate BETWEEN '2007-01-01' AND GETDATE()--10. Write a query that shows the OrderID and OrderDate from the OrderHeader table whose 
--TaxAmount field is greater than 0. SELECT OrderID, OrderDate
FROM Sales.OrderHeader
WHERE TaxAmount > 0

--11. Write a query that lists all addresses from the Address table whose AddressLine2 field is not NULL. 
SELECT * 
FROM Artists.Address
WHERE AddressLine2 IS NOT NULL

--12.  Write a query that shows the OrderID, OrderDate and ShipDate fields from the OrderHeader table 
--and the AlbumID and SalePrice fields from the OrderDetail table. 

SELECT OH.OrderID, OrderDate, ShipDate, AlbumID, OD.SalesPrice
FROM Sales.OrderHeader AS OH
INNER JOIN Sales.OrderDetail AS OD ON OH.OrderID = OD.OrderID

-- 13. Write a query that shows the artist first and last names from the Artist table and their address 
--from the Address table. SELECT FirstName, LastName, AddressLine1, AddressLine2, City, AA.ProvState, Country, AA.PostalZipCodeFROM Artists.Address AS AAINNER JOIN  Artists.ArtistAddress AS AAA ON AA.AddressID = AAA.AddressIDINNER JOIN Artists.Artist AS ARA ON ARA.ArtistID =AAA.ArtistID--14. Write a query that shows the Name, Genre and ReleaseDate fields from the Album table, the 
--OrderDate field from the OrderHeader table and the SalePrice and Discount fields from the 
--OrderDetail table where the Genre = ‘Rock’. SELECT Name, Genre, ReleaseDate, OrderDate, OD.SalesPrice, Discount FROM Music.Album AS MA INNER JOIN Sales.OrderDetail AS OD ON MA.AlbumID = OD.AlbumIDINNER JOIN Sales.OrderHeader AS OH ON OD.OrderID = OH.OrderIDWHERE Genre = 'Rock'--15. Write a query that lists all address from the Address table whose Country starts with the letter C 
--or whose City is equal to Calgary, Edmonton, Los Angeles or New YorkSELECT *FROM Artists.AddressWHERE Country LIKE 'C%' OR City IN ('Calgary', 'Edmonton', 'Los Angeles', 'New York')/*16. Write a query that lists an artist first and last name combined into one field from the Artist table 
the associated album name from the Album table, label name from the Label table, and song 
name(s) and length from the Song table. */SELECT DISTINCT CONCAT (FirstName, ' ', LastName) AS ArtistName, MA.Name AS AlbumName, LL.Name AS LabelName, SongName, SongLengthFROM Music.Album AS MAINNER JOIN Labels.Label LL ON MA.LabelID = LL.LabelIDINNER JOIN Artists.Artist AS AA ON AA.ArtistID = AA.ArtistIDINNER JOIN Music.Song AS MS ON MS.AlbumID = MA.AlbumID--17. Write an UPDATE statement on the Album table that adds 10% to the SalesPrice field who’s Genre is not ROCK. UPDATE Sales.OrderDetailSET SalesPrice = ListPrice*0.10FROM Sales.OrderDetail AS ODINNER JOIN Music.Album AS MA ON OD.AlbumID = MA.AlbumIDWHERE Genre != 'Rock'--18. Convert the queries you wrote in steps 14 and 15 into views. Ensure that the view definitions are encryptedCREATE VIEW VW_TASK14WITH ENCRYPTION AS SELECT Name, Genre, ReleaseDate, OrderDate, OD.SalesPrice, Discount FROM Music.Album AS MA INNER JOIN Sales.OrderDetail AS OD ON MA.AlbumID = OD.AlbumIDINNER JOIN Sales.OrderHeader AS OH ON OD.OrderID = OH.OrderIDWHERE Genre = 'Rock'CREATE VIEW VW_TASK15  WITH ENCRYPTION AS SELECT *FROM Artists.AddressWHERE Country LIKE 'C%' OR City IN ('Calgary', 'Edmonton', 'Los Angeles', 'New York')