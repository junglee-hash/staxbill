CREATE TABLE [dbo].[HostedPageManagedOfferingProduct] (
    [Id]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingId] BIGINT          NOT NULL,
    [ProductId]                   BIGINT          NOT NULL,
    [TitleText]                   NVARCHAR (100)  NOT NULL,
    [DescriptionText]             NVARCHAR (1000) NULL,
    [ButtonText]                  NVARCHAR (50)   NOT NULL,
    [Visible]                     BIT             NOT NULL,
    [SortOrder]                   INT             NOT NULL,
    [IsHighlighted]               BIT             NOT NULL,
    [QuantityManagement]          BIT             NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingProduct] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingProduct_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingProduct_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [uk_OfferingProduct] UNIQUE NONCLUSTERED ([HostedPageManagedOfferingId] ASC, [ProductId] ASC) WITH (FILLFACTOR = 100)
);


GO

