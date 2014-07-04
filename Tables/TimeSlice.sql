CREATE TABLE [Retail].[TimeSlice] (
    [Id]                  INT           NOT NULL,
    [TypeDesc]            NVARCHAR (50) NOT NULL,
    [PercentDistribution] INT           NULL,
    [Duration]            INT           NULL,
    [PlusMinusRange]      INT           NULL,
    [LowerLimit]          INT           NULL,
    [UpperLimit]          INT           NULL,
    [Binnable]            BIT           CONSTRAINT [DF_TimeSlice_Binnable] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_TimeSlice] PRIMARY KEY CLUSTERED ([Id] ASC)
);

