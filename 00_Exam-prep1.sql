create database AMS
go
use AMS

--01. Data definition
create table Flights
(
FlightID int primary key,
DepartureTime datetime not null,
ArrivalTime datetime not null,
Status varchar(9) check (Status in ('Departing', 'Delayed', 'Arrived', 'Cancelled')),
OriginAirportID	int foreign key references Airports(AirportID),
DestinationAirportID int foreign key references Airports(AirportID),
AirlineID int foreign key references Airlines(AirlineID)
)

create table Tickets
(
TicketID int primary key,
Price numeric(8,2) not null,
Class varchar(6) check (Class in ('First', 'Second', 'Third')),
Seat varchar(5) not null,
CustomerID int foreign key references Customers(CustomerID),
FlightID int foreign key references Flights(FlightID)
)

--Section 2: Database Manipulations
--02. Database Manipulations
insert into Flights 
values 
(1,'2016-10-13 06:00 AM','2016-10-13 10:00 AM','Delayed',1,4,1),
(2,'2016-10-12 12:00 PM','2016-10-12 12:01 PM','Departing',1,3,2),
(3,'2016-10-14 03:00 PM','2016-10-20 04:00 AM','Delayed',4,2,4),
(4,'2016-10-12 01:24 PM','2016-10-12 4:31 PM','Departing',3,1,3),
(5,'2016-10-12 08:11 AM','2016-10-12 11:22 PM','Departing',4,1,1),
(6,'1995-06-21 12:30 PM','1995-06-22 08:30 PM','Arrived',2,3,5),
(7,'2016-10-12 11:34 PM','2016-10-13 03:00 AM','Departing',2,4,2),
(8,'2016-11-11 01:00 PM','2016-11-12 10:00 PM','Delayed',4,3,1),
(9,'2015-10-01 12:00 PM','2015-12-01 01:00 AM','Arrived',1,2,1),
(10,'2016-10-12 07:30 PM','2016-10-13 12:30 PM','Departing',2,1,7)

insert into Tickets
values
(1,3000.00,'First','233-A',3,8),
(2,1799.90,'Second','123-D',1,1),
(3,1200.50,'Second','12-Z',2,5),
(4,410.68,'Third','45-Q',2,8),
(5,560.00,'Third','201-R',4,6),
(6,2100.00,'Second','13-T',1,9),
(7,5500.00,'First','98-O',2,7)

--03 Update Arrived Flights
update Flights
set AirlineID = 1
where Status = 'Arrived'

--04 Update Tickets
update Tickets
set Price *= 1.5
where FlightID in (select FlightID from Flights
				   where AirlineID = (select top 1 AirlineID from Airlines
				   order by Rating desc))

--05 Table Creation
create table CustomerReviews
(
ReviewID int primary key,
ReviewContent varchar(255) not null,
ReviewGrade int check (ReviewGrade between 0 and 10),
AirlineID int foreign key references Airlines(AirlineID),
CustomerID int foreign key references Customers(CustomerID)
)

create table CustomerBankAccounts
(
AccountID int primary key,
AccountNumber varchar(10) unique not null,
Balance numeric(10,2) not null,
CustomerID int foreign key references Customers(CustomerID)
)

--06 Fill the new Tables with Data
insert into CustomerReviews
values (1,'Me is very happy. Me likey this airline. Me good.',10,1,1),
(2,'Ja, Ja, Ja... Ja, Gut, Gut, Ja Gut! Sehr Gut!',10,1,4),
(3,'Meh...',5,4,3),
(4,'Well Ive seen better, but Ive certainly seen a lot worse...',7,3,5)

insert into CustomerBankAccounts
values (1,'123456790',2569.23,1),
(2,'18ABC23672',14004568.23,2),
(3,'F0RG0100N3',19345.20,5)

--Section 3: Querying
--07 Extract All Tickets
select TicketID,
	   Price,
	   Class,
	   Seat 
from Tickets
order by TicketID

--08 Extract All Customers 
select CustomerID,
	   CONCAT(FirstName, ' ', LastName) as [FullName],
	   Gender
from Customers
order by FullName, CustomerID

--09 Extract Delayed Flights 
select FlightID,
	   DepartureTime,
	   ArrivalTime
from Flights
where Status = 'Delayed'
order by FlightID

--10 Extract Top 5 Most Highly Rated Airlines which have any Flights
-- 1-st solution
select top 5  
	   a.AirlineID,
	   AirlineName,
	   Nationality,
	   Rating
from Airlines as a
where a.AirlineID in (select AirlineID from Flights as f
					  group by f.AirlineID
					  having COUNT(f.FlightID) > 0)
order by Rating desc, a.AirlineID

-- 2-nd solution
select distinct top 5 
	   a.AirlineID,
	   AirlineName,
	   Nationality,
	   Rating from Airlines as a
  right join Flights as f
	on a.AirlineID = f.AirlineID
	order by Rating desc

--11 Extract all Tickets with price below 5000, for First Class
select TicketID,
	   a.AirportName as [Destination],
	   CONCAT(FirstName, ' ', LastName) as [CustomerName] 
 from Tickets as t
 join Customers as c
 on t.CustomerID = c.CustomerID
 and Price < 5000
 join Flights as f
 on t.FlightID = f.FlightID
 and class = 'First'
 join Airports as a
 on a.AirportID = f.DestinationAirportID
order by TicketID

--12 Extract all Customers which are departing from their Home Town
select c.CustomerID, 
	   CONCAT(c.FirstName, ' ', c.LastName) as [FullName],	
	   t.TownName as HomeTown 
from Customers as c
 join Towns as t
   on c.HomeTownID = t.TownID
 join Tickets as tic
   on c.CustomerID = tic.CustomerID
 join Flights as f
   on tic.FlightID = f.FlightID
   and f.Status = 'Departing'
 join Airports as a
   on f.OriginAirportID = a.AirportID
   and a.TownID = c.HomeTownID
order by c.CustomerID

--13 Extract all Customers which will fly
select distinct c.CustomerID, 
	   CONCAT(c.FirstName, ' ', c.LastName) as [FullName],
	   DATEDIFF(year, c.DateOfBirth, '2016-01-01') as [Age]
from Tickets as t
 join Customers as c
   on c.CustomerID = t.CustomerID
 join Flights as f
   on t.FlightID = f.FlightID
   and f.Status = 'Departing'
   order by Age, c.CustomerID

--14 Extract Top 3 Customers which have Delayed Flights
select top 3 c.CustomerID,
		CONCAT(c.FirstName, ' ', c.LastName) as FullName,	
		t.Price as TicketPrice,	
		a.AirportName as Destination 
from Tickets as t
  join Flights as f
    on t.FlightID = f.FlightID
	and f.Status = 'Delayed'
  join Customers as c
    on t.CustomerID = c.CustomerID
  join Airports as a
    on f.DestinationAirportID = a.AirportID
order by Price desc, c.CustomerID

--15 Extract the Last 5 Flights, which are departing
select f.FlightID,
		DepartureTime,
		ArrivalTime,
		orig.AirportName as Origin,
		dest.AirportName as Destination
from (select top 5 * from Flights
	  where Status = 'Departing'
	  order by DepartureTime desc) as f
 join Airports as orig
   on f.OriginAirportID = orig.AirportID
 join Airports as dest
   on f.DestinationAirportID = dest.AirportID
order by DepartureTime, f.FlightID

--16 Extract all Customers below 21 years...
select distinct c.CustomerID,
	   CONCAT(c.FirstName, ' ', c.LastName) as FullName,
	   DATEDIFF(year, c.DateOfBirth, '2016-01-01') as Age 
from (select * from Customers
	  where DATEDIFF(year, DateOfBirth, '2016-01-01') < 21) as c
 join Tickets as t
   on t.CustomerID = c.CustomerID
 join Flights as f
   on f.FlightID = t.FlightID
   and f.Status = 'Arrived'
--group by c.CustomerID, /*instead of distinct*/
-- CONCAT(c.FirstName, ' ', c.LastName),
-- DATEDIFF(year, c.DateOfBirth, '2016-01-01')
--having COUNT(t.TicketID) > 0
order by Age desc, c.CustomerID

--17 Extract all Airports and the Count of People departing from them
select a.AirportID,
	   a.AirportName,
	   COUNT(t.CustomerID) as Passengers 
from Airports as a
  join Flights as f
    on f.OriginAirportID = a.AirportID
	and f.Status = 'Departing'
  join Tickets as t
    on t.FlightID = f.FlightID
group by a.AirportID,
	   a.AirportName
order by a.AirportID

--Section 4: Programmability
--01 Review Registering Procedure
go
create proc usp_SubmitReview (@CustomerID int, @ReviewContent varchar(max),
							@ReviewGrade int,@AirlineName varchar(30))
as
begin tran
	declare @foundAirlineId int = (select AirlineID 
								from Airlines
								where AirlineName = @AirlineName);
	if (@foundAirlineId is null)
	begin
		rollback;
		throw 50001, 'Airline does not exist.', 1;
		return;
	end
	
	declare @reviewIdNum int = ISNULL((select MAX(ReviewID)
									   from CustomerReviews), 0) + 1;

	insert into CustomerReviews(ReviewID,CustomerID,ReviewContent,ReviewGrade,AirlineID)
	values (@reviewIdNum, @CustomerID, @ReviewContent, @ReviewGrade, @foundAirlineId)
commit
go

exec usp_SubmitReview 5, 'Bla bla', 1, 'Royal Airline';

--02 Ticket Purchase Procedure
go
create proc usp_PurchaseTicket (@CustomerID int,
								@FlightID int,
								@TicketPrice numeric(8,2),
								@Class varchar(6),
								@Seat varchar(5))
as
begin tran
	declare @balance numeric(10,2) = (select Balance
									  from CustomerBankAccounts
									  where CustomerID = @CustomerID);
	
	if (@TicketPrice > @balance or @balance is null)
	begin
		rollback;
		throw 50001, 'Insufficient bank account balance for ticket purchase.', 1;
		return;
	end

	declare @TicketId int = ISNULL((select MAX(TicketID)
							 from Tickets), 0) + 1;

	insert into Tickets(TicketID,Price,Class,Seat,CustomerID,FlightID)
	values (@TicketId, @TicketPrice, @Class, @Seat,@CustomerID,@FlightID)

	update CustomerBankAccounts
	set Balance -= @TicketPrice
	where CustomerId = @CustomerID
commit
go

exec usp_PurchaseTicket 1,1,2001.00, 'First', 'ZZZ-3Z';

select * from Tickets
select * from CustomerBankAccounts

--Section 5. Bonus
--Update Trigger
create table ArrivedFlights
(
FlightID int primary key,
ArrivalTime datetime not null,
Origin varchar(50) not null,
Destination varchar(50) not null,
Passengers int not null
)

go
create trigger tr_ArrivedFlights on Flights for UPDATE
as
	insert into ArrivedFlights (FlightID,ArrivalTime,Origin,Destination,Passengers)
		select i.FlightID
			  ,i.ArrivalTime
			  ,orig.AirportName as Origin
			  ,dest.AirportName as Destination
			  ,(select COUNT(*) from Tickets
			    where FlightID = i.FlightID) as Passengers
		from inserted as i
		  join Airports as orig
			on i.OriginAirportID = orig.AirportID
		  join Airports as dest
			on i.DestinationAirportID = dest.AirportID
		  join Tickets as t
			on i.FlightID = t.FlightID
go

begin tran
	update Flights
	set Status = 'Arrived'
	where FlightID = 5

	select * from Flights
	where FlightID = 5

	select * from ArrivedFlights
rollback

select * from Flights
where FlightID = 1

select COUNT(*) from Tickets
where FlightID = 2
