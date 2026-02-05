CREATE TABLE [dbo].[HostedPageManagedCurrencyOfferingRelationship] (
    [Id]                                     BIGINT IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedSectionSubscriptionId] BIGINT NOT NULL,
    [CurrencyId]                             BIGINT NOT NULL,
    [HostedPageManagedOfferingId]            BIGINT NOT NULL,
    CONSTRAINT [PK_HostedPageManagedCurrencyOfferingRelationship] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedCurrencyOfferingRelationship_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_HostedPageManagedCurrencyOfferingRelationship_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id]),
    CONSTRAINT [FK_HostedPageManagedCurrencyOfferingRelationship_HostedPageManagedSectionSubscription] FOREIGN KEY ([HostedPageManagedSectionSubscriptionId]) REFERENCES [dbo].[HostedPageManagedSectionSubscription] ([Id])
);


GO

