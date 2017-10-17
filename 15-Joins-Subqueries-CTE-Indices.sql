-- 01.Employee Address
use SoftUni

select TOP(5) e.EmployeeID,
		e.JobTitle,
		e.AddressID,
		a.AddressText
from Employees as e
  join Addresses as a
	on e.AddressID = a.AddressID
order by AddressID

-- 02.Addresses with Towns
select TOP(50) e.FirstName,
		e.LastName,
		t.Name,
		a.AddressText
from Employees as e
  join Addresses as a
	on e.AddressID = a.AddressID
  join Towns as t
	on a.TownID = t.TownID
order by e.FirstName, e.LastName

-- 03.Sales Employees
select e.EmployeeID,
		e.FirstName,
		e.LastName,
		d.Name as [DepartmentName]
from Employees as e
  join Departments as d
	on e.DepartmentID = d.DepartmentID
	and d.Name = 'Sales'
order by e.EmployeeID

-- 04.Employee Departments
select TOP(5) 
		e.EmployeeID,
		e.FirstName,
		e.Salary,
		d.Name as [DepartmentName]
from Employees as e
  join Departments as d
    on e.DepartmentID = d.DepartmentID
	and e.Salary > 15000
order by e.DepartmentID

-- 05.Employees Without Projects
select TOP 3
		e.EmployeeID,
		e.FirstName
from Employees as e
  left join EmployeesProjects as ep
    on e.EmployeeID = ep.EmployeeID
where ep.EmployeeID is NULL
order by e.EmployeeID

-- 06.Employees Hired After
select e.FirstName,
		e.LastName,
		e.HireDate,
		d.Name as [DeptName]
from Employees as e
  join Departments as d
	on e.DepartmentID = d.DepartmentID
where DATEDIFF(day,'1999-01-01',e.HireDate) >= 0 
	and d.Name in ('Sales', 'Finance')
order by e.HireDate

-- 07.Employees With Project
select Top 5
		e.EmployeeID,
		e.FirstName,
		p.Name as [ProjectName]
from Employees as e
  join EmployeesProjects as ep
    on e.EmployeeID = ep.EmployeeID
  join Projects as p
    on ep.ProjectID = p.ProjectID
where p.StartDate > '2002-08-13'
	and p.EndDate is null
order by e.EmployeeID

-- 08.Employee 24
select e.EmployeeID,
		e.FirstName,
		case
			when DATEPART(yyyy, p.StartDate) >= 2005 then null
			else p.Name
		end as [ProjectName]
from Employees as e
  join EmployeesProjects as ep
	on e.EmployeeID = ep.EmployeeID
  join Projects as p
	on ep.ProjectID = p.ProjectID
where e.EmployeeID = 24

-- 09. Employee Manager
select e.EmployeeID,
		e.FirstName,
		e.ManagerID,
		m.FirstName
from Employees as e
 join Employees as m
	on e.ManagerID = m.EmployeeID
where e.ManagerID in (3,7)
order by e.EmployeeID

-- 10.Employees Summary
select TOP 50 
		e.EmployeeID,
		CONCAT(e.FirstName,' ', e.LastName) as [EmployeeName],
		CONCAT(m.FirstName,' ', m.LastName) as [ManagerName],
		d.Name as [DepartmentName]
from Employees as e
  join Employees as m
	on e.ManagerID = m.EmployeeID
  join Departments as d
	on e.DepartmentID = d.DepartmentID
order by e.EmployeeID

-- 11.Min Average Salary
select top 1 
	AVG(e.Salary) as [MaxAverageSalary]
from Departments as d
  join Employees as e
	on d.DepartmentID = e.DepartmentID
group by d.DepartmentID
order by [MaxAverageSalary]

-- 12.Highest Peaks in Bulgaria
use Geography

select mc.CountryCode,
		m.MountainRange,
		p.PeakName,
		p.Elevation
from Mountains as m
  join MountainsCountries as mc
	on m.Id = mc.MountainId
  join Peaks as p
	on m.Id = p.MountainId
where mc.CountryCode = 'BG' and p.Elevation > 2835
order by p.Elevation desc

-- 13.Count Mountain Ranges
select mc.CountryCode,
		COUNT(m.MountainRange)
from Mountains as m
  join MountainsCountries as mc
	on m.Id = mc.MountainId
where mc.CountryCode in ('BG','US','RU')
group by mc.CountryCode

-- 14.Countries With or Without Rivers
select top 5
		c.CountryName,
		r.RiverName
from Countries as c
  left join CountriesRivers as cr
	on c.CountryCode = cr.CountryCode
  left join Rivers as r
	on cr.RiverId = r.Id
where c.ContinentCode = 'AF'
order by c.CountryName

-- 15.*Continents and Currencies
select result.ContinentCode,
		result.CurrencyCode,
		result.CurrencyUsage
from (select cur.CurrencyCode,
				con.ContinentCode,
				COUNT(c.CountryName) as [CurrencyUsage],
				RANK() over (partition by con.ContinentCode order by COUNT(c.CountryName) desc) as [CountryRank]
		from Countries as c
		  join Currencies as cur
			on c.CurrencyCode = cur.CurrencyCode
		  join Continents as con
			on c.ContinentCode = con.ContinentCode
		group by cur.CurrencyCode, con.ContinentCode
		having COUNT(c.CountryName) > 1) as result
where result.CountryRank = 1
order by result.ContinentCode

SELECT c.ContinentCode, co.CurrencyCode, c.CurrencyUsage FROM
			(SELECT cu.ContinentCode, MAX(cu.CurrencyUsage) AS CurrencyUsage FROM
						(SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS CurrencyUsage
						 FROM Countries AS c
						 GROUP BY c.ContinentCode , c.CurrencyCode) AS cu
						 GROUP BY cu.ContinentCode
						 HAVING MAX(cu.CurrencyUsage) > 1) AS c
	INNER JOIN (SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS CurrencyUsage
		FROM Countries AS c
		GROUP BY c.ContinentCode, c.CurrencyCode) AS co
	ON co.ContinentCode = c.ContinentCode AND co.CurrencyUsage = c.CurrencyUsage
 ORDER BY c.ContinentCode


 select tab1.ContinentCode,
		tab1.CurrencyCode,
		tab1.CurrencyUsage
 from  (SELECT c.ContinentCode, 
		 c.CurrencyCode, 
		 COUNT(c.CurrencyCode) AS CurrencyUsage					 
		FROM Countries AS c
		GROUP BY c.ContinentCode , c.CurrencyCode
		having COUNT(c.CurrencyCode) > 1) as tab1
		join (SELECT c.ContinentCode, c.CurrencyCode, COUNT(c.CurrencyCode) AS CurrencyUsage
		FROM Countries AS c
		GROUP BY c.ContinentCode, c.CurrencyCode) AS tab2
		  on tab1.ContinentCode = tab2.ContinentCode

-- 16.Countries Without any Mountains
select COUNT(c.CountryCode)
from Countries as c
  left join MountainsCountries as mc
	on c.CountryCode = mc.CountryCode
where mc.MountainId is NULL

-- 17.Highest Peak and Longest River by Country
select top 5 c.CountryName,
		MAX(p.Elevation) as [HighestPeakElevation],
		MAX(r.Length) as [LongestRiverLenght]
from Countries as c
  left join CountriesRivers as cr
    on c.CountryCode = cr.CountryCode
  left join Rivers as r
	on cr.RiverId = r.Id
  left join MountainsCountries as mc
    on c.CountryCode = mc.CountryCode 
  left join Mountains as m
	on mc.MountainId = m.Id
  left join Peaks as p
	on m.Id = p.MountainId
group by c.CountryName
order by [HighestPeakElevation] desc,
		 [LongestRiverLenght] desc, c.CountryName

-- 18.*Highest Peak Name and Elevation by Country
--My solution
select top 5 
		res.CountryName,
		ISNULL(res.PeakName, '(no highest peak)') as [HighestPeakName],
		ISNULL(res.Elevation, 0) as [HighestPeakElevation],
		ISNULL(res.MountainRange, '(no mountain)') as [Mountain]
from (select c.CountryName,
	   p.PeakName,
	   p.Elevation,
	   m.MountainRange,
	   RANK() over (partition by c.CountryName order by p.Elevation desc) as [PeakRank]
		from Countries as c
		  left join MountainsCountries as mc
			on c.CountryCode = mc.CountryCode
		  left join Mountains as m
			on mc.MountainId = m.Id
		  left join Peaks as p
			on m.Id = p.MountainId) as res
where res.PeakRank = 1
order by res.CountryName, [HighestPeakName]

-- 18.Sample solution without partition
SELECT TOP 5 mcpr.CountryName,
	   ISNULL(p.PeakName, '(no highest peak)') AS HighestPeakName,
	   ISNULL(mcpr.HighestPeakElevation, 0),
	   ISNULL(m.MountainRange, '(no mountain)') AS Mountain
FROM  (SELECT cpr.CountryName, 
			  MAX(cpr.Elevation) AS HighestPeakElevation
	   FROM (SELECT 
			 	c.CountryName, p.Elevation
			 FROM Countries AS c
			 	LEFT JOIN MountainsCountries AS mc
					ON c.CountryCode = mc.CountryCode
			 	LEFT JOIN Peaks AS p
					ON mc.MountainId = p.MountainId) AS cpr
	   GROUP BY cpr.CountryName) AS mcpr
LEFT JOIN Peaks AS p
	ON p.Elevation = mcpr.HighestPeakElevation
LEFT JOIN Mountains AS m
	ON m.Id = p.MountainId
ORDER BY mcpr.CountryName, HighestPeakName