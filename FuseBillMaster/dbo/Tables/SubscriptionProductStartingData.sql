CREATE TABLE [dbo].[SubscriptionProductStartingData] (
    [Id]                BIGINT   NOT NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    [InitialMrr]        MONEY    NOT NULL,
    [InitialNetMrr]     MONEY    NOT NULL,
    [HasRenewed]        BIT      NOT NULL,
    CONSTRAINT [PK_SubscriptionProductStartingData] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SubscriptionProductStartingData_SubscriptionProduct] FOREIGN KEY ([Id]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

