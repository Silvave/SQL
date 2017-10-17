--Problem 1-6
CREATE TABLE Minions (
	Id int NOT NULL PRIMARY KEY,
	Name varchar(20) NOT NULL,
	Age int
)

CREATE TABLE Towns (
	Id int NOT NULL PRIMARY KEY,
	Name varchar(20) NOT NULL
)

ALTER TABLE Minions
ADD TownId int NOT NULL FOREIGN KEY REFERENCES Minions.dbo.Towns (Id)


INSERT dbo.Towns VALUES (1, 'Sofia')
INSERT dbo.Towns VALUES (2, 'Plovdiv')
INSERT dbo.Towns VALUES (3, 'Varna')


INSERT dbo.Minions VALUES (1, 'Kevin', 22, 1)
INSERT dbo.Minions VALUES (2, 'Bob', 15, 3)
INSERT dbo.Minions VALUES (3, 'Steward', null, 2)


--UPDATE Minions
--SET Age = 15
--WHERE Name = 'Bob'

TRUNCATE TABLE Minions

DROP TABLE Minions


--Problem 7.
CREATE TABLE People (
	Id int IDENTITY(1,1) PRIMARY KEY, --Add Constrain for max people
	Name nvarchar(200) NOT NULL,
	Picture varbinary(max),
	Height float, --Maybe scale should be more than ten
	Weight float, --Maybe scale should be more than ten
	Gender char(1) NOT NULL, --Add posible states (m/f)
	Birthdate DATE NOT NULL,
	Biography nvarchar(max)
)


INSERT INTO People(Name, Picture, Height, Weight, Gender, Birthdate, Biography)
 VALUES ('Todor', null, 1.80, 78, 'm', '1991-02-17', 'I am Robot')
INSERT INTO People VALUES ('Marina', null, 1.81, 65, 'f', '1992-02-05', 'I am Aniram')
INSERT INTO People VALUES ('Maria', null, 1.75, 95, 'f', '1967-03-01', 'I am Airam')
INSERT INTO People VALUES ('Kosta', null, 1.82, 105, 'm', '1960-07-04', 'I am Atsok')
INSERT INTO People VALUES ('Marinka', null, 1.80, 78, 'f', '1900-03-02', 'I am Akniram')


--Problem 8-12
CREATE TABLE Users 
(
Id bigint identity(1,1) primary key,
Username varchar(30) not null,
Password varchar(26) not null,
ProfilePicture varbinary(900),
LastLoginTime datetime,
IsDeleted bit
)


INSERT INTO Users(Username, Password, ProfilePicture, IsDeleted)
VALUES ('Todor', '12345', null, 1)

INSERT INTO Users(Username, Password, ProfilePicture, IsDeleted)
VALUES ('Alisa', '12345', null, 1)

INSERT INTO Users(Username, Password, ProfilePicture, IsDeleted)
VALUES ('Monika', '12345', null, 0)

INSERT INTO Users(Username, Password, ProfilePicture, IsDeleted)
VALUES ('Pesho', '12345', null, 1)

INSERT INTO Users(Username, Password, ProfilePicture, IsDeleted)
VALUES ('Raa', '12341232', null, 1)


ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC075DD733FF]

ALTER TABLE Users
ADD CONSTRAINT PK_UserId
PRIMARY KEY (Id, Username)


ALTER TABLE Users
ADD CONSTRAINT CheckMinPass
CHECK(LEN(Password) >= 5)


ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime


ALTER TABLE Users
DROP CONSTRAINT PK_UserId


ALTER TABLE Users
ADD CONSTRAINT PK_Id
PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CheckUsername
CHECK (LEN(Username) >= 3)


--Problem 13. Movies Database
CREATE DATABASE Movies
USE Movies


CREATE TABLE Directors 
(
Id INT IDENTITY PRIMARY KEY,
DirectorName nvarchar(10) CHECK(LEN(DirectorName) >= 3),
Notes nvarchar(4000)
)

CREATE TABLE Genres 
(
Id INT IDENTITY PRIMARY KEY,
GenreName varchar(10) NOT NULL,
Notes nvarchar(400)
)

CREATE TABLE Categories 
(
Id INT IDENTITY PRIMARY KEY,
CategoryName varchar(10) NOT NULL,
Notes nvarchar(400)
)

CREATE TABLE Movies 
(
Id INT IDENTITY PRIMARY KEY,
Title nvarchar(30) NOT NULL,
DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
CopyrightYear DATE NOT NULL,
Lenght varchar(10),
GenreId INT FOREIGN KEY REFERENCES Genres(Id),
CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
Rating int,
Notes varchar(4000)
)

INSERT INTO Directors VALUES ('Pesho', 'Mega good')
INSERT INTO Directors VALUES ('Misho', 'Bad camerashots')
INSERT INTO Directors VALUES ('Stamat', 'Too simple')
INSERT INTO Directors VALUES ('Gosho', 'Urban footage')
INSERT INTO Directors VALUES ('Mitko', 'Best at sellout')

INSERT INTO Categories VALUES ('Action', 'Most watched')
INSERT INTO Categories VALUES ('Sci-fi', 'For nurdes')
INSERT INTO Categories VALUES ('Drama', 'For girls')
INSERT INTO Categories VALUES ('Romance', 'For girly girls')
INSERT INTO Categories VALUES ('Adventure', 'For everyone')

INSERT INTO Genres VALUES ('Thriller', 'Keeps you in suspense')
INSERT INTO Genres VALUES ('Horror', 'It is not for people below 18')
INSERT INTO Genres VALUES ('Animation', 'For weeboos')
INSERT INTO Genres VALUES ('War film', 'Not for everyone')
INSERT INTO Genres VALUES ('Action', 'If you want to be entertained')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES ('Here and there', 2, '2017-01-30', '1:30', 1, 1, 8, 'This film have a golden globe for something')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES ('For what', 5, '2016-11-21', '2:46', 4, 3, 9, 'Best film of 2016')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES ('Best, normal, bad', 4, '2016-09-11', '1:22', 5, 5, 7, 'A normal film of the best bad quality')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES ('Beach', 3, '2015-03-07', '3:14', 3, 4, 9.1, 'Weeboo stuff')

INSERT INTO Movies(Title, DirectorId, CopyrightYear, Lenght, GenreId, CategoryId, Rating, Notes)
VALUES ('Wood', 1, '2014-12-21', '1:14', 2, 2, 9.3, 'Two teenagers go to a cabin in the woods to celebrate Chrismas but something happens')

--Problem 14. Car rental database
CREATE DATABASE CarRental
USE CarRental

CREATE TABLE Categories
(
Id INT IDENTITY(1,1) PRIMARY KEY,
CategoryName varchar(10) NOT NULL,
DailyRate int NOT NULL,
WeeklyRate int NOT NULL,
MonthlyRate int NOT NULL,
WeekendRate int NOT NULL
)

CREATE TABLE Cars 
(
Id INT IDENTITY(1,1) PRIMARY KEY,
PlateNumber BIGINT NOT NULL,
Manufacturer varchar(30) NOT NULL,
Model varchar(10) NOT NULL,
CarYear DATE NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
Doors tinyint,
Picture varbinary(max),
Condition varchar(30),
Available varchar(10) NOT NULL
)

CREATE TABLE Employees
(
Id INT IDENTITY(1,1) PRIMARY KEY,
Firstname nvarchar(15) NOT NULL,
LastName nvarchar(20) NOT NULL,
Title nvarchar(10),
Notes varchar(100)
)

CREATE TABLE Customers 
(
Id INT IDENTITY(1,1) PRIMARY KEY,
DriverLicenceNumber BIGINT NOT NULL,
FullName nvarchar(50) NOT NULL,
[Address] nvarchar(100) NOT NULL,
City nvarchar(15) NOT NULL,
ZIPCode smallint,
Notes varchar(100)
)

CREATE TABLE RentalOrders 
(
Id INT IDENTITY(1,1) PRIMARY KEY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL,
CarId INT FOREIGN KEY REFERENCES Cars(Id) NOT NULL,
TankLevel TINYINT,
KilometrageStart SMALLINT,
KilometrageEnd SMALLINT,
TotalKilometrage SMALLINT,
StartDate DATE,
EndDate DATE,
TotalDays smallint,
RateApplied INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
TaxRate int,
OrderStatus varchar(10),
Notes varchar(300)
)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES ('A', 100, 70, 50, 90)
INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES ('B', 110, 80, 60, 100)
INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES ('C', 120, 90, 70, 110)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES (34753281345235, 'Mercedeees', 'comby', '2015-02-01', 1, 4, null, 'good', 'YES')
INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES (14724526475342, 'BMV', 'sport', '2011-03-01', 2, 2, null, 'very good', 'YES')
INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available)
VALUES (236415245215, 'Honda', 'hatchback', '2013-12-01', 3, 4, null, 'not very good', 'NO')

INSERT INTO Employees(Firstname, LastName, Title, Notes)
VALUES ('Pesho', 'Georgiev', 'The rench', 'Very hard working')
INSERT INTO Employees(Firstname, LastName, Title, Notes)
VALUES ('Misho', 'Petrov', 'Big shot', 'Lazy')
INSERT INTO Employees(Firstname, LastName, Title, Notes)
VALUES ('Vicky', 'Lioniess', 'Princess', 'Sweet')

INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes)
VALUES (345262346423346, 'Niko Nikov', 'bul. Mihail Gerdjikov 6B', 'Sofia', 1000, 'Rich')
INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes)
VALUES (612462454143652, 'Marina Vasileva', 'bul. Smt Something 72', 'Burgas', null, null)
INSERT INTO Customers(DriverLicenceNumber, FullName, [Address], City, ZIPCode, Notes)
VALUES (987254782485222, 'Nqkoi Toi', 'bul. Nie Vie 3T', 'Plovtiv', null, 'Poor')

INSERT INTO RentalOrders(EmployeeId,CustomerId,CarId,TankLevel,
KilometrageStart,KilometrageEnd,TotalKilometrage,
StartDate,EndDate,TotalDays,RateApplied,TaxRate,OrderStatus,Notes)
VALUES (1, 2, 1, null, 3125, 3325, 200, '2016-03-01', '2016-03-03', 2, 1, 20, 'returned','very precise')

INSERT INTO RentalOrders
VALUES (2, 1, 2, 70, 123, 1236, 1113, '2016-11-01', '2016-11-15', 14, 2, 15, 'returned', 'hitted rear left light')

INSERT INTO RentalOrders
VALUES (3, 3, 3, null, 600, 1000, 400, '2017-01-25', '2016-01-28', 3, 3, 10, 'service', 'for repair')

--Problem 15. Hotel DB
CREATE DATABASE Hotel
USE Hotel

CREATE TABLE Employees 
(
Id INT IDENTITY(1,1) PRIMARY KEY,
FirstName nvarchar(15) NOT NULL,
LastName nvarchar(20) NOT NULL,
Title varchar(10),
Notes varchar(100)
)

CREATE TABLE Customers
(
AccountNumber INT NOT NULL PRIMARY KEY,
FirstName nvarchar(15) NOT NULL,
LastName nvarchar(20) NOT NULL,
PhoneNumber varchar(10) NOT NULL,
EmergencyName nvarchar(15),
EmergencyNumber int,
Notes varchar(200)
)

CREATE TABLE RoomStatus
(
RoomStatus varchar(15) NOT NULL PRIMARY KEY,
Notes varchar(100)
)

CREATE TABLE RoomTypes
(
RoomType varchar(15) NOT NULL PRIMARY KEY,
Notes varchar(100)
)

CREATE TABLE BedTypes
(
BedType varchar(10) NOT NULL PRIMARY KEY,
Notes varchar(50)
)

CREATE TABLE Rooms
(
RoomNumber smallint NOT NULL PRIMARY KEY,
RoomType varchar(15) FOREIGN KEY REFERENCES RoomTypes(RoomType) NOT NULL,
BedType varchar(10) FOREIGN KEY REFERENCES BedTypes(BedType) NOT NULL,
Rate tinyint,
RoomStatus varchar(15) FOREIGN KEY REFERENCES RoomStatus(RoomStatus) NOT NULL,
Notes varchar(100)
)

CREATE TABLE Payments
(
Id INT IDENTITY(1,1) PRIMARY KEY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
PaymentDate DATE NOT NULL,
AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
FirstDateOccupied DATE NOT NULL,
LastDateOccupied DATE NOT NULL,
TotalDays tinyint NOT NULL,
AmountCharged smallmoney NOT NULL,
TaxRate float(24) NOT NULL,
TaxAmount float(24) NOT NULL,
PaymentTotal smallmoney NOT NULL,
Notes varchar(100)
)

CREATE TABLE Occupancies
(
Id INT IDENTITY(1,1) PRIMARY KEY,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL,
DateOccupied DATE NOT NULL,
AccountNumber INT FOREIGN KEY REFERENCES Customers(AccountNumber) NOT NULL,
RoomNumber smallint FOREIGN KEY REFERENCES Rooms(RoomNumber) NOT NULL,
RateApplied float(24) NOT NULL,
PhoneCharge int,
Notes varchar(200)
)

INSERT INTO Employees(FirstName,LastName,Title,Notes)
VALUES ('Stamat', 'Stamatov',null,null)

INSERT INTO Employees(FirstName,LastName,Title,Notes)
VALUES ('Mitko', 'Dimitrov', 'Mitaka', 'Hard worker')

INSERT INTO Employees(FirstName,LastName,Title,Notes)
VALUES ('Pesho', 'Peshov', 'Peshkata', 'Little lazy')

insert into Customers(AccountNumber,FirstName,LastName,PhoneNumber,EmergencyName,EmergencyNumber,Notes)
values ('1235123411', 'Viktoria', 'Lesova', 098713141, 'Vicky', null,null)

insert into Customers(AccountNumber,FirstName,LastName,PhoneNumber,EmergencyName,EmergencyNumber,Notes)
values ('446134613', 'Marina', 'Visova', 0987123515, 'Mani', null,'very sweet')

insert into Customers(AccountNumber,FirstName,LastName,PhoneNumber,EmergencyName,EmergencyNumber,Notes)
values ('513614616', 'Alisa', 'Terzieva', 097893245, 'Alis', null, 'brutal')

insert into RoomStatus(RoomStatus,Notes) values('occupied', null)
insert into RoomStatus(RoomStatus,Notes) values('reserved', null)
insert into RoomStatus(RoomStatus,Notes) values('free', null)

insert into RoomTypes(RoomType,Notes) values('mezonet', null)
insert into RoomTypes(RoomType,Notes) values('apartment', null)
insert into RoomTypes(RoomType,Notes) values('double-small', null)

insert into BedTypes(BedType,Notes) values('double', null)
insert into BedTypes(BedType,Notes) values('single', null)
insert into BedTypes(BedType,Notes) values('two single', null)

insert into Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
values ('123', 'mezonet', 'double', 10, 'occupied', 'young couple')

insert into Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
values ('345', 'apartment', 'two single', 8, 'reserved', 'two couples')

insert into Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
values ('512', 'double-small', 'single', 7, 'free', null)

insert into Payments(EmployeeId, PaymentDate, AccountNumber, 
FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate,
 TaxAmount, PaymentTotal, Notes)
 values (1, '2016-03-01', '1235123411', '2016-02-20', '2016-02-28', 8,
  4123.40, 20, 15, 4321.00, null)

insert into Payments(EmployeeId, PaymentDate, AccountNumber, 
FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate,
 TaxAmount, PaymentTotal, Notes)
values (2, '2016-04-10', '446134613', '2016-04-01', '2016-04-09', 9,
  4123.40, 20, 15, 4321.00, null)

insert into Payments(EmployeeId, PaymentDate, AccountNumber, 
FirstDateOccupied, LastDateOccupied, TotalDays, AmountCharged, TaxRate,
 TaxAmount, PaymentTotal, Notes)
values (3, '2016-05-11', '513614616', '2016-05-01', '2016-05-10', 10,
  4123.40, 20, 15, 4321.00, null)

insert into Occupancies(EmployeeId, DateOccupied, AccountNumber,
 RoomNumber, RateApplied, PhoneCharge, Notes)
values (1, '2016-05-11', '513614616', '123', 10, null, null)

insert into Occupancies(EmployeeId, DateOccupied, AccountNumber,
 RoomNumber, RateApplied, PhoneCharge, Notes)
values (2, '2016-04-10', '446134613', '345', 9, null, null)

insert into Occupancies(EmployeeId, DateOccupied, AccountNumber,
 RoomNumber, RateApplied, PhoneCharge, Notes)
values (3, '2016-03-01', '1235123411', '512', 8, null, null)


--Problem 16. SoftUni DB
create database SoftUni
GO
use SoftUni

create table Towns
(
Id INT IDENTITY(1,1) PRIMARY KEY,
Name varchar(15) NOT NULL
)

create table [Addresses]
(
Id Int IDENTITY(1,1) PRIMARY KEY,
AddressText varchar(30) NOT NULL,
TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

create table Departments
(
Id int identity(1,1) primary key,
Name varchar(20) not null
)

create table Employees
(
Id int identity(1,1) primary key,
FirstName nvarchar(15) not null,
MiddleName nvarchar(20),
LastName nvarchar(20) not null,
JobTitle varchar(15) not null,
DepartmentId int foreign key references Departments(Id) not null,
HireDate date not null,
Salary money not null,
AddressId int foreign key references Addresses(Id) not null
)

insert into Towns(Name) values('Sofia')
insert into Towns(Name) values('Plovdiv')
insert into Towns(Name) values('Varna')
insert into Towns(Name) values('Burgas')

insert into Departments(Name) values('Engineering')
insert into Departments(Name) values('Sales')
insert into Departments(Name) values('Marketing')
insert into Departments(Name) values('Software Development')
insert into Departments(Name) values('Quality Assurance')

insert into Addresses(TownId,AddressText)
values (1, 'Bul. Patriarh Evtimii 37')

insert into Addresses(TownId,AddressText)
values (2, 'Bul. Vasil Levski 137')

insert into Addresses(TownId,AddressText)
values (3, 'Bul. Kosta Dimitrov 25')


insert into Employees(FirstName,MiddleName,LastName,JobTitle,
DepartmentId,HireDate,Salary,AddressId)
values ('Ivan', 'Ivanov', 'Ivanov', '.NET Developer',
 4, '2013-02-01', 3500.00, 1)

insert into Employees
values ('Petar', 'Petrov', 'Petrov', 'Senior Engineer',
 1, '2004-03-02', 4000.00, 2)

insert into Employees
values ('Maria', 'Petrova', 'Ivanova', 'Intern',
 5, '2016-08-28', 525.25, 3)

insert into Employees
values ('Georgi', 'Terziev', 'Ivanov', 'CEO',
 2, '2007-12-09', 3000.00, 1)

insert into Employees
values ('Peter', 'Pan', 'Pan', 'Intern',
 3, '2016-08-28', 599.88, 2)

 --Problem 19 Basic select all fields
select * from Towns

select * from Departments

select * from Employees

--Problem 20 Basic select all fields and order them
select * from Towns order by Name

select * from Departments order by Name

select * from Employees order by Salary DESC

--Problem 21 Basic Select Some Fields
select [Name] from Towns order by Name

select [Name] from Departments order by Name

select 
	[FirstName], [LastName], [JobTitle], [Salary] 
from Employees
order by Salary DESC

--Problem 22 Increase employees salary
UPDATE Employees
SET Salary *= 1.1

select [Salary]
from Employees

--Problem 23 Decrease tax rate
Use Hotel

UPDATE Payments
SET TaxRate *= 0.97

Select [TaxRate] From Payments

--Problem 24 Delete all records
use Hotel

truncate table Occupancies