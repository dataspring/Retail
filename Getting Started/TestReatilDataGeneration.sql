
USE [BigTestData]
Go

------step 1
------- clear the sales detail & sales header table and prepare for the transactions being fileld up
TRUNCATE TABLE [Retail].[SalesDetail]
TRUNCATE TABLE [Retail].[SalesHeader]
Go


------step 1.1
----generate batch run number for this test run / your big data loop run
DECLARE @BatchRunTicks nvarchar(50)
SET @BatchRunTicks = CAST(Retail.GetTicks() AS nvarchar(50));


-------start loop here for as many customers as you need
-------now test execute this stroed proc to generate transactions for a single customer whose id is 91377
-------step 2
EXEC [Retail].[GenerateBuyMatrix] '2012-01-07', '2013-12-23', 91377, 'ALL', @BatchRunTicks
-------close the customer iteration loop here

-----step 3
-----check the counts of the sales detail & sales header table
Select count(*) from [Retail].[SalesHeader]
Select count(*) from [Retail].[SalesDetail]

---For Big Data Requirements: You need to iterate step 2 enclosing in a loop for all customers that you need.
---In the quickstart folder, you have a database backup that has 100K customers that yo can generate data, simply loop them all
--- and leave it run for the few hours - voila - you have the records