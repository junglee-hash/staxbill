CREATE TABLE [dbo].[PlanProduct] (
    [Id]                             BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProductId]                      BIGINT          NOT NULL,
    [PlanRevisionId]                 BIGINT          NOT NULL,
    [IsOptional]                     BIT             NOT NULL,
    [IsIncludedByDefault]            BIT             NOT NULL,
    [IsFixed]                        BIT             NOT NULL,
    [IsRecurring]                    BIT             NOT NULL,
    [Quantity]                       DECIMAL (18, 6) NOT NULL,
    [MaxQuantity]                    DECIMAL (18, 6) NULL,
    [CreatedTimestamp]               DATETIME        NOT NULL,
    [ModifiedTimestamp]              DATETIME        NOT NULL,
    [IsTrackingItems]                BIT             CONSTRAINT [DF_PlanProduct_IsTrackingItems] DEFAULT ((0)) NOT NULL,
    [ResetTypeId]                    INT             NOT NULL,
    [PlanProductUniqueId]            BIGINT          NULL,
    [StatusId]                       INT             CONSTRAINT [df_PlanProduct_StatusId] DEFAULT ((1)) NOT NULL,
    [Name]                           NVARCHAR (100)  NULL,
    [Description]                    NVARCHAR (1000) NULL,
    [Code]                           NVARCHAR (1000) NULL,
    [ChargeAtSubscriptionActivation] BIT             DEFAULT ((1)) NOT NULL,
    [SortOrder]                      INT             CONSTRAINT [DF_PlanProduct_SortOrder] DEFAULT ((1)) NOT NULL,
    [GenerateZeroDollarCharge]       BIT             CONSTRAINT [DF_PlanProduct_GenerateZeroDollarCharge] DEFAULT ((1)) NOT NULL,
    [GLCodeId]                       BIGINT          NULL,
    CONSTRAINT [PK_PlanProduct] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanProduct_GLCode] FOREIGN KEY ([GLCodeId]) REFERENCES [dbo].[GLCode] ([Id]),
    CONSTRAINT [FK_PlanProduct_PlanProductKey] FOREIGN KEY ([PlanProductUniqueId]) REFERENCES [dbo].[PlanProductKey] ([Id]),
    CONSTRAINT [fk_PlanProduct_PlanProductStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[PlanProductStatus] ([Id]),
    CONSTRAINT [FK_PlanProduct_PlanRevision] FOREIGN KEY ([PlanRevisionId]) REFERENCES [dbo].[PlanRevision] ([Id]),
    CONSTRAINT [FK_PlanProduct_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [FK_PlanProduct_ProductResetType] FOREIGN KEY ([ResetTypeId]) REFERENCES [Lookup].[ProductResetType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PlanProduct_PlanProductUniqueId_SortOrder]
    ON [dbo].[PlanProduct]([PlanProductUniqueId] ASC, [SortOrder] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanProduct_ResetTypeId]
    ON [dbo].[PlanProduct]([ResetTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PlanProduct_PlanRevisionId]
    ON [dbo].[PlanProduct]([PlanRevisionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanProduct_StatusId]
    ON [dbo].[PlanProduct]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PlanProduct_ProductId]
    ON [dbo].[PlanProduct]([ProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

