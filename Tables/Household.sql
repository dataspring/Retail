CREATE TABLE [Retail].[Household] (
    [Id]                  INT           NOT NULL,
    [TypeDesc]            NVARCHAR (50) NOT NULL,
    [PercentDistribution] INT           NOT NULL,
    CONSTRAINT [PK_Household] PRIMARY KEY CLUSTERED ([Id] ASC)
);

