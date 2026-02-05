CREATE TABLE [dbo].[UserSecurityQuestion] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [UserId]             BIGINT         NOT NULL,
    [SecurityQuestionId] BIGINT         NOT NULL,
    [Password]           NVARCHAR (255) NOT NULL,
    [Salt]               VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_UserSecurityQuestion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UserSecurityQuestion_SecurityQuestion] FOREIGN KEY ([SecurityQuestionId]) REFERENCES [dbo].[SecurityQuestion] ([Id]),
    CONSTRAINT [FK_UserSecurityQuestion_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

