CREATE TABLE [dbo].[AccountTxtSchedule] (
    [Id]                   BIGINT       IDENTITY (1, 1) NOT NULL,
    [AccountId]            BIGINT       NOT NULL,
    [Type]                 VARCHAR (50) NOT NULL,
    [DaysFromTerm]         INT          NOT NULL,
    [Key]                  VARCHAR (60) NOT NULL,
    [CreatedTimestamp]     DATETIME     NOT NULL,
    [ModifiedTimestamp]    DATETIME     NOT NULL,
    [AccountTxtTemplateId] BIGINT       NOT NULL,
    CONSTRAINT [PK_AccountTxtSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountTxtSchedule_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountTxtSchedule_AccountTxtTemplate] FOREIGN KEY ([AccountTxtTemplateId]) REFERENCES [dbo].[AccountTxtTemplate] ([Id])
);


GO

