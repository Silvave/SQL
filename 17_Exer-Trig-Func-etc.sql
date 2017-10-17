--Part I – Queries for SoftUni Database
--01 Problem 1.	Employees with Salary Above 35000
use SoftUni
go

create proc usp_GetEmployeesSalaryAbove35000 
as
begin
	select FirstName,
		   LastName
	from Employees
	where Salary > 35000
end
go

--02 Employees with Salary Above Number
create proc usp_GetEmployeesSalaryAboveNumber (@salaryNum money)
as
begin
	select FirstName,
		   LastName
	from Employees
	where Salary >= @salaryNum
end

--03 Town Names Starting With
go
create proc usp_GetTownsStartingWith (@checkStr varchar(max))
as
begin
	select Name
	from Towns
	where Left(Name,Len(@checkStr)) = @checkStr
end
go

exec usp_GetTownsStartingWith 'b'

--04 Employees from Town
go
create proc usp_GetEmployeesFromTown (@townName varchar(max))
as
begin
	select e.FirstName,
		   e.LastName
	from Employees as e
	  join Addresses as a
	    on e.AddressID = a.AddressID
	  join Towns as t
	    on a.TownID = t.TownID
	where t.Name = @townName
end
go

exec usp_GetEmployeesFromTown 'Sofia'

--05 Salary Level Function
go
create function ufn_GetSalaryLevel(@salary money)
returns varchar(7)
as
begin
	declare @salaryType varchar(7);
	if (@salary < 30000)
		set @salaryType = 'Low'
	else if (@salary <= 50000)
		set @salaryType = 'Average'
	else
		set @salaryType = 'High'
	return @salaryType;
end
go

select Salary,
	   dbo.ufn_GetSalaryLevel(Salary) as [Salary Level]
from Employees

--06 Employees by Salary Level
go
create proc usp_EmployeesBySalaryLevel (@salaryLevel varchar(7))
as
begin
	select  FirstName,
			LastName
	from Employees
	where dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
end
go

--07 Define Function
go
create function ufn_IsWordComprised(@setOfLetters varchar(max),
									 @word varchar(max))
returns bit
as
begin
	declare @currentLetIndex int = 1;
	
	while @currentLetIndex <= len(@word)
	begin
		declare @currentLetter varchar = substring(@word, @currentLetIndex, 1);
		declare @isLetterPresent int = charindex(@currentLetter, @setOfLetters)
		
		if (@isLetterPresent = 0)
			return 0

		set @currentLetIndex += 1;
	end
	return 1
end
go

select FirstName
from Employees
where dbo.ufn_IsWordComprised(FirstName, 'Rob') = 1	