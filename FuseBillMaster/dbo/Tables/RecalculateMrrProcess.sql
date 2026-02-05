CREATE TABLE [dbo].[RecalculateMrrProcess] (
    [Id]                    BIGINT        IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]      DATETIME      NULL,
    [CompletedTimestamp]    DATETIME      NULL,
    [RecalculationFailures] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_RecalculateMrrProcess_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

