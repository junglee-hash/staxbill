CREATE TABLE [dbo].[AccountUser] (
    [Id]        BIGINT IDENTITY (1, 1) NOT NULL,
    [AccountId] BIGINT NOT NULL,
    [UserId]    BIGINT NOT NULL,
    [IsEnabled] BIT    NOT NULL,
    CONSTRAINT [PK_AccountUser] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountUser_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountUser_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUser_UserId]
    ON [dbo].[AccountUser]([UserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUser_AccountId]
    ON [dbo].[AccountUser]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

