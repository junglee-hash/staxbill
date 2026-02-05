CREATE TABLE [dbo].[UserLoginIntercept] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [UserId]           BIGINT   NOT NULL,
    [LoginInterceptId] TINYINT  NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [pk_UserLoginIntercept] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [fk_UserLoginIntercept_LoginIntercept] FOREIGN KEY ([LoginInterceptId]) REFERENCES [Lookup].[LoginIntercept] ([Id]),
    CONSTRAINT [fk_UserLoginIntercept_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

