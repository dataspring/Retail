CREATE TABLE [Retail].[Gender] (
    [Id]                  INT           NOT NULL,
    [TypeDesc]            NVARCHAR (50) NOT NULL,
    [PercentDistribution] INT           NOT NULL,
    CONSTRAINT [PK_Gender] PRIMARY KEY CLUSTERED ([Id] ASC)
);

