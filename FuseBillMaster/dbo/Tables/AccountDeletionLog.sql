CREATE TABLE [dbo].[AccountDeletionLog] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT         NULL,
    [CompanyName]      NVARCHAR (255) NULL,
    [CreatedTimestamp] DATETIME       NULL,
    [DeletedBy]        NVARCHAR (255) NULL,
    [Description]      VARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

