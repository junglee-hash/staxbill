CREATE TABLE [dbo].[AccountTxtTemplate] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT         NOT NULL,
    [TxtTypeId]         INT            NOT NULL,
    [TxtBody]           NVARCHAR (500) NOT NULL,
    [Enabled]           BIT            NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [Option1]           BIT            CONSTRAINT [DF_AccountTxtTemplate_Option1] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountTxtTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountTxtTemplate_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountTxtTemplate_TxtType] FOREIGN KEY ([TxtTypeId]) REFERENCES [Lookup].[TxtType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountTxtTemplate_AccountId]
    ON [dbo].[AccountTxtTemplate]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

