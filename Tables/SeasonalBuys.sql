CREATE TABLE [Retail].[SeasonalBuys] (
    [Id]       INT           IDENTITY (1, 1) NOT NULL,
    [Occasion] NVARCHAR (50) NOT NULL,
    [Year]     INT           NULL,
    [FromDate] DATETIME      NULL,
    [ToDate]   DATETIME      NULL,
    CONSTRAINT [PK_SeasonalBuys] PRIMARY KEY CLUSTERED ([Id] ASC)
);

