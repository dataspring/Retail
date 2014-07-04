
CREATE PROCEDURE [Retail].[ProductMatrix] 
    @HouseholdType nvarchar(50),
	@Profile nvarchar(50),
    @AgeGroupType nvarchar(50),
	@Gender nvarchar(10),
	@RegularRandom nvarchar(10),
	@iSetPercentile int = 5,
	@ExculdeList ProdExcludeList READONLY
AS

	DECLARE @ComputedBuyMatrix TABLE
			(TimeSliceId int,
			TimeSlice nvarchar(50),
			TopCategoryId int,
			TopCategory nvarchar(200),
			CategoryId int,
			Category nvarchar(200),
			ProductId int,
			ProdQty int)

	DECLARE @iBuyCategory int = 1, @totalBuyMatrix int = 0,
			@iProdCount int, @HouseHoldPercentile int, @iProdCountCheck int, @iPercentile int, @iProdQty int

	DECLARE  
			@TimeSliceId int,
			@TimeSlice nvarchar(50),
			@TopCategoryId int,
			@TopCategory nvarchar(200),
			@CategoryId int,
			@Category nvarchar(200),
			@RegularProdCount int,
			@RegularProdQty int,
			@RandomProdCount int,
			@RandomProdCountUpperBound int,
			@RandomProdQty int,
			@RandomProdQtyUpperBound int

	DECLARE @Weekly int,
			@Fortnightgly int,
			@Monthly int,
			@Quarterly int,
			@SemiAnnual int,
			@Annual int,
			@Daily int,
			@Once int,
			@Periodic int


	IF LEN(LTRIM(RTRIM(@Profile))) <= 0
		 SET @Profile = @AgeGroupType + @Gender

	Select row_number() OVER(ORDER BY Id ASC) as rowint, * into #tmpBuyMatrix from [Retail].[AgeGenderBuyMatrix] where Age = @AgeGroupType and Gender = @Gender and Profile = @Profile

	SELECT @totalBuyMatrix = Count(*) from #tmpBuyMatrix

	--Select @totalBuyMatrix

	WHILE @iBuyCategory <= @totalBuyMatrix
	BEGIN
		Select  @TimeSliceId = ISNULL(TimeSliceId,0),
				@TimeSlice = ISNULL(TimeSlice,''),
				@TopCategoryId = ISNULL(TopCategoryId,0),
				@TopCategory = ISNULL(TopCategory,''),
				@CategoryId = ISNULL(CategoryId,0),
				@Category = ISNULL(Category,''),
				@RegularProdCount = ISNULL(RegularProdCount,0),
				@RegularProdQty = ISNULL(RegularProdQty,0),
				@RandomProdCount = ISNULL(RandomProdCount,0),
				@RandomProdCountUpperBound = ISNULL(RandomProdCountUpperBound,0),
				@RandomProdQty = ISNULL(RandomProdQty,0),
				@RandomProdQtyUpperBound = ISNULL(RandomProdQtyUpperBound,0)
				from #tmpBuyMatrix where rowint = @iBuyCategory

		--Select @Category, @TimeSlice where @iBuyCategory = 28

		IF @TimeSlice = 'Inherit'
			BEGIN
				Select 
					@Weekly = ISNULL(Weekly,0),
					@Fortnightgly = ISNULL(Fortnightgly,0),
					@Monthly = ISNULL(Monthly,0),
					@Quarterly = ISNULL(Quarterly,0),
					@SemiAnnual = ISNULL(SemiAnnual,0),
					@Annual = ISNULL(Annual,0),
					@Daily = ISNULL(Daily,0),
					@Once = 0,
					@Periodic = 0
					FROM [Retail].[CategorySchedule] where Category = @Category;
				
				--Select @Weekly,@Fortnightgly,@Monthly,@Quarterly,@SemiAnnual,@Annual,@Daily  where @iBuyCategory = 28
				--Select * FROM [Retail].[CategorySchedule] where RTRIM(LTRIM(Category)) = RTRIM(LTRIM(@Category))  and @iBuyCategory = 28

				set @TimeSlice = 
				case
					--WHEN @Periodic > 1 Then 'Periodic'
					--WHEN @Once > 1 Then 'Once'
					WHEN @Annual > 0 THEN 'Annual'
					WHEN @SemiAnnual > 0 THEN 'SemiAnnual'
					WHEN @Quarterly > 0 THEN 'Quarterly'
					WHEN @Monthly > 0 THEN 'Monthly'
					WHEN @Fortnightgly > 0 THEN 'Fortnightly'
					WHEN @Weekly > 0 THEN 'Weekly'
					WHEN @Daily > 0 THEN 'Daily'
				end

				Select @TimeSliceId = [Id] from [Retail].[TimeSlice] where [TypeDesc] = @TimeSlice

			END


		IF @RegularRandom = 'Regular'
			SELECT @iProdCount = @RegularProdCount, @iProdQty = @RegularProdQty
		ELSE
			SELECT @iProdCount = @RandomProdCount, @iProdQty = @RandomProdQty


		-- iterate for each pentile to get the required product count at random, if not reduce the pentile point to a lower value until 1
		SELECT @HouseHoldPercentile = Id from [Retail].[Household] where TypeDesc = @HouseholdType
		SELECT @iPercentile = ISNULL(@iSetPercentile, 5), @HouseHoldPercentile = ISNULL(@HouseHoldPercentile, 1)


		--Select @TimeSlice, @TimeSliceId, @iProdCount, @iPercentile, @HouseHoldPercentile, @Category, 1, @iProdCountCheck

		WHILE @iPercentile >= 1 AND @TimeSlice <> 'Inherit' AND @iProdCount > 0
		BEGIN
			
			--call a sql that returns random product-----------------------------
			Select @iProdCountCheck = Count(*) from
				(SELECT fc.Id ,NTILE(@iPercentile) OVER (order by AveragePrice) Pentile
						FROM [BigTestData].[Retail].[FactualProduct] fc
						where fc.Category = @Category and not fc.Id in (Select Id from @ExculdeList)) prod
				where Pentile = @HouseHoldPercentile


			--Select @iProdCountCheck, @iProdCount, @iPercentile, @HouseHoldPercentile, @Category, 1
			

			IF @iProdCountCheck >= @iProdCount
			BEGIN

				INSERT INTO @ComputedBuyMatrix 
				Select  TOP (@iProdCount)  @TimeSliceId, @TimeSlice, @TopCategoryId, @TopCategory, @CategoryId, @Category, Id, @iProdQty from
						(SELECT fc.Id
							  ,NTILE(@iPercentile) OVER (order by AveragePrice) Pentile
						  FROM [BigTestData].[Retail].[FactualProduct] fc 
						  where fc.Category = @Category and not fc.Id in (Select Id from @ExculdeList)) prod
						  where Pentile = @HouseHoldPercentile
						  order by newid()
				BREAK;
			END
			------------------------------------------------------------------
			IF @iPercentile = @HouseHoldPercentile SET @HouseHoldPercentile = @HouseHoldPercentile - 1
			---------------
			SET @iPercentile = @iPercentile - 1
		END


		SET @iBuyCategory = @iBuyCategory + 1
	END

	Select * from @ComputedBuyMatrix



--DECLARE @ExculdeList ProdExcludeList
--INSERT @ExculdeList (Id) Values(89987)
--exec Retail.ProductMatrix  'Lower', '', 'Mid', 'Male', 'Regular', 5, @ExculdeList



--DECLARE @Exculde ProdExcludeList
--INSERT @Exculde (Id) Values(89987)
--exec Retail.ProductMatrix 'Lower', 'Birthday', 'All', 'All', 'hhh', 5, @Exculde


--Declare @i int = 2
--Select TOP (@i) * from [Retail].[CategorySchedule]


--Select * from
--(SELECT [Id]
--      ,[FactualId]
--      ,[Brand]
--      ,[ProductName]
--      ,[AveragePrice]
--	  ,RANK() OVER(ORDER BY AveragePrice) Rnk
--	  ,NTILE(5) OVER (order by AveragePrice) Pentile
--  FROM [BigTestData].[Retail].[FactualProduct] fc
--  where fc.Category  = 'Glass Cleaners') prod
--  where Pentile = 2
--  order by newid()
  
