CREATE function [Retail].[Random_Date] ( @fromDate smalldatetime, @toDate smalldatetime) returns smalldatetime
as
begin

 declare @days_between int
 declare @days_rand int

 set @days_between = datediff(day,@fromDate,@toDate)
 select @days_rand  = CAST(v.rndResult * 10000 AS INT) % @days_between from rndView v

 --set @days_rand  = cast(RAND()*10000 as int)  % @days_between

 return dateadd( day, @days_rand, @fromDate )
end
