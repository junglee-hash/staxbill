CREATE TABLE [dbo].[CustomerTextLog] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomerId]         BIGINT          NOT NULL,
    [Body]               NVARCHAR (2000) NOT NULL,
    [PhoneNumber]        VARCHAR (50)    NULL,
    [TxtTypeId]          INT             NOT NULL,
    [TxtStatusId]        INT             NOT NULL,
    [Result]             NVARCHAR (500)  NULL,
    [CreatedTimestamp]   DATETIME        NOT NULL,
    [SentTimestamp]      DATETIME        NULL,
    [ModifiedTimestamp]  DATETIME        NOT NULL,
    [TwilioMessagingSid] VARCHAR (100)   NULL,
    CONSTRAINT [PK_CustomerTextLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerTextLog_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerTextLog_TxtStatus] FOREIGN KEY ([TxtStatusId]) REFERENCES [Lookup].[TxtStatus] ([Id]),
    CONSTRAINT [FK_CustomerTextLog_TxtType] FOREIGN KEY ([TxtTypeId]) REFERENCES [Lookup].[TxtType] ([Id])
);


GO

