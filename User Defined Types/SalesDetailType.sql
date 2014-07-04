CREATE TYPE [Retail].[SalesDetailType] AS TABLE (
    [InvoiceNo]    NVARCHAR (50)   NOT NULL,
    [Description]  NVARCHAR (50)   NULL,
    [Qty]          INT             NULL,
    [Price]        NUMERIC (18, 2) NULL,
    [TotalValue]   NUMERIC (18, 2) NULL,
    [ProductId]    INT             NOT NULL,
    [CategoryId]   INT             NULL,
    [IsRegularBuy] BIT             NULL,
    [Profile]      NVARCHAR (50)   NULL,
    [AgeGroupType] NVARCHAR (50)   NULL,
    [Gender]       NVARCHAR (10)   NULL,
    [TimeSliceId]  INT             NULL,
    [TimeSlice]    NVARCHAR (50)   NULL);

