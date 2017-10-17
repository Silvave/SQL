-- 01.Employees with Salary Above 35000
create proc usp_GetEmployeesSalaryAbove35000
as
begin
	select e.FirstName,
			e.LastName
	from Employees as e
	where e.Salary > 35000
end
go

-- 02.Employees with Salary Above Number
go
create proc usp_GetEmployeesSalaryAboveNumber (@Salary money)
as
begin
	select e.FirstName,
			e.LastName
	from Employees as e
	where e.Salary >= @Salary
end
go

-- 03.Town Names Starting With
go
create proc usp_GetTownsStartingWith (@PARTNAME varchar(max))
as
begin
	DECLARE @startName varchar(max);
	set @startName = @PARTNAME + '%'
	select t.Name
	from Towns as t
	where t.Name like @startName
end
go

-- 04.Employees from Town
go
create proc usp_GetEmployeesFromTown (@TownName varchar(max))
as
begin
	select e.FirstName,
			e.LastName
	from Employees as e
	  join Addresses as a
		on e.AddressID = a.AddressID
	  join Towns as t
		on a.TownID = t.TownID
	where t.Name = @TownName
end
go

-- 05.Salary Level Function
go
create function ufn_GetSalaryLevel(@salary money)
returns varchar(7)
as
begin
	declare @SalaryType varchar(7);
	if (@salary < 30000)
		set @SalaryType = 'Low';
	else if (@salary <= 50000)
		set @SalaryType = 'Average';
	else
		set @SalaryType = 'High';

	return @SalaryType;
end
go

-- 06.Employees by Salary Level
go
create proc usp_EmployeesBySalaryLevel (@salaryType varchar(7))
as
begin
	select e.FirstName,
			e.LastName
	from Employees as e
	where dbo.ufn_GetSalaryLevel(e.Salary) = @salaryType
end
go

-- 07.Define Function
go
create function ufn_IsWordComprised(@setOfLetters varchar(max), @word varchar(max))
returns bit
as
begin
	declare @currentIndex int = 1;

	while @currentIndex <= len(@word)
	begin
		declare @currentLetter varchar = substring(@word,@currentIndex,1);
		declare @isThereLetter int = charindex(@currentLetter, @setOfLetters);

		if (@isThereLetter = 0)
			return 0
	
		set @currentIndex += 1;
	end

	return 1
end
go

-- 08.Delete Employees and Departments
delete from EmployeesProjects
where EmployeeID in (select e.EmployeeID
					from Employees as e
						join Departments as d
						on e.DepartmentID = d.DepartmentID
					where d.Name in ('Production','Production Control'))

update Employees
set ManagerID = null
where ManagerID in (select e.EmployeeID
					from Employees as e
						join Departments as d
						on e.DepartmentID = d.DepartmentID
					where d.Name in ('Production','Production Control'))

alter table Departments
alter column ManagerID int null

update Departments
set ManagerID = null
where Name in ('Production','Production Control')

delete from Employees
where EmployeeID in (select e.EmployeeID
					from Employees as e
						join Departments as d
						on e.DepartmentID = d.DepartmentID
					where d.Name in ('Production','Production Control'))

delete Departments
where Name in ('Production','Production Control')

-- 09.Employees with Three Projects
go
create proc usp_AssignProject(@emloyeeId int, @projectID int)
as
begin tran
	insert into EmployeesProjects(EmployeeID, ProjectID)
	values (@emloyeeId, @projectID)

	if ((select Count(ProjectID) from EmployeesProjects
		 where EmployeeID = @emloyeeId) > 3)
	begin;
		rollback;
		raiserror('The employee has too many projects!', 16, 1);
		return;
	end
commit
go

-- 17.Create Table Logs
use Bank
go
create trigger tr_AddToLogs on Accounts for update
as
begin
	declare @AccountId int = (select Id from inserted);
	declare @NewSum money = (select Balance from inserted)
	declare @OldSum money = (select Balance from deleted)

	insert into Logs values (@AccountId, @OldSum, @NewSum)
end
go