CREATE TABLE [dbo].[CustomerTxtControl] (
    [Id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerId]       BIGINT       NOT NULL,
    [TxtKey]           VARCHAR (50) NOT NULL,
    [CreatedTimestamp] DATETIME     NOT NULL,
    CONSTRAINT [PK_TxtCommunication] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_TxtCommunication_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [UK_CustomerTxtControl_CustomerId_TxtKey] UNIQUE NONCLUSTERED ([CustomerId] ASC, [TxtKey] ASC) WITH (FILLFACTOR = 100)
);


GO

