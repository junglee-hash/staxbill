CREATE TABLE [dbo].[TwilioNotification] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT         NULL,
    [CustomerId]       BIGINT         NULL,
    [Raw]              VARCHAR (4000) NOT NULL,
    [CreatedTimestamp] DATETIME       NOT NULL,
    CONSTRAINT [PK__TwilioNotification] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TwilioNotificationAccountId_Id] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_TwilioNotificationCustomerId_Id] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id])
);


GO

