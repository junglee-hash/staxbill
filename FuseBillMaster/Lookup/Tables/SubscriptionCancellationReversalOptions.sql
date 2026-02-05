CREATE TABLE [Lookup].[SubscriptionCancellationReversalOptions] (
    [Id]   INT           NOT NULL,
    [Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_SubscriptionCancellationReversalOptions] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

