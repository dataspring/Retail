
CREATE PROCEDURE [Retail].[FeatureFreqInterval] 
	@CustomerId int,
	@ProductId int = NULL,
	@DataRunVersion nvarchar(50) = NULL
AS


	-----get all products for each batchrun -> to loop around-----------------------
	DECLARE @ProdTable TABLE
			   (rowint int IDENTITY(1,1), DataRunVersion nvarchar(50),
			   ProductId int)

	Insert into @ProdTable 
	Select distinct h.DataRunVersion, d.ProductId
			from [Retail].[SalesHeader] h INNER JOIN [Retail].[SalesDetail] d
			ON h.InvoiceNo = d.InvoiceNo
			WHERE h.CustomerId = @CustomerId
			AND d.ProductId = COALESCE(@ProductId, d.ProductId) 
			AND h.DataRunVersion = COALESCE(@DataRunVersion, h.DataRunVersion)
    -----END: get all products to loop around-----------------------


	CREATE TABLE #tmpDateLeadFreq (rowint int IDENTITY(1,1), DataRunVersion nvarchar(50), ProductId int, InvoiceDate datetime, TypeDesc nvarchar(50), Qty int, Freq int);
	DECLARE @iCount int = 1, @iTotalRow int = 0;
	DECLARE @ProdId int, @InvoiceDate datetime, @Qty int, @DataRunVer nvarchar(50);
	

	--------loop for each product to fill teh frequency ---------------------------------------
	SELECT @iCount= 1, @iTotalRow = 0;
	Select @iTotalRow = count(*) from @ProdTable
	WHILE @iCount <= @iTotalRow
	BEGIN
		Select @ProdId = ProductId, @DataRunVer = DataRunVersion from @ProdTable where rowint = @iCount
		
		Insert into #tmpDateLeadFreq
		Select 
			s.DataRunVersion, s.ProductId, s.InvoiceDate, 
			r.TypeDesc, SUM(s.Qty),
			Count(s.InvoiceDate) as [Frequency] -- count will be always one
		from
			[Retail].[TimeSlice]  r inner join 
			--get for all/given product --> their invoice dates, diff in days from previous invoice and quantity purchased-------------
			(Select h.DataRunVersion, d.ProductId, h.InvoiceDate, d.Qty, DATEDIFF(dd, h.InvoiceDate,(lead(h.InvoiceDate) over (order by InvoiceDate))) diff
				from [Retail].[SalesHeader] h INNER JOIN [Retail].[SalesDetail] d
				ON h.InvoiceNo = d.InvoiceNo
				WHERE h.CustomerId = @CustomerId
				AND d.ProductId = @ProdId
				AND h.DataRunVersion = @DataRunVer
			) s 
			--------join with timeslice to get thier timeslice type
			on s.diff between r.LowerLimit and r.UpperLimit
		group by  s.DataRunVersion, s.ProductId, s.InvoiceDate,  r.TypeDesc


		SET @iCount = @iCount + 1
	END
	-------END: loop for each product to fill teh frequency ---------------------------------------


	

	----get the distinct dates for processing------------------------------------------------------------------
	select ROW_NUMBER() OVER(ORDER BY ProductId, InvoiceDate ASC) AS rowint, DataRunVersion, ProductId, InvoiceDate into #tmpProdTxn from #tmpDateLeadFreq GROUP BY DataRunVersion, ProductId, InvoiceDate
	
	
	--------get regular product matrix for this customer done and keep it aside -------------------------
	DECLARE @ProdTxnTimeSliceFreq TABLE
			   (DataRunVersion nvarchar(50),
			    ProductId int,
				InvoiceDate datetime,
				Qty int,
				Daily int,
				HalfWeekly int,
				Weekly int,
				Fortnightly int,
				Monthly int,
				BiMonthly int,
				Quarterly int,
				SemiAnnual int,
				Annual int)
				

	DECLARE @ProdTxnTimeSliceFreqFinal TABLE
			   (DataRunVersion nvarchar(50),
			    ProductId int,
				InvoiceDate datetime,
				Qty int,
				Daily decimal(18,6),
				HalfWeekly decimal(18,6),
				Weekly decimal(18,6),
				Fortnightly decimal(18,6),
				Monthly decimal(18,6),
				BiMonthly decimal(18,6),
				Quarterly decimal(18,6),
				SemiAnnual decimal(18,6),
				Annual decimal(18,6),
				CurrentSlice int)


	-------perform transpose on the timeslice value from row to columnar values----------------------------
	SELECT @iCount= 1, @iTotalRow = 0;
	Select @iTotalRow = count(*) from #tmpProdTxn
	WHILE @iCount <= @iTotalRow
	BEGIN
		Select @DataRunVersion = DataRunVersion, @ProdId = ProductId, @InvoiceDate = InvoiceDate from #tmpProdTxn where rowint = @iCount
		Select TOP 1 @Qty=Qty from #tmpDateLeadFreq f where f.DataRunVersion = @DataRunVersion AND f.ProductId = @ProductId AND f.InvoiceDate = @InvoiceDate

		Insert into @ProdTxnTimeSliceFreq (DataRunVersion,Qty,ProductId,InvoiceDate,Daily,HalfWeekly,Weekly,Fortnightly,Monthly,BiMonthly,Quarterly,SemiAnnual,Annual)
		Select @DataRunVersion, @Qty, @ProdId, pvt.* from
		(select  InvoiceDate, Isnull([Daily],0) AS [Daily],Isnull([HalfWeekly],0) AS [HalfWeekly],Isnull([Weekly],0) AS [Weekly],Isnull([Fortnightly],0) AS [Fortnightly],Isnull([Monthly],0) AS [Monthly],Isnull([BiMonthly],0) AS [BiMonthly],Isnull([Quarterly],0) AS [Quarterly],Isnull([SemiAnnual],0) AS [SemiAnnual],Isnull([Annual],0) AS [Annual]
			FROM 
				(Select InvoiceDate, TypeDesc, Freq from #tmpDateLeadFreq where 
					ProductId = @ProdId and InvoiceDate = @InvoiceDate)  AS SourceTable
			PIVOT
			 ( SUM(Freq)
				FOR TypeDesc in ([Daily],[HalfWeekly],[Weekly],[Fortnightly],[Monthly],[BiMonthly],[Quarterly],[SemiAnnual],[Annual]) 
			 ) AS PivotTable
		  ) pvt

		SET @iCount = @iCount + 1
	END
	-------transpose ends --------------------------------------------------------------------------


	-----End: for each transaction update the qty ----------------------------------------------------------
	
	
	-------for each transaction/invoice date, get teh summation of all preceding rows to get the frequency of interval at this transaction w.r.t all previous transactions
	SELECT @iCount= 1, @iTotalRow = 0;
	Select @iTotalRow = count(*) from #tmpProdTxn
	WHILE @iCount <= @iTotalRow
	BEGIN
		Select @DataRunVersion = DataRunVersion, @ProdId = ProductId, @InvoiceDate = InvoiceDate from #tmpProdTxn where rowint = @iCount
		Insert into @ProdTxnTimeSliceFreqFinal (DataRunVersion,ProductId,InvoiceDate,Qty,Daily,HalfWeekly,Weekly,Fortnightly,Monthly,BiMonthly,Quarterly,SemiAnnual,Annual)
		Select DataRunVersion, ProductId, @InvoiceDate, Sum(Qty), Sum([Daily]),Sum([HalfWeekly]),Sum([Weekly]),Sum([Fortnightly]),Sum([Monthly]),Sum([BiMonthly]),Sum([Quarterly]),Sum([SemiAnnual]),Sum([Annual]) 
		from @ProdTxnTimeSliceFreq where DataRunVersion = @DataRunVersion and ProductId = @ProdId and InvoiceDate <= @InvoiceDate
		GROUP BY DataRunVersion, ProductId

		SET @iCount = @iCount + 1
	END
	--------END: trev txn summation ends -------------------------
	
	Select * from @ProdTxnTimeSliceFreqFinal 
	------------normalize over the total qty purchased at that transaction----------------------
	Update @ProdTxnTimeSliceFreqFinal Set Daily = Daily/Qty,HalfWeekly=HalfWeekly/Qty,Weekly=Weekly/Qty,Fortnightly=Fortnightly/Qty,Monthly=Monthly/Qty,
											BiMonthly=BiMonthly/Qty,Quarterly=Quarterly/Qty,SemiAnnual=SemiAnnual/Qty,Annual=Annual/Qty



	------update the current timeslice for each transaction-------------------------------------
	Update @ProdTxnTimeSliceFreqFinal Set CurrentSlice = t.Id from @ProdTxnTimeSliceFreqFinal p 
	INNER JOIN #tmpDateLeadFreq f 
	ON p.DataRunVersion = f.DataRunVersion and p.ProductId = f.ProductId and p.InvoiceDate = f.InvoiceDate
	INNER JOIN [Retail].[TimeSlice] t
	ON f.TypeDesc = t.TypeDesc

	------END: update the current timeslice for each transaction-------------------------------------

	--Select * from #tmpDateLeadFreq
	--Select * from @ProdTxnTimeSliceFreq
	--Select distinct ProductId, InvoiceDate from @ProdTxnTimeSliceFreqFinal 

	Select * from @ProdTxnTimeSliceFreqFinal 


--EXEC Retail.FeatureFreqInterval 91377, NULL, '635237574645200000'
--EXEC Retail.FeatureFreqInterval 91377, 54624, '635237574645200000'

--SELECT [
