CREATE TABLE [dbo].[AccountReset] (
    [Id]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                BIGINT         NOT NULL,
    [TemporaryAccountId]       BIGINT         NULL,
    [UserId1]                  BIGINT         NULL,
    [UserId1ApprovedTimestamp] DATETIME       NULL,
    [UserId2]                  BIGINT         NULL,
    [UserId2ApprovedTimestamp] DATETIME       NULL,
    [StatusId]                 INT            NOT NULL,
    [CreatedTimestamp]         DATETIME       NOT NULL,
    [FinalApprovedTimestamp]   DATETIME       NULL,
    [CollectingStartTimestamp] DATETIME       NULL,
    [CollectingEndTimestamp]   DATETIME       NULL,
    [ResetStartTimestamp]      DATETIME       NULL,
    [ResetEndTimestamp]        DATETIME       NULL,
    [CustomerIdsToExclude]     VARCHAR (2000) NULL,
    [CountOfCustomers]         INT            NULL,
    [ErrorReason]              VARCHAR (255)  NULL,
    CONSTRAINT [PK_AccountReset] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountReset_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountReset_AccountResetStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[AccountResetStatus] ([Id]),
    CONSTRAINT [FK_AccountReset_TemporaryAccount] FOREIGN KEY ([TemporaryAccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountReset_User1] FOREIGN KEY ([UserId1]) REFERENCES [dbo].[User] ([Id]),
    CONSTRAINT [FK_AccountReset_User2] FOREIGN KEY ([UserId2]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountReset_AccountId]
    ON [dbo].[AccountReset]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

