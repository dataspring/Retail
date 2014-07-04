CREATE TABLE [Retail].[FactualProduct] (
    [Id]             INT              IDENTITY (1, 1) NOT NULL,
    [FactualId]      UNIQUEIDENTIFIER NULL,
    [Brand]          NVARCHAR (200)   NULL,
    [ProductName]    NVARCHAR (200)   NULL,
    [Size]           NVARCHAR (200)   NULL,
    [Upc]            NVARCHAR (50)    NULL,
    [Ean13]          NVARCHAR (50)    NULL,
    [Category]       NVARCHAR (200)   NULL,
    [Manufacturer]   NVARCHAR (200)   NULL,
    [AveragePrice]   DECIMAL (18, 2)  NULL,
    [Currency]       NVARCHAR (5)     NULL,
    [CreateDateTime] DATETIME         CONSTRAINT [DF_FactualProduct_CreateDateTime] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_FactualProduct] PRIMARY KEY CLUSTERED ([Id] ASC)
);

