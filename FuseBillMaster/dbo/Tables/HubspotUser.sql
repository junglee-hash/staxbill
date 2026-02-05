CREATE TABLE [dbo].[HubspotUser] (
    [Id]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [HubspotUserId] VARCHAR (20)  NOT NULL,
    [FirstName]     VARCHAR (120) NOT NULL,
    [LastName]      VARCHAR (120) NOT NULL,
    [Email]         VARCHAR (256) NOT NULL,
    [AccessLevel]   VARCHAR (100) NOT NULL,
    [AccountId]     BIGINT        NOT NULL,
    [UserId]        BIGINT        NULL,
    CONSTRAINT [PK_HubspotUser] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HubspotUser_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_HubspotUser_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_HubspotUser_Account]
    ON [dbo].[HubspotUser]([AccountId] ASC);


GO

