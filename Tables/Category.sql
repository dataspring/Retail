CREATE TABLE [Retail].[Category] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [TypeDesc]    NVARCHAR (200) NOT NULL,
    [TopCategory] NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED ([Id] ASC)
);

