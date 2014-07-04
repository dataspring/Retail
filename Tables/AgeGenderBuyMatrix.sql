CREATE TABLE [Retail].[AgeGenderBuyMatrix] (
    [Id]                        INT            IDENTITY (1, 1) NOT NULL,
    [Profile]                   NVARCHAR (50)  NOT NULL,
    [AgeId]                     INT            NULL,
    [Age]                       NVARCHAR (50)  NOT NULL,
    [GenderId]                  INT            NULL,
    [Gender]                    NVARCHAR (50)  NOT NULL,
    [TimeSliceId]               INT            NULL,
    [TimeSlice]                 NVARCHAR (50)  NOT NULL,
    [TopCategoryId]             INT            NULL,
    [TopCategory]               NVARCHAR (200) NOT NULL,
    [CategoryId]                INT            NULL,
    [Category]                  NVARCHAR (200) NOT NULL,
    [RegularProdCount]          INT            CONSTRAINT [DF_CustomerBuyMatrix_RegularProdCount] DEFAULT ((0)) NOT NULL,
    [RegularProdQty]            INT            CONSTRAINT [DF_CustomerBuyMatrix_RegularProdQty] DEFAULT ((0)) NOT NULL,
    [RandomProdCount]           INT            CONSTRAINT [DF_CustomerBuyMatrix_RandomCountRangeFrom] DEFAULT ((0)) NOT NULL,
    [RandomProdCountUpperBound] INT            CONSTRAINT [DF_CustomerBuyMatrix_RandomCountRangeTo] DEFAULT ((0)) NOT NULL,
    [RandomProdQty]             INT            CONSTRAINT [DF_CustomerBuyMatrix_RandomQtyRangeFrom] DEFAULT ((0)) NOT NULL,
    [RandomProdQtyUpperBound]   INT            CONSTRAINT [DF_CustomerBuyMatrix_RandomQtyRangeTo] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CustomerBuyMatrix] PRIMARY KEY CLUSTERED ([Id] ASC)
);

