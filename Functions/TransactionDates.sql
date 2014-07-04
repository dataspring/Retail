

CREATE FUNCTION [Retail].[TransactionDates]
(
    @FromDate smalldatetime,
    @ToDate smalldatetime,
	@CustomerId int,
	@TimeSlice nvarchar(50) = 'ALL'
)
RETURNS @returntable TABLE 
(
	[TimeSliceId] int,
	[TimeSlice] nvarchar(50),
	[Profile] nvarchar(50),
	AgeGroupType nvarchar(50),
	Gender nvarchar(10),
	[Instance] int,
	[ActualDate] smalldatetime,
	[RandomDiff] int,
	[TransactionDate] smalldatetime
)
AS
BEGIN

	DECLARE 
	@AgeGroupType nvarchar(50),
	@Gender nvarchar(10),
	@WeekDay int,
	@MonthDay int,
	@FortnightStart int,
	@BiMonthlyStart int,
	@QuarterMonthDay int,
	@SemiAnnualMonthDay int,
	@AnnualMonthDay int,
	@CeleberatoryBuys int,
	@VacationDays int,
	@TeenageCount int,
	@InfantCount int,
	@ChildCount int,
	@ElderCount int,
	@Christmas int,
	@CNY int,
	@Birthday int,
	@Medical int,
	@Celebratory int,
	---------- variables for random range of date genration from teh give day for each timeslice
	@DayRange int,
	@RandomDayRange int,
	@FromDateStart smalldatetime,
	@FromDateRanged smalldatetime,
	@TimeSliceId int,
	@Duration int,
	@TransactionDate smalldatetime

	---- IF timeslice is 'ALL', always skips daily and inherit timelines for brevity sake
	---- IT timeline is 'Daily' will only do for it

	select
	@AgeGroupType= AgeGroupType,
	@Gender = Gender,
	@WeekDay = ISNULL(WeekDay,1),
	@MonthDay = ISNULL(MonthDay,1),
	@FortnightStart = ISNULL(FortnightStart,1),
	@BiMonthlyStart = ISNULL(BiMonthlyStart,1),
	@QuarterMonthDay = ISNULL(QuarterMonthDay,1),
	@SemiAnnualMonthDay = ISNULL(SemiAnnualMonthDay,1),
	@AnnualMonthDay = ISNULL(AnnualMonthDay,1),
	@CeleberatoryBuys = ISNULL(CeleberatoryBuys,0),
	@VacationDays = ISNULL(VacationDays,0),
	@TeenageCount = ISNULL(TeenageCount,0),
	@InfantCount = ISNULL(InfantCount,0),
	@ChildCount = ISNULL(ChildCount,0),
	@ElderCount = ISNULL(ElderCount,0),
	@Christmas = ISNULL(Christmas,0),
	@CNY = ISNULL(CNY,0),
	@Birthday = ISNULL(Birthday,0),
	@Medical = ISNULL(Medical,0),
	@Celebratory = ISNULL(Celebratory,0)
	from [Retail].[Customer] where Id = @CustomerId;



   ------weekly-------------------------------------------------------------------------------------
   select @TimeSliceId = Id, @DayRange = plusminusrange, @Duration = duration from [Retail].[TimeSlice] where typedesc = 'Weekly'
   SET @FromDateRanged =  DATEADD(dd, @DayRange, @FromDate)   
	Set @FromDateStart = 
	   CASE 
		  WHEN (datepart(dw,@FromDateRanged) = @WeekDay) THEN @FromDateRanged 
		  WHEN (datepart(dw,@FromDateRanged) > @WeekDay) THEN @FromDateRanged - (datepart(dw,@FromDateRanged)-@WeekDay)
		  WHEN (datepart(dw,@FromDateRanged) < @WeekDay) THEN @FromDateRanged + (@WeekDay-datepart(dw,@FromDateRanged))
	   END 
	   	---------decide the start date acoordingly & proceed--------------------------------------	
	WHILE @FromDateStart <= @ToDate
	BEGIN
		SET @RandomDayRange = [Retail].[random_range_with_default](-1 * @DayRange, @DayRange, 0, 5);
		SET @TransactionDate = DATEADD(dd, @RandomDayRange, @FromDateStart);
		INSERT @returntable (TimeSliceId,TimeSlice, Profile, AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
			Select @TimeSliceId, 'Weekly', @AgeGroupType+@Gender, @AgeGroupType, @Gender, 0, @FromDateStart, @RandomDayRange, @TransactionDate
		----include infant stuff--------------------------------------------
		IF @InfantCount > 0
		BEGIN
			INSERT @returntable (TimeSliceId,TimeSlice, Profile, AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
			Select @TimeSliceId, 'Weekly', 'Infant', 'All', 'All', @InfantCount, @FromDateStart, @RandomDayRange, @TransactionDate
		END
		----include Child stuff--------------------------------------------
		IF @ChildCount > 0
		BEGIN
			INSERT @returntable (TimeSliceId,TimeSlice, Profile, AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
			Select @TimeSliceId, 'Weekly', 'Child', 'All', 'All', @ChildCount, @FromDateStart, @RandomDayRange, @TransactionDate
		END	

		Set @FromDateStart = @FromDateStart + @Duration 
	END

	------fortnightly-------------------------------------------------------------------------------------
	select @TimeSliceId = Id, @DayRange = plusminusrange, @Duration = duration from [Retail].[TimeSlice] where typedesc = 'Fortnightly'
	SET @FromDateRanged =  DATEADD(dd, @DayRange, @FromDate) 
	Set @FromDateStart = 
	   CASE 
		  WHEN (datepart(dd,@FromDateRanged) = @FortnightStart) THEN @FromDateRanged 
		  WHEN (datepart(dd,@FromDateRanged) > @FortnightStart) THEN DATEFROMPARTS(DATEPART(yyyy, DATEADD(mm, 1, @FromDateRanged)), DATEPART(mm, DATEADD(mm, 1, @FromDateRanged)), @FortnightStart+@DayRange)
		  WHEN (datepart(dd,@FromDateRanged) < @FortnightStart) THEN DATEFROMPARTS(DATEPART(yyyy, @FromDateRanged), DATEPART(mm, @FromDateRanged), @FortnightStart+@DayRange)
	   END 
	   ---------decide the start date acoordingly & proceed--------------------------------------	
	WHILE @FromDateStart <= @ToDate
	BEGIN
		SET @RandomDayRange = [Retail].[random_range_with_default](-1 * @DayRange, @DayRange, 0, 5);
		SET @TransactionDate = DATEADD(dd, @RandomDayRange, @FromDateStart);
		INSERT @returntable (TimeSliceId,TimeSlice, Profile, AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
			Select @TimeSliceId, 'Fortnightly', @AgeGroupType+@Gender, @AgeGroupType, @Gender, 0, @FromDateStart, @RandomDayRange, @TransactionDate

		----include infant stuff--------------------------------------------
		IF @InfantCount > 0
		BEGIN
			INSERT @returntable (TimeSliceId,TimeSlice, Profile, AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
			Select @TimeSliceId, 'Fortnightly', 'Infant', 'All', 'All', @InfantCount, @FromDateStart, @RandomDayRange, @TransactionDate
		END
		----include Child stuff--------------------------------------------
		IF @ChildCount > 0
		BEGIN
			INSERT @returntable (TimeSliceId,TimeSlice, Profile, AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
			Select @TimeSliceId, 'Fortnightly', 'Child', 'All', 'All', @ChildCount, @FromDateStart, @RandomDayRange, @TransactionDate
		END

		Set @FromDateStart = @FromDateStart + @Duration 
	END

	------monthly, bimonthly, quarterly, semi-annual, annual-------------------------------------------------------------------------------------
	DECLARE @monthtypes int = 5, @TimeSliceMonth nvarchar(50), @MonthTypeDay int
	WHILE @monthtypes <= 9
	BEGIN

	   Set @MonthTypeDay = 
	   CASE 
		  WHEN @monthtypes = 5 THEN @MonthDay 
		  WHEN @monthtypes = 6 THEN @BiMonthlyStart 
		  WHEN @monthtypes = 7 THEN @QuarterMonthDay 
		  WHEN @monthtypes = 8 THEN @SemiAnnualMonthDay 
		  WHEN @monthtypes = 9 THEN @AnnualMonthDay 
	   END 

		select @TimeSliceId = Id, @TimeSliceMonth = typedesc, @DayRange = plusminusrange, @Duration = duration from [Retail].[TimeSlice] where Id = @monthtypes

		SET @FromDateRanged =  DATEADD(dd, @DayRange, @FromDate) 
		Set @FromDateStart = 
			CASE 
				WHEN (datepart(dd,@FromDateRanged) = @MonthTypeDay) THEN @FromDateRanged 
				WHEN (datepart(dd,@FromDateRanged) > @MonthTypeDay) THEN DATEADD(dd, @DayRange, DATEFROMPARTS(DATEPART(yyyy, DATEADD(mm, 1, @FromDateRanged)), DATEPART(mm, DATEADD(mm, 1, @FromDateRanged)), @MonthDay))
				WHEN (datepart(dd,@FromDateRanged) < @MonthTypeDay) THEN DATEADD(dd, @DayRange, DATEFROMPARTS(DATEPART(yyyy, @FromDateRanged), DATEPART(mm, @FromDateRanged), @MonthDay))
				--WHEN (datepart(dd,@FromDateRanged) > @MonthTypeDay) THEN DATEFROMPARTS(DATEPART(yyyy, DATEADD(mm, 1, @FromDateRanged)), DATEPART(mm, DATEADD(mm, 1, @FromDateRanged)), @MonthDay+@DayRange)
				--WHEN (datepart(dd,@FromDateRanged) < @MonthTypeDay) THEN DATEFROMPARTS(DATEPART(yyyy, @FromDateRanged), DATEPART(mm, @FromDateRanged), @MonthDay+@DayRange)
			END 
			---------decide the start date acoordingly & proceed--------------------------------------
	
		WHILE @FromDateStart <= @ToDate
		BEGIN
			SET @RandomDayRange = [Retail].[random_range_with_default](-1 * @DayRange, @DayRange, 0, 4);
			SET @TransactionDate = DATEADD(dd, @RandomDayRange, @FromDateStart);
			INSERT @returntable (TimeSliceId,TimeSlice, Profile,AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
				Select @TimeSliceId, @TimeSliceMonth, @AgeGroupType+@Gender, @AgeGroupType, @Gender, @InfantCount, @FromDateStart, @RandomDayRange, @TransactionDate
			Set @FromDateStart = DATEADD(mm, @Duration, @FromDateStart)  
		END

		IF @monthtypes = 5 OR @monthtypes = 7 --- do this for monthly and quarterly
		BEGIN
			----include infant stuff--------------------------------------------
			IF @InfantCount > 0
			BEGIN
				INSERT @returntable (TimeSliceId,TimeSlice, Profile,AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
					Select @TimeSliceId, @TimeSliceMonth, 'Infant', 'All', 'All', @InfantCount, @FromDateStart, @RandomDayRange, @TransactionDate
			END
			----include Child stuff--------------------------------------------
			IF @ChildCount > 0
			BEGIN
				INSERT @returntable (TimeSliceId,TimeSlice, Profile,AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
					Select @TimeSliceId, @TimeSliceMonth, 'Child', 'All', 'All', @ChildCount, @FromDateStart, @RandomDayRange, @TransactionDate
			END
		END
		
		Set @monthtypes = @monthtypes + 1 
	END

	------Periodic-------------------------------------------------------------------------------------
	DECLARE @yearOccasion int
	select @TimeSliceId = Id, @DayRange = plusminusrange, @Duration = duration from [Retail].[TimeSlice] where typedesc = 'Periodic'

	IF @CNY > 0 
	BEGIN
		SET @yearOccasion = datepart(yyyy,@FromDate)
		WHILE @yearOccasion <= datepart(yyyy,@ToDate)
		BEGIN
			Select @FromDateStart = FromDate from [Retail].[SeasonalBuys] where Year = @yearOccasion and Occasion = 'CNY'
			SET @FromDateRanged =  DATEADD(dd, -1 * @DayRange, @FromDateStart)
			IF @FromDateRanged > @FromDate AND @FromDateRanged < @ToDate
			BEGIN
				SET @RandomDayRange = -1 * [Retail].[random_range](1, @DayRange)
				SET @TransactionDate = DATEADD(dd, @RandomDayRange, @FromDateStart);
				INSERT @returntable (TimeSliceId,TimeSlice,Profile,AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
				Select @TimeSliceId, 'Periodic', 'CNY', 'All', 'All', 1, @FromDateStart, @RandomDayRange, @TransactionDate
			END
			SET @yearOccasion = @yearOccasion + 1
		END
	END


	IF @Christmas > 0 
	BEGIN
		SET @yearOccasion = datepart(yyyy,@FromDate)
		WHILE @yearOccasion <= datepart(yyyy,@ToDate)
		BEGIN
			Select @FromDateStart = FromDate from [Retail].[SeasonalBuys] where Year = @yearOccasion and Occasion = 'Christmas'
			SET @FromDateRanged =  DATEADD(dd, -1 * @DayRange, @FromDateStart)
			IF @FromDateRanged > @FromDate AND @FromDateRanged < @ToDate
			BEGIN
				SET @RandomDayRange = -1 * [Retail].[random_range](1, @DayRange)
				SET @TransactionDate = DATEADD(dd, @RandomDayRange, @FromDateStart);
				INSERT @returntable (TimeSliceId,TimeSlice,Profile,AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
				Select @TimeSliceId, 'Periodic', 'Christmas', 'All','All', 1, @FromDateStart, @RandomDayRange, @TransactionDate
			END
			SET @yearOccasion = @yearOccasion + 1
		END
	END


	------birthday, medical, celebratory -------------------------------------------------------------------------------------
	select @TimeSliceId = Id, @DayRange = plusminusrange, @Duration = duration from [Retail].[TimeSlice] where typedesc = 'Once'
	DECLARE @adhoctypes int = 1 --birthday 1, medical 2, celebratory 3, 
	DECLARE @LoopCount int, @LoopVariable int = 1, @LoopAgeGroupType nvarchar(50), @yearloopdate smalldatetime

	--loop for ------birthday, medical, celebratory
	WHILE @adhoctypes <= 3
	BEGIN
		SET @LoopCount = 
		CASE
			WHEN @adhoctypes = 1 THEN @Birthday + @ChildCount + @TeenageCount
			WHEN @adhoctypes = 2 THEN @Medical
			WHEN @adhoctypes = 3 THEN @Celebratory
		END
		SET @LoopAgeGroupType = 
		CASE
			WHEN @adhoctypes = 1 THEN 'Birthday'
			WHEN @adhoctypes = 2 THEN 'Medical'
			WHEN @adhoctypes = 3 THEN 'Party'
		END

		--loop for ---every year in between the date range
		SET @yearloopdate = @FromDate
		WHILE @yearloopdate <= @ToDate
		BEGIN

			--loop for ------individual count of birthday, medical, celebratory
			SET @LoopVariable = 1
			WHILE @LoopVariable <= @LoopCount
			BEGIN
				SET @FromDateStart = Retail.random_date(@yearloopdate, DATEADD(yy, 1, @yearloopdate))
				SET @RandomDayRange = [Retail].[random_range](0, @DayRange);
				SET @TransactionDate = DATEADD(dd, @RandomDayRange, @FromDateStart);
				INSERT @returntable (TimeSliceId,TimeSlice,Profile,AgeGroupType, Gender ,Instance, [ActualDate], [RandomDiff], TransactionDate)
					Select @TimeSliceId, 'Once', @LoopAgeGroupType, 'All','All', 1, @FromDateStart, @RandomDayRange, @TransactionDate

				--loop for ------individual count of birthday, medical, celebratory
				SET @LoopVariable = @LoopVariable + 1
			END
			--loop for ---every year in between the date range
			Set @yearloopdate = DATEADD(mm, 12, @yearloopdate)  
		END

		--loop for ------birthday, medical, celebratory
		SET @adhoctypes = @adhoctypes + 1
	END


    RETURN 
END


--SELECT RandomdIFF, count(*) FROM [Retail].[TransactionDates] ('2011-12-01', '2012-11-30', 1) group BY RandomdIFF

--SELECT * FROM [Retail].[TransactionDates] ('2011-01-02', '2012-12-31', 416, 'ALL') 

--DECLARE @startdate smalldatetime
--SET @startdate = '2013-12-12'
--SET @startdate = @startdate + 0
--PRINT @startdate

--select DATEFROMPARTS(2013, 12, 23)
--Select  * from [Retail].[Customer] c where infantcount = 1 and id = 416


