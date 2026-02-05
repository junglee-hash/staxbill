CREATE TABLE [Lookup].[SubscriptionStatus] (
    [Id]        INT          NOT NULL,
    [Name]      VARCHAR (50) NOT NULL,
    [SortOrder] INT          NULL,
    CONSTRAINT [PK_SubscriptionStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

