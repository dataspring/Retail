CREATE TYPE [Retail].[SalesHeaderType] AS TABLE (
    [InvoiceNo]      NVARCHAR (50)   NOT NULL,
    [DataRunVersion] NVARCHAR (50)   NOT NULL,
    [YearNumber]     INT             NOT NULL,
    [InvoiceDate]    DATETIME        NULL,
    [TotalValue]     NUMERIC (18, 2) NULL,
    [LocationId]     NVARCHAR (50)   NOT NULL,
    [TerminalId]     NVARCHAR (50)   NOT NULL,
    [TotalLines]     INT             NULL,
    [CustomerId]     INT             NULL);

