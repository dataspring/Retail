CREATE TABLE [Retail].[Age] (
    [Id]                  INT           NOT NULL,
    [TypeDesc]            NVARCHAR (50) NOT NULL,
    [PercentDistribution] FLOAT (53)    NULL,
    [FromAge]             INT           NULL,
    [ToAge]               INT           NULL,
    CONSTRAINT [PK_Age] PRIMARY KEY CLUSTERED ([Id] ASC)
);

