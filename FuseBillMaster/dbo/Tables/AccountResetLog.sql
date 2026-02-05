CREATE TABLE [dbo].[AccountResetLog] (
    [Id]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT        NOT NULL,
    [UserId]           BIGINT        NOT NULL,
    [ActionId]         INT           NOT NULL,
    [Message]          VARCHAR (255) NOT NULL,
    [CreatedTimestamp] DATETIME      NOT NULL,
    CONSTRAINT [PK_AccountResetLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountResetLog_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountResetLog_Action] FOREIGN KEY ([ActionId]) REFERENCES [Lookup].[Action] ([Id]),
    CONSTRAINT [FK_AccountResetLog_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountResetLog_AccountId]
    ON [dbo].[AccountResetLog]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

