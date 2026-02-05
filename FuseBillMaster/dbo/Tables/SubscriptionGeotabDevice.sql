CREATE TABLE [dbo].[SubscriptionGeotabDevice] (
    [Id]              BIGINT        NOT NULL,
    [GeotabAccountId] NVARCHAR (30) NOT NULL,
    CONSTRAINT [PK_SubscriptionGeotabDevice] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SubscriptionGeotabDevice_Subscription] FOREIGN KEY ([Id]) REFERENCES [dbo].[Subscription] ([Id])
);


GO

