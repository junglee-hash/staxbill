CREATE TABLE [dbo].[UserPageIntercept] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [UserId]           BIGINT   NOT NULL,
    [PageInterceptId]  TINYINT  NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [pk_UserPageIntercept] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [fk_UserPageIntercept_PageIntercept] FOREIGN KEY ([PageInterceptId]) REFERENCES [Lookup].[PageIntercept] ([Id]),
    CONSTRAINT [fk_UserPageIntercept_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

