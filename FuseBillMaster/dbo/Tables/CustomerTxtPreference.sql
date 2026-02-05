CREATE TABLE [dbo].[CustomerTxtPreference] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerId]        BIGINT   NOT NULL,
    [TxtTypeId]         INT      NOT NULL,
    [Enabled]           BIT      NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_CustomerTxtPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerTxtPreference_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerTxtPreference_TxtType] FOREIGN KEY ([TxtTypeId]) REFERENCES [Lookup].[TxtType] ([Id])
);


GO

