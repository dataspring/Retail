﻿CREATE TABLE [Retail].[SalesHeader] (
    [InvoiceNo]      UNIQUEIDENTIFIER NOT NULL,
    [DataRunVersion] NVARCHAR (50)    NOT NULL,
    [YearNumber]     INT              NOT NULL,
    [InvoiceDate]    DATETIME         NULL,
    [TotalValue]     NUMERIC (18, 2)  NULL,
    [Gst]            NUMERIC (18, 4)  NULL,
    [NetDiscount]    NUMERIC (18, 2)  NULL,
    [Discount]       NUMERIC (18, 2)  NULL,
    [DiscountType]   NVARCHAR (50)    NULL,
    [NetTotal]       NUMERIC (18, 2)  NULL,
    [CashierID]      NVARCHAR (50)    NULL,
    [LocationId]     NVARCHAR (50)    NOT NULL,
    [TerminalId]     NVARCHAR (50)    NOT NULL,
    [TotalLines]     INT              NULL,
    [TenderAmount]   NUMERIC (18, 2)  NULL,
    [Balance]        NUMERIC (18, 2)  NULL,
    [SalesType]      NVARCHAR (50)    NULL,
    [CustomerId]     INT              NULL,
    [MemberDiscount] NUMERIC (18, 2)  NULL,
    [CreateDate]     DATETIME         NOT NULL,
    [ModifyDate]     DATETIME         NULL,
    CONSTRAINT [PK_SalesHeader] PRIMARY KEY CLUSTERED ([InvoiceNo] ASC)
);

