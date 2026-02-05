CREATE TABLE [dbo].[CollectionNote] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerId]       BIGINT         NOT NULL,
    [UserId]           BIGINT         NOT NULL,
    [Content]          NVARCHAR (280) NOT NULL,
    [CreatedTimestamp] DATETIME       NOT NULL,
    [IsDeleted]        BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CollectionNote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CollectionNote_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CollectionNote_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

