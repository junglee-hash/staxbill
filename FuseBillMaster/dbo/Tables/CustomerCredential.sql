CREATE TABLE [dbo].[CustomerCredential] (
    [Id]                BIGINT        NOT NULL,
    [Username]          NVARCHAR (50) NULL,
    [Password]          VARCHAR (255) NULL,
    [Salt]              VARCHAR (255) NULL,
    [AccountId]         BIGINT        NOT NULL,
    [CreatedTimestamp]  DATETIME      NULL,
    [ModifiedTimestamp] DATETIME      NULL,
    CONSTRAINT [PK_CustomerCredential] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerCredential_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_CustomerCredential_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_CustomerCredential]
    ON [dbo].[CustomerCredential]([AccountId] ASC, [Username] ASC) WHERE ([Username] IS NOT NULL) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerCredential_AccountId]
    ON [dbo].[CustomerCredential]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

