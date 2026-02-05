CREATE TABLE [dbo].[HostedPageManagedSectionPurchase] (
    [Id]                                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedSelfServicePortalId] BIGINT         NOT NULL,
    [TitleText]                            NVARCHAR (500) NOT NULL,
    [ProductId]                            BIGINT         NOT NULL,
    [Visible]                              BIT            CONSTRAINT [DF_Visible] DEFAULT ((0)) NOT NULL,
    [PriceOverride]                        BIT            CONSTRAINT [DF_PriceOverrideSectionPurchase] DEFAULT ((0)) NOT NULL,
    [SalesTrackingCodeAccess]              BIT            CONSTRAINT [DF_SalesTrackingCodeAccess] DEFAULT ((0)) NOT NULL,
    [SortOrder]                            INT            NOT NULL,
    [SalesTrackingCode1Id]                 BIGINT         NULL,
    [SalesTrackingCode2Id]                 BIGINT         NULL,
    [SalesTrackingCode3Id]                 BIGINT         NULL,
    [SalesTrackingCode4Id]                 BIGINT         NULL,
    [SalesTrackingCode5Id]                 BIGINT         NULL,
    [DescriptionOverride]                  BIT            CONSTRAINT [DF_DescriptionOverride_Purchase] DEFAULT ((0)) NOT NULL,
    [DescriptionOverrideText]              VARCHAR (1000) NULL,
    [Selected]                             BIT            CONSTRAINT [DF_Selected] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionPurchase] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_HostedPage] FOREIGN KEY ([HostedPageManagedSelfServicePortalId]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPurchase_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id])
);


GO

