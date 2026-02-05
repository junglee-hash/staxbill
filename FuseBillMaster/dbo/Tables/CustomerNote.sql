CREATE TABLE [dbo].[CustomerNote] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerId]        BIGINT         NOT NULL,
    [UserId]            BIGINT         NULL,
    [Note]              VARCHAR (2000) NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [Editable]          BIT            CONSTRAINT [DF_CustomerNote_Editable] DEFAULT ((1)) NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [SourceApplication] NVARCHAR (50)  NULL,
    CONSTRAINT [PK_CustomerNote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerNote_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerNote_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerNote_UserId]
    ON [dbo].[CustomerNote]([UserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerNote_CustomerId]
    ON [dbo].[CustomerNote]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

