CREATE TABLE [dbo].[Pricebook] (
    [Id]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]                 BIGINT          NOT NULL,
    [CreatedTimestamp]          DATETIME        NOT NULL,
    [ModifiedTimestamp]         DATETIME        NOT NULL,
    [Code]                      NVARCHAR (255)  NOT NULL,
    [Name]                      NVARCHAR (100)  NOT NULL,
    [Description]               NVARCHAR (1000) NULL,
    [Deletable]                 BIT             CONSTRAINT [DF_Deletable] DEFAULT ((1)) NOT NULL,
    [IsUsingDateBasedPricebook] BIT             CONSTRAINT [DF_IsUsingDateBasedPricebook] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Pricebook] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Pricebook_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [uc_Pricebook_AccountId_Code] UNIQUE NONCLUSTERED ([AccountId] ASC, [Code] ASC)
);


GO

