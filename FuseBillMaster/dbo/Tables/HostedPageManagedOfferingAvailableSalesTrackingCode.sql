CREATE TABLE [dbo].[HostedPageManagedOfferingAvailableSalesTrackingCode] (
    [Id]                          BIGINT IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingId] BIGINT NOT NULL,
    [SalesTrackingCodeId]         BIGINT NOT NULL,
    [SalesTrackingCodeTypeId]     INT    NOT NULL,
    [SortOrder]                   INT    NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingAvailableSalesTrackingCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingAvailableSalesTrackingCode_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingAvailableSalesTrackingCode_SalesTrackingCode] FOREIGN KEY ([SalesTrackingCodeId]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingAvailableSalesTrackingCode_SalesTrackingCodeType] FOREIGN KEY ([SalesTrackingCodeTypeId]) REFERENCES [Lookup].[SalesTrackingCodeType] ([Id])
);


GO

