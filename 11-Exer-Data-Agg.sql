--01. Records’ Count
use Gringotts
go

select COUNT(*) as [Count]
from WizzardDeposits

--02. Longest Magic Wand
select MAX(MagicWandSize) as [LongestMagicWand]
from WizzardDeposits

--03. Longest Magic Wand per Deposit Groups
select [DepositGroup]
	  ,MAX(MagicWandSize) as [LongestMagicWand]
from WizzardDeposits
group by DepositGroup

--04. Smallest Deposit Group per Magic Wand Size
--1-st solution
select [DepositGroup]
from WizzardDeposits
group by [DepositGroup]
having AVG([MagicWandSize]) = (
								  select MIN(avgMWandSize)  from 
								  (
									  select AVG([MagicWandSize]) as avgMWandSize
									  from WizzardDeposits
									  group by [DepositGroup]
								  ) as AvgMagicWandSize
							  )

--2-nd solution
select top (1) with ties
	  [DepositGroup]
from WizzardDeposits
group by [DepositGroup]
order by AVG([MagicWandSize])

--05. Deposits Sum
select wd.DepositGroup
	  ,SUM(wd.DepositAmount) as 'TotalSum'
from WizzardDeposits as wd
group by wd.DepositGroup

--06. Deposits Sum for Ollivander Family
select wd.DepositGroup
	  ,SUM(wd.DepositAmount) as 'TotalSum'
from WizzardDeposits as wd
where wd.MagicWandCreator = 'Ollivander family'
group by wd.DepositGroup

--07. Deposits Filter
select wd.DepositGroup
	  ,SUM(wd.DepositAmount) as [TotalSum]
from WizzardDeposits as wd
where wd.MagicWandCreator = 'Ollivander family'
group by wd.DepositGroup
having SUM(wd.DepositAmount) < 150000
order by [TotalSum] desc

--08. Deposit Charge
select [DepositGroup]
	  ,[MagicWandCreator]
	  ,MIN([DepositCharge]) as [MinDepositeCharge]
from WizzardDeposits
group by DepositGroup, MagicWandCreator
order by [MagicWandCreator], [DepositGroup]

--09. Age Groups
select [AgeGroup]
	  ,Count(AgeGroup) as [WizzardCount] from
(
	select 
		case
			WHEN Age between 0 and 10 THEN '[0-10]'
			WHEN Age between 11 and 20 THEN '[11-20]'
			WHEN Age between 21 and 30 THEN '[21-30]'
			WHEN Age between 31 and 40 THEN '[31-40]'
			WHEN Age between 41 and 50 THEN '[41-50]'
			WHEN Age between 51 and 60 THEN '[51-60]'
			WHEN Age >= 61 THEN '[61+]'
		end as [AgeGroup]
	from WizzardDeposits
) as GroupsByAge
group by AgeGroup

--10. First Letter
select LEFT(FirstName, 1) as [FirstLetter]
from WizzardDeposits
where [DepositGroup] = 'Troll Chest'
group by LEFT(FirstName, 1) --can be done with 'distinct' too

--11. Average Interest
select [DepositGroup]
	  ,[IsDepositExpired]
	  ,AVG([DepositInterest]) as [AverageInterest]
from WizzardDeposits
where DATEDIFF(day, '1985-01-01', [DepositStartDate]) > 0
group by [DepositGroup], [IsDepositExpired]
order by [DepositGroup] desc, [IsDepositExpired]

--12. Rich Wizard, Poor Wizard
select SUM([Difference]) as [SumDifference] from 
(
	select [DepositAmount] - LEAD([DepositAmount]) OVER (ORDER BY(Id)) 
			as [Difference]
	from WizzardDeposits
) as Differences

--13. Departments Total Salaries
use SoftUni
go

select [DepartmentID] 
	  ,SUM([Salary]) as [TotalSalary]
from Employees
group by [DepartmentID]
order by [DepartmentID]

--14. Employees Minimum Salaries
select [DepartmentID] 
	  ,MIN([Salary]) as [MinimumSalary]
from Employees
where [DepartmentID] in (2,5,7)
	and DATEDIFF(day, '2000-01-01', HireDate) > 0
group by [DepartmentID]
order by DepartmentID

--15. Employees Average Salaries
select *
into HighPaidEmployees
from Employees
where Salary > 30000

delete from HighPaidEmployees
where ManagerID = 42

update HighPaidEmployees 
set Salary += 5000
where DepartmentID = 1

select [DepartmentID]
	  ,AVG([Salary]) as [AverageSalary]
from HighPaidEmployees
group by DepartmentID

--16. Employees Maximum Salaries
select [DepartmentID]
	  ,MAX([Salary]) as [MaxSalary]
from Employees
group by DepartmentID
having not MAX([Salary]) between 30000 and 70000

--17. Employees Count Salaries
select Count([Salary]) as [Count]
from Employees
group by ManagerID
having ManagerID is null

--18. 3rd Highest Salary
select [DepartmentID]
	  ,[Salary] from
	(
		select [DepartmentID]
			  ,[Salary]
			  ,ROW_NUMBER() 
				  over(partition by [DepartmentID] order by [Salary] desc) 
					as [SalaryRank]
		from [Employees]
		group by [DepartmentID], [Salary]
	) as [GroupedSalaries]
where [SalaryRank] = 3

--19. Salary Challenge
select top (10)
	   [FirstName]
	  ,[LastName]
	  ,[DepartmentID]
from Employees as [outDep]
where Salary >	(
					select AVG([Salary])
					from Employees as [inDep]
					where inDep.DepartmentID = outDep.DepartmentID
					group by DepartmentID
				) 
order by DepartmentID
