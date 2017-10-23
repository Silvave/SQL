--Section 1.DDL
create database WMS
go

use WMS
go

create table Clients
(
  ClientId int identity(1,1) primary key,
  FirstName varchar(50) not null,
  LastName varchar(50) not null,
  Phone char(12) not null
)
go

create table Mechanics
(
  MechanicId int identity(1,1) primary key,
  FirstName varchar(50) not null,
  LastName varchar(50) not null,
  Address varchar(255) not null
)
go

create table Models
(
  ModelId int identity(1,1) primary key,
  Name varchar(50) unique not null
)
go

create table Jobs
(
  JobId int identity(1,1) primary key,
  ModelId int foreign key references Models(ModelId) not null,
  Status varchar(11) check (Status in ('Pending','In Progress','Finished')) default 'Pending',
  ClientId int foreign key references Clients(ClientId) not null,
  MechanicId int foreign key references Mechanics(MechanicId),
  IssueDate date not null,
  FinishDate date
)
go

create table Orders
(
  OrderId int identity(1,1) primary key,
  JobId int foreign key references Jobs(JobId) not null,
  IssueDate date,
  Delivered bit default 0
)
go

create table Vendors
(
  VendorId int identity(1,1) primary key,
  Name varchar(50) unique not null
)
go

create table Parts
(
  PartId int identity(1,1) primary key,
  SerialNumber varchar(50) unique not null,
  Description varchar(255),
  Price decimal(6,2) check (Price > 0) not null,
  VendorId int foreign key references Vendors(VendorId) not null,
  StockQty int check (StockQty >= 0) default 0
)
go

create table PartsNeeded
(
  JobId int foreign key references Jobs(JobId),
  PartId int foreign key references Parts(partId),
  Quantity int check (Quantity > 0) default 1,
  constraint PK_Job_Part primary key (JobId, PartId)
)
go

create table OrderParts
(
  OrderId int foreign key references Orders(OrderId),
  PartId int foreign key references Parts(PartId),
  Quantity int check (Quantity > 0) default 1,
  constraint PK_Order_Part primary key (OrderId, PartId)
)
go

--Section 2. DML
-- 2. Insert
insert into Clients (FirstName, LastName, Phone) values
('Teri','Ennaco','570-889-5187'),
('Merlyn','Lawler','201-588-7810'),
('Georgene','Montezuma','925-615-5185'),
('Jettie','Mconnell','908-802-3564'),
('Lemuel','Latzke','631-748-6479'),
('Melodie','Knipp','805-690-1682'),
('Candida','Corbley','908-275-8357')
go

insert into Parts (SerialNumber, Description, Price, VendorId) values
('WP8182119','Door Boot Seal',117.86,2),
('W10780048','Suspension Rod',42.81,1),
('W10841140','Silicone Adhesive ',6.77,4),
('WPY055980','High Temperature Adhesive',13.94,3)
go

-- 3. Update
begin tran
	update Jobs
	set MechanicId = 3,
		Status = 'In Progress'
	where Status = 'Pending'
rollback

-- 4. Delete
begin tran
	delete OrderParts
	where OrderId = 19

	delete Orders
	where OrderId = 19
rollback

--Section 3. Querying
-- 5. Clients by NAME
select FirstName,
		LastName,
		Phone
from Clients
order by LastName, ClientId

-- 6. Job Status
select Status,
		IssueDate
from Jobs
where Status <> 'Finished'
order by IssueDate, JobId

-- 7. Mechanic Assignments
select CONCAT(m.FirstName, ' ', m.LastName) as [Mechanic],
		j.Status,
		j.IssueDate
from Mechanics as m
 join Jobs as j
	on m.MechanicId = j.MechanicId
order by m.MechanicId, j.IssueDate, j.JobId

-- 8. Current Clients
select CONCAT(c.FirstName, ' ', c.LastName) as [Client],
		DATEDIFF(day, j.IssueDate, '2017-04-24') as [Days going],
		j.Status
from Clients as c
  join Jobs as j
	on c.ClientId = j.ClientId
where j.Status <> 'Finished'
order by [Days going] desc, c.ClientId

-- 9. Mechanic Performance
select mechStats.Mechanic,
		AVG(mechStats.JobDays) as [Average Days]
from (select m.MechanicId as [MechId],
				CONCAT(m.FirstName, ' ', m.LastName) as [Mechanic],
				DATEDIFF(day,j.IssueDate,j.FinishDate) as [JobDays]
		from Mechanics as m
		  join Jobs as j
			on m.MechanicId = j.MechanicId
		where j.Status = 'Finished') as mechStats
group by mechStats.Mechanic, mechStats.MechId
order by mechStats.MechId

-- 10. Hard Earners
select CONCAT(m.FirstName, ' ', m.LastName) as [Mechanic],
		Count(j.JobId) as [Jobs]
from Mechanics as m
  join Jobs as j
	on m.MechanicId = j.MechanicId
where j.Status <> 'Finished'
group by CONCAT(m.FirstName, ' ', m.LastName), m.MechanicId
having Count(j.JobId) > 1
order by [Jobs] desc, m.MechanicId

-- 11. Available Mechanics
select CONCAT(m.FirstName, ' ', m.LastName) as [Mechanic]
from Mechanics as m
  left join Jobs as j
	on m.MechanicId = j.MechanicId
group by CONCAT(m.FirstName, ' ', m.LastName), m.MechanicId
having COUNT(j.Status) = (select COUNT(JobId) from Jobs where Status = 'Finished' and MechanicId = m.MechanicId)
order by m.MechanicId

insert into Mechanics (FirstName, LastName, [Address]) values
('Pesho', 'Peshov', 'Pirin 7')

-- 12. Parts Cost
select ISNULL(SUM(result.TotalOrderPartsCost), 0) as [Parts Total]
from (select op.OrderId,
			SUM(p.Price * op.Quantity) as [TotalOrderPartsCost]
		from OrderParts as op
		  left join Parts as p
			on op.PartId = p.PartId
		  left join Orders as o
					on op.OrderId = o.OrderId
				where DATEDIFF(day, o.IssueDate, '2017-04-24') between 0 and 21
		group by op.OrderId) as [result]

-- 13. Past Expenses
select j.JobId,
		ISNULL(SUM(p.Price * op.Quantity), 0) as [Total]
from Jobs as j
   left join Orders as o
    on j.JobId = o.JobId
   left join OrderParts as op
    on o.OrderId = op.OrderId
   left join Parts as p
    on op.PartId = p.PartId
where j.Status = 'Finished'
group by j.JobId
order by [Total] desc, j.JobId

-- 14. Model Repair Time
select result.ModelId,
		result.Name,
		CONCAT(ISNULL(AVG(result.DaysToFinishJob), 0), ' days') as [Average Service Time]
from (select m.ModelId,
				m.Name,
				j.JobId,
				DATEDIFF(DAY, j.IssueDate, j.FinishDate) as [DaysToFinishJob]
		from Models as m
		   left join Jobs as j
			on m.ModelId = j.ModelId
		where j.Status = 'Finished') as result
group by result.ModelId, result.Name
order by ISNULL(AVG(result.DaysToFinishJob), 0)

-- 15.Faultiest Model
select top 1 with ties -- doesn't check if there are more than one faultest model
		m.Name,
		COUNT(distinct j.JobId) as [JobCount],
		ISNULL(SUM(p.Price * op.Quantity), 0) as [TotalPriceparts]
from Models as m
   join Jobs as j
	on m.ModelId = j.ModelId
   left join Orders as o
    on j.JobId = o.JobId
   left join OrderParts as op
    on o.OrderId = op.OrderId
   left join Parts as p
    on op.PartId = p.PartId
group by m.Name
order by [JobCount] desc

-- 16. Missing Parts
select  PartId,
		Description,
		Required,
		[In Stock],
		Ordered
from (select p.PartId,
			 p.Description,
			 pn.Quantity as [Required],
			 p.StockQty as [In Stock],
			 ISNULL((select SUM(op.Quantity) from OrderParts as op 
					  left join Orders as o 
					   on op.OrderId = o.OrderId where op.PartId = p.PartId
					 group by op.PartId, o.Delivered
					 having o.Delivered = 0), 0) as [Ordered]
		from Jobs as j
		  join PartsNeeded as pn
			on j.JobId = pn.JobId
		  join Parts as p
			on pn.PartId = p.PartId
		where j.Status <> 'Finished'
		group by p.PartId, p.Description, pn.Quantity, p.StockQty) as [PartsInfo]
where [Required] > [In Stock] + [Ordered]
order by PartId


-- Section 4. Programmability
-- 17. Cost of Order
go
create function udf_GetCost(@JobbId int)
returns decimal(10,2)
as
begin
	declare @TotalCost decimal(10,2) = (select top 1 ISNULL(SUM(p.Price * op.Quantity), 0)
										from Jobs as j
										   left join Orders as o
											on j.JobId = o.JobId
										   left join OrderParts as op
											on o.OrderId = op.OrderId
										   left join Parts as p
											on op.PartId = p.PartId
										where j.JobId = @JobbId
										group by j.JobId)
	return @TotalCost
end
go

-- 18. Place Order
go
create proc usp_PlaceOrder (@JobId int, @PartSerialNumber varchar(20), @Quantity int)
as
begin tran
	declare @isThereOrder int =	(select COUNT(*) from Orders
								where JobId = @JobId and IssueDate is null)

	if (@isThereOrder = 0)
	begin
		--insert into OrderParts (OrderId)
	end
commit
go

-- 19. Detect Delivery
go
create trigger tr_OrderProd on Orders for update
as
begin
	declare @OrderProdId int = (select OrderId from inserted);
	declare @isDelivered bit = (select Delivered from inserted);

	if (@isDelivered = 1)
	begin
		update Parts
		set StockQty += op.Quantity
			from Parts as p
			  join OrderParts as op
				on p.PartId = op.PartId
		    where OrderId = @OrderProdId
	end
end
go

