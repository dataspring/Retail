CREATE TYPE [Retail].[ToBeGeneratedProdList] AS TABLE (
    [Id]           INT           NOT NULL,
    [Profile]      NVARCHAR (50) NULL,
    [AgeGroupType] NVARCHAR (50) NULL,
    [Gender]       NVARCHAR (10) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC));

