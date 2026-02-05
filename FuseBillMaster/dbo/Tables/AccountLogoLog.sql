CREATE TABLE [dbo].[AccountLogoLog] (
    [Id]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT        NOT NULL,
    [CreatedTimestamp] DATETIME      NOT NULL,
    [Filename]         VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_AccountLogoLog] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AccountLogoLog_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

