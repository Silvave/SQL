--Table relations


--09. *Peaks in Rila
use Geography
go

select [MountainRange]
	  ,[PeakName]
	  ,[Elevation]	
from Peaks
	join Mountains on
		Mountains.Id = Peaks.MountainId
where MountainRange = 'Rila'
order by Elevation desc