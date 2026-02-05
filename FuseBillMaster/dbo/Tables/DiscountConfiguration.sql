CREATE TABLE [dbo].[DiscountConfiguration] (
    [Id]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]                 BIGINT          NOT NULL,
    [RemainingUsagesUntilStart] INT             NOT NULL,
    [RemainingUsage]            INT             NULL,
    [Amount]                    DECIMAL (18, 6) NOT NULL,
    [DiscountTypeId]            INT             NOT NULL,
    [Name]                      NVARCHAR (255)  NULL,
    [Description]               NVARCHAR (500)  NULL,
    [Code]                      NVARCHAR (255)  NULL,
    [StatusId]                  INT             NOT NULL,
    [NetsuiteItemId]            VARCHAR (100)   NULL,
    CONSTRAINT [PK_DiscountConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DiscountConfiguration_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_DiscountConfiguration_DiscountStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[DiscountStatus] ([Id]),
    CONSTRAINT [FK_DiscountConfiguration_DiscountType] FOREIGN KEY ([DiscountTypeId]) REFERENCES [Lookup].[DiscountType] ([Id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_DiscountConfiguration_AccountId_Code]
    ON [dbo].[DiscountConfiguration]([AccountId] ASC, [Code] ASC) WHERE ([Code] IS NOT NULL) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_DiscountConfiguration_AccountId]
    ON [dbo].[DiscountConfiguration]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_DiscountConfiguration_DiscountTypeId]
    ON [dbo].[DiscountConfiguration]([DiscountTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_DiscountConfiguration_StatusId]
    ON [dbo].[DiscountConfiguration]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

