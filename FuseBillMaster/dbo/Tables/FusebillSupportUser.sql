CREATE TABLE [dbo].[FusebillSupportUser] (
    [Id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ActiveDirectoryUsername] NVARCHAR (255) NOT NULL,
    [UserId]                  BIGINT         NOT NULL,
    CONSTRAINT [PK_FusebillSupportUser] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FusebillSupportUser_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_FusebillSupportUser_UserId]
    ON [dbo].[FusebillSupportUser]([UserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

