--Part I - Queries for SoftUni Database
--Problem 1 Find Names of All Employees by First Name
use SoftUni
go

select [FirstName]
	  ,[LastName]
	from Employees
	where FirstName like 'Sa%'

--02. Find Names of All Employees by Last Name
select [FirstName]
	  ,[LastName]
	from Employees
	where LastName like '%ei%'

--03. Find First Names of All Employess
select [FirstName]
	from Employees
	where DepartmentID in (3,10)
		AND
		  Datepart(year, HireDate) between 1995 and 2005

--04. Find All Employees Except Engineers
select [FirstName]
	  ,[LastName]
	  from Employees
	  where Charindex('engineer', JobTitle) = 0

--05. Find Towns with Name Length
select [Name]
	from Towns
	where LEN(RTRIM(Name)) in (5,6)
	order by Name

--06. Find Towns Starting With
select [TownID]
	  ,[Name]
	from Towns
	where Name like '[MKBE]%'
	order by Name

--07. Find Towns Not Starting With
select [TownID]
	  ,[Name]
	from Towns
	where not Name like '[RBD]%'
	order by Name

--08. Create View Employees Hired After
go
create view V_EmployeesHiredAfter2000 
as
select [FirstName]
	  ,[LastName]
	from Employees
	where Datepart(year, HireDate) > 2000
go
--09. Length of Last Name
select [FirstName]
	  ,[LastName]
	from Employees
	where LEN(RTRIM(LastName)) = 5

--10. Countries Holding 'A'
use Geography
go

select [CountryName]
	  ,[IsoCode]
	from Countries
	where CountryName like '%a%a%a%'
	order by IsoCode

--11. Mix of Peak and River Names
select [PeakName]
	  ,[RiverName]
	  ,LOWER(CONCAT(PeakName, RIGHT(RiverName, LEN(RiverName)-1))) --or SUBSTRING(RiverName, 2, LEN(RiverName)-1)
	  as [Mix]
	from Peaks, Rivers
	where RIGHT(PeakName, 1) = LEFT(RiverName, 1)
	order by Mix

--12. Games From 2011 and 2012 Year
use Diablo
go

select top (50) 
	   [Name]
	  ,FORMAT([Start], 'yyyy-MM-dd') as [Started]
	from Games
	where DATEPART(year, [Start]) between 2011 and 2012
	order by Start, Name

--13. User Email Providers
select [Username]
	  ,SUBSTRING([Email],CHARINDEX('@',[Email])+1,LEN([Email])) as [Email Provider]
	  from Users
	  order by [Email Provider], [Username]

--14. Get Users with IPAddress Like Pattern
select [Username]
	  ,[IpAddress] as [IP Address]
	from Users
	where [IpAddress] LIKE '___.1%.%.___'
	order by Username

--15. Show All Games with Duration
select [Name]
	  ,CASE
		WHEN DATEPART(hour,Start) between 0 and 11
			THEN 'Morning'
		WHEN DATEPART(hour,Start) between 12 and 17
			THEN 'Afternoon'
		WHEN DATEPART(hour,Start) between 18 and 23
			THEN 'Evening'
	   END as [Part of the Day]
	  ,CASE
		WHEN [Duration] <= 3
			THEN 'Extra Short'
		WHEN [Duration] between 4 and 6
			THEN 'Short'
		WHEN [Duration] > 6
			THEN 'Long'
		WHEN [Duration] is null
			THEN 'Extra Long'
	  END as [Duration]
	 from Games
	 order by [Name]
			 ,[Duration]
			 ,[Part of the Day]

--16. Orders Table
use Orders
go

select [ProductName]
	  ,[OrderDate]
	  ,DATEADD(day, 3, [OrderDate]) as [Pay Due]
	  ,DATEADD(month, 1, [OrderDate]) as [Deliver Due]
	   from Orders

--17. People Table
use School
go

create table People
(
Id INT IDENTITY(1,1) PRIMARY KEY,
Name varchar(20) NOT NULL,
Birthdate datetime NOT NULL
)

insert into People(Name, Birthdate)
 values('Victor', '2000-12-07 00:00:00.000')
	  ,('Steven', '1992-09-10 00:00:00.000')
	  ,('Stephen', '1910-09-19 00:00:00.000')
	  ,('John', '2010-01-06 00:00:00.000')

select [Name]
	  ,DATEDIFF(year, Birthdate, GETDATE()) as [Age in Years]
	  ,DATEDIFF(month, Birthdate, GETDATE()) as [Age in Months]
	  ,DATEDIFF(day, Birthdate, GETDATE()) as [Age in Days]
	  ,DATEDIFF(minute, Birthdate, GETDATE()) as [Age in Minutes]
	from People