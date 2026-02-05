CREATE TABLE [dbo].[UserAccessLink] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [Link]            NVARCHAR (MAX) NOT NULL,
    [UserId]          BIGINT         NOT NULL,
    [ExpiryTimestamp] DATETIME       NOT NULL,
    [IsConsumed]      BIT            NOT NULL,
    [PasswordKey]     NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_UserAccessLink] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_UserAccessLink_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_UserAccessLink_UserId]
    ON [dbo].[UserAccessLink]([UserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

