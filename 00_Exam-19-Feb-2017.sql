
create database Bakery
go

use Bakery
go

create table Countries
(
Id int Identity(1,1) primary key,
Name nvarchar(50) Unique
)
go

create table Customers
(
Id int Identity(1,1) primary key,
FirstName nvarchar(25),
LastName nvarchar(25),
Gender char check (Gender in ('M','F')),
Age int,
PhoneNumber char(10),
CountryId int foreign key references Countries(Id)
)
go

create table Products
(
Id int Identity(1,1) primary key,
Name nvarchar(25) unique,
Description nvarchar(250),
Recipe nvarchar(max),
Price money check (Price >= 0)
)


create table Feedbacks
(
Id int identity(1,1) primary key,
Description nvarchar(255),
Rate decimal(10,2) check(Rate between 0 and 10),
ProductId int foreign key references Products(Id),
CustomerId int  foreign key references Customers(Id)
)
go

create table Distributors
(
Id int identity(1,1) primary key,
Name nvarchar(25) unique,
AddressText nvarchar(30),
Summary nvarchar(200),
CountryId int foreign key references Countries(Id)
)
go

create table Ingredients
(
Id int identity(1,1) primary key,
Name nvarchar(30),
Description nvarchar(200),
OriginCountryId int foreign key references Countries(Id),
DistributorId int foreign key references Distributors(Id)
)
go

create table ProductsIngredients
(
ProductId int foreign key references Products(Id),
IngredientId int foreign key references Ingredients(Id),
constraint PK_Prod_Ing primary key (ProductId,IngredientId)
)
go


--Section 2. DML (15 pts)
--02 Insert
insert into Distributors(Name,CountryId,AddressText,Summary)
values ('Deloitte & Touche',2,'6 Arch St #9757','Customizable neutral traveling'),
	   ('Congress Title',13,'58 Hancock St','Customer loyalty'),
	   ('Kitchen People',1,'3 E 31st St #77','Triple-buffered stable delivery'),
	   ('General Color Co Inc',21,'6185 Bohn St #72','Focus group'),
	   ('Beck Corporation',23,'21 E 64th Ave','Quality-focused 4th generation hardware')
go

insert into Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
values ('Francoise','Rautenstrauch',15,'M','0195698399',5),
	   ('Kendra','Loud',22,'F','0063631526',11),
	   ('Lourdes','Bauswell',50,'M','0139037043',8),
	   ('Hannah','Edmison',18,'F','0043343686',1),
	   ('Tom','Loeza',31,'M','0144876096',23),
	   ('Queenie','Kramarczyk',30,'F','0064215793',29),
	   ('Hiu','Portaro',25,'M','0068277755',16),
	   ('Josefa','Opitz',43,'F','0197887645',17)

--03 Update
update Ingredients
set DistributorId = 35
where Name in ('Bay Leaf', 'Paprika', 'Poppy')


update Ingredients
set OriginCountryId = 14
where OriginCountryId = 8

--04 Delete
delete from Feedbacks
where CustomerId = 14 or ProductId = 5


--Section 3. Querying (40 pts)
--05 Products by Price
select Name,
	   Price,
	   Description
from Products
order by Price desc, Name

--06 Ingredients
select Name,
	   Description,
	   OriginCountryId 
from Ingredients
where OriginCountryId in (1,10,20)
order by Id

--07 Ingredients from Bulgaria and Greece
select top 15 
	   i.Name,
	   Description,
	   c.Name as [CountryName] 
from Ingredients as i
  join Countries as c
    on i.OriginCountryId = c.Id
where c.Name in ('Bulgaria','Greece')
order by i.Name, c.Name

--08 Best Rated Products
select top 10
		p.Name,
		p.Description,
		AVG(f.Rate) as AverageRate,
		COUNT(f.Id) as FeedbacksAmount 
from Products as p
  join Feedbacks as f
    on p.Id = f.ProductId
group by p.Name, p.Description
order by AverageRate desc, FeedbacksAmount desc

--09 Negative Feedback
select f.ProductId
	  ,f.Rate
	  ,f.Description
	  ,f.CustomerId
	  ,c.Age
	  ,c.Gender
from Feedbacks as f
  join Customers as c
    on f.CustomerId = c.Id
where f.Rate < 5.0
order by f.ProductId desc, f.Rate

--10 Customers without Feedback
select CONCAT(c.FirstName, ' ', c.LastName) as [CustomerName],
	   c.PhoneNumber,
	   c.Gender
from Customers as c
  left join Feedbacks as f
    on f.CustomerId = c.Id
where f.Id is null
order by c.Id

--11 Honorable Mentions
select f.ProductId,
	   CONCAT(c.FirstName, ' ', c.LastName) as [CustomerName],
	   f.Description as [FeedbackDescription]
from Customers as c
  right join Feedbacks as f
    on f.CustomerId = c.Id
where c.Id in (select feed.CustomerId
				from Feedbacks as feed
				group by feed.CustomerId
				having COUNT(feed.Id) >= 3)
order by f.ProductId, [CustomerName], f.Id


--12 Customers by Criteria
select cs.FirstName,
	   cs.Age,
	   cs.PhoneNumber
from Customers as cs
  join Countries as ct
    on cs.CountryId = ct.Id
where Age >= 21 
	and (FirstName like '%an%' or RIGHT(PhoneNumber, 2) = '38')
	and not ct.Name = 'Greece'
order by cs.FirstName, cs.Age desc

select Right(PhoneNumber, 2) as endPhoneNumber,
		FirstName
from Customers

--13 Middle Range Distributors
select d.Name as DistributorName
      ,i.Name as IngredientName
      ,prod.Name as ProductName
      ,AVG(f.Rate) as AverageRate
from Feedbacks as f
  join ProductsIngredients as p
    on f.ProductId = p.ProductId
  join Ingredients as i
    on p.IngredientId = i.Id
  join Products as prod
    on p.ProductId = prod.Id
  join Distributors as d
    on i.DistributorId = d.Id
group by d.Name, i.Name, prod.Name
having AVG(f.Rate) between 5 and 8
order by DistributorName, IngredientName, ProductName

--14 The Most Positive Country
select top (1) with ties
	 ct.Name as [CountryName],
	 AVG(f.Rate) as [FeedbackRate]
from Feedbacks as f
  join Customers as cs
    on f.CustomerId = cs.Id
  join Countries as ct
    on cs.CountryId = ct.id
group by ct.Name
order by [FeedbackRate] desc

--15 Country Representative
select topDistCountry.CtName as [CountryName],
	   topDistCountry.DistName as [DistributorName]
from (select c.Name as [CtName], 
		d.Name as [DistName],
		RANK() over (partition by c.Name order by COUNT(i.Name) desc) as [DistRank]
	  from Distributors as d
	    left join Ingredients as i
	  	  on i.DistributorId = d.Id
	    join Countries as c
	  	  on d.CountryId = c.Id
	  group by d.Name, c.Name) as [topDistCountry]
where topDistCountry.DistRank = 1
order by CountryName, DistributorName


--Section 4. Programmability (20 pts)
--16 Customers with Countries
go
create view v_UserWithCountries as
select 
	 CONCAT(c.FirstName, ' ', c.LastName) as CustomerName
	,Age
	,Gender
	,cn.Name as CountryName
from Customers as c
  join Countries as cn
    on c.CountryId = cn.Id
go

--17 Feedback by Product Name
go
create function dbo.udf_GetRating (@ProductName nvarchar(25))
returns varchar(10)
as
begin
	declare @ratingWord varchar(10);

	declare @ratingNum decimal = (select AVG(Rate) 
								  from Products as p
									join Feedbacks as f
									  on p.Id = f.ProductId
								  where p.Name = @ProductName
								  group by f.ProductId)
	if (@ratingNum < 5)
		set @ratingWord = 'Bad'
	else if (@ratingNum between 5 and 8)
		set @ratingWord = 'Average'
	else if (@ratingNum > 8)
		set @ratingWord = 'Good'
	else
		set @ratingWord = 'No rating'
	
	return @ratingWord;
end
go

--18 Send Feedback
go
create proc usp_SendFeedback(@CustomerId int, @ProductId int, 
@Rate decimal(10,2), @Description nvarchar(255))
as
begin tran 
	insert into Feedbacks(CustomerId, ProductId, Rate, Description)
	values (@CustomerId, @ProductId, @Rate, @Description)
	if ((select COUNT(*) from Feedbacks
	where CustomerId = @CustomerId) >= 3)
	begin;
		rollback;
		raiserror('You are limited to only 3 feedbacks per product!', 16, 1);
		return;
	end
commit
go

EXEC usp_SendFeedback 1, 5, 7.50, 'Average experience';
SELECT COUNT(*) FROM Feedbacks WHERE CustomerId = 1 AND ProductId = 5;

--19 Delete Products 
go
create trigger tr_DeleteProduct on Products instead of delete
as
begin 
	declare @ProductId int = (select top 1 Id from deleted);

	update Feedbacks
	set CustomerId = null
	where ProductId = @ProductId
	
	delete ProductsIngredients
	where ProductId = @ProductId

	delete Feedbacks
	where ProductId = @ProductId

	delete Products
	where Id = @ProductId
end

begin tran
	DELETE FROM Products WHERE Id = 7
rollback
go

--20 Products by One Distributor
select p.Name,
		AVG(f.Rate) as [PruductAverageRate],
		d.Name as [DistributorName],
		c.Name as [DistributorCountry]
from Products as p
  left join Feedbacks as f
    on p.Id = f.ProductId
  left join ProductsIngredients as pIng
	on p.Id = pIng.ProductId
  left join Ingredients as i
	on pIng.IngredientId = i.Id
  left join Distributors as d
	on i.DistributorId = d.Id
  left join Countries as c
	on d.CountryId = c.Id
where p.Name in (select p.Name
				from Products as p
				  left join ProductsIngredients as  prodI
					on p.Id = prodI.ProductId
				  left join Ingredients as i
					on i.Id = prodI.IngredientId
				group by p.Id ,p.Name
				having Count(distinct i.DistributorId) = 1)
group by p.Id, p.Name, d.Name, c.Name
order by p.Id