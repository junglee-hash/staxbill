CREATE TABLE [dbo].[AccountEmailSchedule] (
    [Id]                            BIGINT       IDENTITY (1, 1) NOT NULL,
    [AccountId]                     BIGINT       NOT NULL,
    [Type]                          VARCHAR (50) NOT NULL,
    [DaysFromTerm]                  INT          NOT NULL,
    [Key]                           VARCHAR (60) NOT NULL,
    [CreatedTimestamp]              DATETIME     NOT NULL,
    [ModifiedTimestamp]             DATETIME     NOT NULL,
    [AccountEmailTemplateContentId] BIGINT       NOT NULL,
    CONSTRAINT [PK_AccountEmailSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountEmailSchedule_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountEmailSchedule_AccountEmailTemplateContent] FOREIGN KEY ([AccountEmailTemplateContentId]) REFERENCES [dbo].[AccountEmailTemplateContent] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountEmailSchedule_AccountId]
    ON [dbo].[AccountEmailSchedule]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

