CREATE TABLE [dbo].[ProductItem] (
    [Id]                         BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]           DATETIME       NOT NULL,
    [Reference]                  NVARCHAR (255) NOT NULL,
    [Name]                       NVARCHAR (100) NULL,
    [Description]                VARCHAR (255)  NULL,
    [ModifiedTimestamp]          DATETIME       NOT NULL,
    [ProductId]                  BIGINT         CONSTRAINT [DF_ProductItem_ProductId] DEFAULT ((0)) NOT NULL,
    [StatusId]                   INT            CONSTRAINT [DF_ProductItem_StatusId] DEFAULT ((1)) NOT NULL,
    [CustomerId]                 BIGINT         NULL,
    [NetsuiteInventoryTimestamp] DATETIME       NULL,
    [NetsuiteInventoryStatusId]  TINYINT        CONSTRAINT [DF_ProductItem_NetsuiteInventoryStatusId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ProductItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProductItem_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_ProductItem_NetsuiteInventoryStatusId] FOREIGN KEY ([NetsuiteInventoryStatusId]) REFERENCES [Lookup].[NetsuiteInventoryStatus] ([Id]),
    CONSTRAINT [FK_ProductItem_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ProductItem_Reference_CustomerId]
    ON [dbo].[ProductItem]([Reference] ASC, [CustomerId] ASC)
    INCLUDE([ProductId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_ProductItem_ProductId_StatusId]
    ON [dbo].[ProductItem]([ProductId] ASC, [StatusId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_ProductItem_Customer]
    ON [dbo].[ProductItem]([CustomerId] ASC)
    INCLUDE([Id], [Reference], [ProductId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_ProductItem_StatusId_CustomerId]
    ON [dbo].[ProductItem]([StatusId] ASC, [CustomerId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_ProductItem_ProductId_StatusId_Reference_CustomerId_INCL]
    ON [dbo].[ProductItem]([ProductId] ASC, [StatusId] ASC, [Reference] ASC, [CustomerId] ASC)
    INCLUDE([CreatedTimestamp], [ModifiedTimestamp], [Name], [Description]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_ProductItem_ProductId]
    ON [dbo].[ProductItem]([ProductId] ASC)
    INCLUDE([Id], [StatusId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductIdReferenceActive]
    ON [dbo].[ProductItem]([ProductId] ASC, [Reference] ASC) WHERE ([StatusId]=(1)) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

