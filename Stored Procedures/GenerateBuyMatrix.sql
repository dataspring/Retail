
CREATE PROCEDURE [Retail].[GenerateBuyMatrix] 
    @FromDate smalldatetime,
    @ToDate smalldatetime,
	@CustomerId int,
	@ForTimeSlice nvarchar(50) = 'ALL',
	@BatchRun nvarchar(50) = ''
AS
	SET NOCOUNT ON

	IF @BatchRun = ''
	BEGIN
		SET @BatchRun = CAST(Retail.GetTicks() AS nvarchar(50));
	END


	SELECT ROW_NUMBER() OVER(ORDER BY TransactionDate ASC) AS rowint, * into #tmpTrnDates FROM [Retail].[TransactionDates] (@FromDate, @ToDate, @CustomerId, @ForTimeSlice) 

	--consolidate transaction dates which are nearer to weekly purchases immediatley after one day----------------
	Update #tmpTrnDates set TransactionDate = u.TransactionDate from
	(Select * from
		(select   rowint, tIMESLICE,
				 TransactionDate,
				 DATEDIFF(dd, TransactionDate,(lead(TransactionDate) over (order by rowint)))  diff
		from     #tmpTrnDates
		) sbt WHERE sbt.TimeSlice = 'Weekly' and 
		sbt.diff = 1) u INNER JOIN #tmpTrnDates d 
		ON d.rowint = u.rowint+1

	--consolidate transaction dates which are nearer to weekly purchases immediatley after one day----------------
	Update #tmpTrnDates set TransactionDate = u.TransactionDate from
	(Select * from
		(select   rowint, tIMESLICE,
				 TransactionDate,
				 DATEDIFF(dd, TransactionDate,(lag(TransactionDate) over (order by rowint)))  diff
		from     #tmpTrnDates
		) sbt WHERE sbt.TimeSlice = 'Weekly' and 
		sbt.diff = -1) u INNER JOIN #tmpTrnDates d 
		ON d.rowint = u.rowint-1
	

	----get the distinct dates for processing------------------------------------------------------------------
	select ROW_NUMBER() OVER(ORDER BY TransactionDate ASC) AS rowint, TransactionDate into #tmpIterateDates from #tmpTrnDates GROUP BY TransactionDate
	
	

	--------get regular product matrix for this customer done and keep it aside -------------------------
	DECLARE @ComputedBuyMatrix TABLE
			(Profile nvarchar(50),
			AgeGroupType nvarchar(50),
			Gender nvarchar(10),
			TimeSliceId int,
			TimeSlice nvarchar(50),
			TopCategoryId int,
			TopCategory nvarchar(200),
			CategoryId int,
			Category nvarchar(200),
			ProductId int,
			ProdQty int)

	DECLARE @RandomBuyMatrix TABLE
			(Profile nvarchar(50),
			AgeGroupType nvarchar(50),
			Gender nvarchar(10),
			TimeSliceId int,
			TimeSlice nvarchar(50),
			TopCategoryId int,
			TopCategory nvarchar(200),
			CategoryId int,
			Category nvarchar(200),
			ProductId int,
			ProdQty int)

	DECLARE @Exculde  ProdExcludeList, -- don't fill teh table variable now
			@ProdGenList ToBeGeneratedProdList,
			@Profile nvarchar(50),
			@AgeGroupType nvarchar(50),
			@Gender nvarchar(10),
			@Instance int,
			@HosueholdType nvarchar(50)

	Insert into @ProdGenList  Select ROW_NUMBER() OVER(ORDER BY [Profile] ASC) AS Id, [Profile], AgeGroupType, Gender from #tmpTrnDates GROUP BY [Profile], AgeGroupType, Gender
	SELECT @HosueholdType = [HosueholdType] from [Retail].[Customer] where Id = @CustomerId;

	--select * from @ProdGenList
	--Select * from #tmpTrnDates
	DELETE from @Exculde --offload all entries from exculde list 
	Insert into @ComputedBuyMatrix
		exec Retail.ConsolidateProductMatrix @HosueholdType, 'Regular', 5, @ProdGenList, @Exculde
	--------END: get regular product matrix for this customer done and keep it aside -------------------------
	DELETE from @Exculde 
	Insert into @Exculde select distinct ProductId from @ComputedBuyMatrix 
	Insert into @RandomBuyMatrix
				exec Retail.ConsolidateProductMatrix @HosueholdType, 'Random', 5, @ProdGenList, @Exculde
	
	-------prepare for main loop for each-------------------------------------------

	----sales haeder and detail variables 
	DECLARE @SalesHeader SalesHeaderType, @SalesDetail SalesDetailType, @InvoiceNumber nvarchar(50), @tranDate smalldatetime, @trantime TIME, @tranDateTime datetime

	DECLARE @iterateDateCount int = 1, @dateCount int = 0
	SELECT @dateCount = COUNT(*) from #tmpIterateDates
	WHILE @iterateDateCount <= @dateCount
	BEGIN
		Select @tranDate = TransactionDate from #tmpIterateDates where rowint = @iterateDateCount
		SET @trantime = CAST(DATEADD(SECOND,ABS(CHECKSUM(NEWID()))% DATEDIFF(ss,'07:05','22:55'),'07:05') AS TIME)
		SET @tranDateTime = CAST(@tranDate AS DATETIME) + CAST(@trantime AS DATETIME)

		--------prepare the table variables - clean-up before start
		DELETE from @SalesDetail
		DELETE from @SalesHeader

		----------- do random buy matrix once in a while - every 3 times--------------------
		IF Retail.random_range(1,9) >= 9
		BEGIN
			DELETE from @Exculde 
			Insert into @Exculde select distinct ProductId from @ComputedBuyMatrix 

			Insert into @RandomBuyMatrix
				exec Retail.ConsolidateProductMatrix @HosueholdType, 'Random', 5, @ProdGenList, @Exculde
		END
		-------------------------------------------------------------------------------------
		SET @InvoiceNumber = CAST(newid() AS nvarchar(50)) -- decide the invoice number and 

		-------regular items goes in --------------------------
		Insert into @SalesDetail
		Select @InvoiceNumber, Left(prod.ProductName, 50), cbm.ProdQty + Retail.random_range_with_default(0,2,0,5), prod.AveragePrice, 0, cbm.ProductId, cbm.CategoryId,
				1, cbm.Profile,cbm.AgeGroupType,cbm.Gender,cbm.TimeSliceId,cbm.TimeSlice 
		from #tmpTrnDates trn 
		INNER JOIN @ComputedBuyMatrix cbm ON
			trn.TimeSlice = cbm.TimeSlice AND
			trn.Profile = cbm.Profile AND
			trn.AgeGroupType = cbm.AgeGroupType AND
			trn.Gender = cbm.Gender
		INNER JOIN [Retail].[FactualProduct] prod ON
			cbm.ProductId = prod.Id
		WHERE trn.TransactionDate = @tranDate

		-------random items goes in --------------------------
		Insert into @SalesDetail
		Select @InvoiceNumber, Left(prod.ProductName, 50), cbm.ProdQty + Retail.random_range_with_default(0,2,0,5), prod.AveragePrice, 0, cbm.ProductId, cbm.CategoryId,
		       0, cbm.Profile,cbm.AgeGroupType,cbm.Gender,cbm.TimeSliceId,cbm.TimeSlice 
		from #tmpTrnDates trn 
		INNER JOIN @RandomBuyMatrix cbm ON
			trn.TimeSlice = cbm.TimeSlice AND
			trn.Profile = cbm.Profile AND
			trn.AgeGroupType = cbm.AgeGroupType AND
			trn.Gender = cbm.Gender
		INNER JOIN [Retail].[FactualProduct] prod ON
			cbm.ProductId = prod.Id
		WHERE trn.TransactionDate = @tranDate


		UPDATE @SalesDetail SET [TotalValue] = [Qty] * [Price]

		---prepare the sales header stuff -------------------------------
		Insert into @SalesHeader
			select @InvoiceNumber, @BatchRun, DATEPART(yyyy, @tranDate), 
			@tranDateTime, 
			(Select SUM([TotalValue]) from @SalesDetail),
			Retail.random_range_with_default(1,12,4,7),
			Retail.random_range(1,7),
			(Select Count(*) from @SalesDetail),
			@CustomerId


		---now insert into the actual sales transaction tables --> ideally in a SQL transaction
		Insert into [Retail].[SalesHeader]
		(InvoiceNo,DataRunVersion,YearNumber,InvoiceDate,TotalValue,LocationId,TerminalId,TotalLines,CustomerId, CreateDate)
		Select InvoiceNo,DataRunVersion,YearNumber,InvoiceDate,TotalValue,LocationId,TerminalId,TotalLines,CustomerId, InvoiceDate
			from @SalesHeader
		Insert into [Retail].[SalesDetail]
		(InvoiceNo,Description,Qty,Price,TotalValue,ProductId,CategoryId,IsRegularBuy,Profile,AgeGroupType,Gender,TimeSliceId,TimeSlice, CreateDate)
		select InvoiceNo,Description,Qty,Price,TotalValue,ProductId,CategoryId,IsRegularBuy,Profile,AgeGroupType,Gender,TimeSliceId,TimeSlice, @tranDateTime
		   from @SalesDetail



		SET @iterateDateCount = @iterateDateCount + 1
	END


	--Select distinct TransactionDate from #tmpTrnDates 
	--Select distinct [Profile], AgeGroupType, Gender from #tmpTrnDates 
	--Select * from @ComputedBuyMatrix 

	--select * from #tmpTrnDates where TransactionDate = @tranDate
	-- Select * from @ComputedBuyMatrix order by TimeSlice
	-- select * from @RandomBuyMatrix order by TimeSlice
	--Select * from @SalesHeader
	--Select * from @SalesDetail



--Select distinct  TransactionDate, AgeGroupType, Gender, TimeSlice, Count(*) from #tmpTrnDates 
--group by TransactionDate, AgeGroupType, Gender, TimeSlice
--order by TransactionDate

--Select distinct   TransactionDate from #tmpTrnDates 



--EXEC Retail.GenerateBuyMatrix '2011-01-02', '2011-12-31', 416, 'ALL'
--	Select * from SalesHeader
--	Select * from SalesDetail

--SELECT [HosueholdType],* from [Retail].[Customer] where Id = 416
--DECLARE @ExculdeList ProdExcludeList
--INSERT @ExculdeList (Id) Values(89987)
--exec Retail.ProductMatrix  'Middle', '', 'Adult', 'male', 'Regular', 5, @ExculdeList
