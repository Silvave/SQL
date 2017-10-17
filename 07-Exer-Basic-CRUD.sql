--problem 2 find all information
use SoftUni
go

select * from Departments

--03. Find all Department Names
select [Name] from Departments

--04. Find Salary of Each Employee
select [FirstName],[LastName], [Salary] from Employees

--05. Find Full Name of Each Employee
select [FirstName], [MiddleName], [LastName] from Employees

--06. Find Email Address of Each Employee
select CONCAT([FirstName],'.', [LastName],'@softuni.bg') from Employees

--07. Find All Different Employee’s Salaries
select DISTINCT [Salary] from Employees

--08. Find all Information About Employees
select * from Employees where [JobTitle] = 'Sales Representative'

--09. Find Names of All Employees by Salary in Range
select 
	[FirstName],[LastName], [JobTitle] 
from 
	Employees
where Salary between 20000 AND 30000

--10. Find Names of All Employees
select [FirstName] + ' ' + [MiddleName] + ' ' + [LastName] AS [Full Name]
from Employees
where Salary in (25000,14000,12500,23600)

--Why does this does not work in judge
--select
--	CONCAT([FirstName], ' ',[MiddleName], ' ',[LastName]) 
--	as [Full Name]
--from
--	Employees
--where Salary in (25000,14000,12500,23600)

--11. Find All Employees Without Manager
select [FirstName], [LastName] 
from Employees
where ManagerID is null

--12. Find All Employees with Salary More Than
select
	[FirstName], [LastName], [Salary]
from Employees
where Salary > 50000
order by Salary DESC

--13. Find 5 Best Paid Employees
select top (5)
	[FirstName], [LastName]
from Employees
order by Salary DESC

--14. Find All Employees Except Marketing
select
	[FirstName], [LastName]
from Employees
where NOT DepartmentID = 4

--15. Sort Employees Table
select
	*
from
	Employees
order by Salary DESC, 
		 [FirstName],
		 [LastName] DESC, 
		 [MiddleName]

--16. Create View Employees with Salaries
go
create view V_EmployeesSalaries as
select [FirstName], [LastName], [Salary]
from Employees
go

--17. Create View Employees with Job Titles
go
create view V_EmployeeNameJobTitle as
SELECT 
	CONCAT([FirstName],' ',[MiddleName], ' ', [LastName]) as [Full Name]
	,[JobTitle] as [Job Title]
FROM Employees
go
--18. Distinct Job Titles
select distinct [JobTitle] from Employees

--19. Find First 10 Started Projects
select top (10)
	*
from Projects
order by StartDate, Name

--20. Last 7 Hired Employees
select top (7)
	[FirstName], [LastName], [HireDate]
from Employees
order by [HireDate] desc

--21. Increase Salaries
update Employees
set Salary *= 1.12
where DepartmentID in (1, 2, 4, 11)

select Salary from Employees
--------------------------------
--to disconnect the database before restoring it
use [master];
ALTER DATABASE [SoftUni] SET OFFLINE WITH ROLLBACK IMMEDIATE;
ALTER DATABASE [SoftUni] SET ONLINE;
--------------------------------

--22. All Mountain Peaks
use Geography
go

select [PeakName] from Peaks
order by PeakName

--23. Biggest Countries by Population
select top (30)
	[CountryName], [Population]
from Countries
where ContinentCode = 'EU'
order by [Population] desc, [CountryName]

--24. Countries and Currency (Euro / Not Euro)
select 
	[CountryName], [CountryCode],
	CASE
		WHEN CurrencyCode = 'EUR'
			THEN 'Euro'
		ELSE 'Not Euro'
	END AS [Currency]
from Countries
order by CountryName

--25. All Diablo Characters
use Diablo
go

select [Name] from Characters
order by Name