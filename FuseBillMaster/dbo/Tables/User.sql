CREATE TABLE [dbo].[User] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [Email]             VARCHAR (255)  NULL,
    [FirstName]         NVARCHAR (500) NULL,
    [LastName]          NVARCHAR (500) NULL,
    [LoginAttempts]     INT            CONSTRAINT [df_User_LoginAttempts] DEFAULT ((0)) NOT NULL,
    [LockTimestamp]     DATETIME       CONSTRAINT [df_User_LockTimestamp] DEFAULT (NULL) NULL,
    [MfaSecretyKey]     VARCHAR (255)  NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

