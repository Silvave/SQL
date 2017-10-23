create database ReportService
GO

use ReportService
go


-- Section. 1 DDL
create table Users
(
  Id int identity(1,1) primary key,
  Username nvarchar(30) unique not null,
  Password nvarchar(50) not null,
  Name nvarchar(50),
  Gender char(1) check (Gender in ('M', 'F')),
  BirthDate date,
  Age int,
  Email nvarchar(50) not null
)
go

create table Departments
(
  Id int identity(1,1) primary key,
  Name nvarchar(50) not null
)
go

create table Employees
(
  Id int identity(1,1) primary key,
  FirstName nvarchar(25),
  LastName nvarchar(25),
  Gender char(1) check (Gender in ('M', 'F')),
  BirthDate date,
  Age int,
  DepartmentId int not null foreign key references Departments(Id)
)
go

create table Categories
(
  Id int identity(1,1) primary key,
  Name nvarchar(50) not null,
  DepartmentId int foreign key references Departments(Id)
)
go

create table Status
(
  Id int identity(1,1) primary key,
  Label nvarchar(30) not null
)
go

create table Reports
(
  Id int identity(1,1) primary key,
  OpenDate date not null,
  CloseDate date,
  Description nvarchar(200),
  CategoryId int not null foreign key references Categories(Id),
  StatusId int not null foreign key references Status(Id),
  UserId int not null foreign key references Users(Id),
  EmployeeId int foreign key references Employees(Id)
)
go


-- Section 2. DML
-- 2. Insert
insert into Employees (FirstName, LastName, Gender, BirthDate, DepartmentId) values
('Marlo', 'O’Malley', 'M', '9/21/1958', 1),
('Niki', 'Stanaghan', 'F', '11/26/1969', 4),
('Ayrton', 'Senna', 'M', '3/21/1960', 9),
('Ronnie', 'Peterson', 'M', '2/14/1944', 9),
('Giovanna', 'Amati', 'F', '7/20/1959', 5)
go

insert into Reports (CategoryId, StatusId, OpenDate, CloseDate, Description, UserId, EmployeeId) values
(1, 1, '04/13/2017', null, 'Stuck Road on Str.133', 6, 2),
(6, 3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
(14, 2, '09/07/2015', null, 'Falling bricks on Str.58', 5, 2),
(4, 3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)
go

-- 3. Update
begin tran
	update Reports
	set StatusId = 2
	where StatusId = 1 and CategoryId = 4
rollback

-- 4. Delete
begin tran
	delete Reports
	 where UserId in (select Id from Users where Age < 18)

	delete Users
	where Age < 18
rollback

-- Section 3. Querying
-- 5. Users by Age
select Username,
      Age
from Users
order by Age asc, Username desc

-- 6. Unassigned Reports
select Description,
  OpenDate
from Reports
where EmployeeId is null
order by OpenDate asc, Description asc

-- 7. Employees & Reports
select e.FirstName,
  e.LastName,
  r.Description,
  format(r.OpenDate, 'yyyy-MM-dd')
from Reports as r
  join Employees as e
  on r.EmployeeId = e.Id
order by r.EmployeeId asc, r.OpenDate asc

-- 8. Most Reported Category
select c.Name as [CategoryName],
  count(r.Id) as [ReposrtsNumber]
from Categories as c
  join Reports as r
    on c.Id = r.CategoryId
group by c.Name
order by ReposrtsNumber asc, c.Name asc

-- 9. Employees in Category
select c.Name as [CategoryName],
  count(e.Id) as [Employees Number]
from Categories as c
  join Departments as d
   on c.DepartmentId = d.Id
  join Employees as e
    on d.Id = e.DepartmentId
group by c.Name
order by c.Name asc

-- 10. Birthday Report
select c.Name
from Categories as c
  join Reports as r
    on c.Id = r.CategoryId
  join Users as u
    on r.UserId = u.Id
where format(r.OpenDate, 'dd-MM') = format(u.BirthDate, 'dd-MM')
group by c.Name
order by c.Name

-- 11. Users per Employee
select concat(e.FirstName, ' ', e.LastName) as [Name],
  count(r.EmployeeId) as [Users Number]
from Employees as e
  left join (select r.UserId,
          r.EmployeeId
        from Reports as r
        where r.EmployeeId is not null
        group by r.UserId, r.EmployeeId) as r
  on e.Id = r.EmployeeId
group by e.FirstName, e.LastName
order by 'Users Number' desc, Name asc

-- 12. Emergency Patrol
select r.OpenDate,
  r.Description,
  u.Email
from Reports as r
  join Categories as c
    on r.CategoryId = c.Id
  join Users as u
    on r.UserId = u.Id
where r.CloseDate is null and
      len(r.Description) > 20 and
      r.Description like '%str%' and
      c.DepartmentId in (1, 4, 5)
order by r.OpenDate asc, u.Email asc

-- 13. Numbers Coincidence
select u.Username
from Users as u
  join Reports as r
    on r.UserId = u.Id
where (u.Username like '[0-9]%' and left(u.Username, 1) = convert(nvarchar, r.CategoryId)) or
      (u.Username like '%[0-9]' and right(u.Username, 1) = convert(nvarchar, r.CategoryId))
group by u.Username
order by u.Username asc

-- 14. Open/Close Statistic
select concat(e.FirstName, ' ', e.LastName) as [Name],
	concat(sum(case isnull(datepart(year, r.CloseDate), '0') when '2016' then 1 else 0 end),
	 '/', sum(case datepart(year, r.OpenDate) when '2016' then 1 else 0 end)) as [ReportsNumber]
from Employees as e
  join  Reports as r
    on e.Id = r.EmployeeId
group by e.Id, e.FirstName, e.LastName
having sum(case isnull(datepart(year, r.CloseDate), '0') when '2016' then 1 else 0 end) > 0 or
	sum(case datepart(year, r.OpenDate) when '2016' then 1 else 0 end) > 0
order by [Name] asc

-- 15. Avg Closing Time
select d.Name as [Department Name],
	isnull(convert(nvarchar, avg(DATEDIFF(day, r.OpenDate, r.CloseDate))), 'no info') as [Average Duration]
from Departments as d
  join Categories as c
    on d.Id = c.DepartmentId
  join Reports as r
    on c.Id = r.CategoryId
group by d.Name
order by d.Name asc

-- 16. Most Reported Category
select d.Name as [Department Name],
  c.Name as [Category Name],
  cast(round(((ur.ReportsByCategory * 1.0) / dr.AllDepReports) * 100, 0) as int) as [Percentage]
from Departments as d
  join Categories as c
    on d.Id = c.DepartmentId
  join (select r.CategoryId,
            count(r.Id) as [ReportsByCategory]
          from Reports as r
          group by r.CategoryId) as ur
    on c.Id = ur.CategoryId
    join (select c.DepartmentId,
          count(r.Id) as [AllDepReports]
        from Reports as r
          join Categories as c
            on r.CategoryId = c.Id
        group by c.DepartmentId) as dr
      on d.Id = dr.DepartmentId
group by d.Name, c.Name, dr.AllDepReports, ur.ReportsByCategory
order by [Department Name] asc, [Category Name] asc, [Percentage] asc

-- 16. 2-nd solution with partition
select [Department Name],
  [Category Name],
  Percentage
from (select distinct c.Name as [Category Name],
        d.Name as [Department Name],
        cast(round(((count(r.id) over(partition by c.Name) * 1.0) /
               count(r.id) over(partition by d.Name)) * 100, 0) as int) as [Percentage]
      from Reports as r
        join Categories as c
          on r.CategoryId = c.Id
        join Departments as d
          on c.DepartmentId = d.Id) as result
order by [Department Name] asc, [Category Name] asc, [Percentage] asc


-- Section 4. Programmability
-- 17. Employee’s Load
GO
create function udf_GetReportsCount(@employeeId int, @statusId int)
returns int
as
begin
  return (select count(*)
          from Reports as r
          where r.EmployeeId = @employeeId and
                r.StatusId = @statusId
          group by r.EmployeeId)
end
go

--Test
SELECT Id, Firstname, Lastname, dbo.udf_GetReportsCount(Id, 2)
FROM Employees
ORDER BY Id

-- 18. Assign Employee
go
create proc usp_AssignEmployeeToReport(@employeeId int, @reportId int)
as
begin tran
  update Reports
  set EmployeeId = @employeeId
  where Id = @reportId

  declare @employeeDep int = (select e.DepartmentId from Employees as e where e.Id = @employeeId)
  declare @reportDep int = (select c.DepartmentId
                            from Reports as r
                              join Categories as c
                                on r.CategoryId = c.Id
                            where r.Id = @reportId)

  if (@employeeDep != @reportDep)
  begin
    rollback;
    raiserror('Employee doesn''t belong to the appropriate department!', 16, 1)
    return;
  end
commit
go

-- Test
begin tran
  exec usp_AssignEmployeeToReport 17, 2;
  select EmployeeId from Reports where id = 2
rollback

-- 19. Close Reports
go
create trigger tr_ChangeReportStatus on Reports after update
as
begin
  declare @isReportFinished date = (select top 1 CloseDate from inserted)
  declare @ReportId int = (select top 1 Id from inserted)

  if(@isReportFinished is not null)
  begin
    update Reports
    set StatusId = 3
    where Id = @ReportId
  end
end
go

-- Test
begin tran
  update Reports
  set CloseDate = getdate()
  where EmployeeId = 5;
rollback


-- Section 5. Bonus
-- 20. Categories Revision
select [Category Name],
       [Waiting] + [In Progress] as [Reports Number],
       case
         when [Waiting] > [In Progress] then 'waiting'
         when [Waiting] < [In Progress] then 'in progress'
		 else 'equal'
	   end as [Main Status]
from (select c.Name as [Category Name],
        sum(case s.Label when 'waiting' then 1 else 0 end) as [Waiting],
        sum(case s.Label when 'in progress' then 1 else 0 end) as [In Progress]
      from Reports as r
        join Categories as c
          on r.CategoryId = c.Id
        join Status as s
          on r.StatusId = s.Id
      where s.Label in ('waiting', 'in progress')
      group by c.Name) as CategoryStatusReports
order by [Category Name] asc
