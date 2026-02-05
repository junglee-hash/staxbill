CREATE TABLE [dbo].[CustomerSmsNumber] (
    [Id]                BIGINT       IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT       NOT NULL,
    [CustomerId]        BIGINT       NOT NULL,
    [PhoneNumber]       VARCHAR (20) NOT NULL,
    [SmsStatusId]       TINYINT      NOT NULL,
    [CreatedTimestamp]  DATETIME     NOT NULL,
    [ModifiedTimestamp] DATETIME     NOT NULL,
    CONSTRAINT [PK_CustomerSmsNumber] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerSmsNumber_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_CustomerSmsNumber_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerSmsNumber_SmsStatus] FOREIGN KEY ([SmsStatusId]) REFERENCES [Lookup].[SmsStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerSmsNumber_CustomerId_AccountId]
    ON [dbo].[CustomerSmsNumber]([CustomerId] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerSmsNumber_AccountId_PhoneNumber]
    ON [dbo].[CustomerSmsNumber]([AccountId] ASC, [PhoneNumber] ASC) WITH (FILLFACTOR = 100);


GO

