CREATE TABLE [dbo].[CustomerReference] (
    [Id]                   BIGINT        NOT NULL,
    [Reference1]           VARCHAR (255) NULL,
    [Reference2]           VARCHAR (255) NULL,
    [Reference3]           VARCHAR (255) NULL,
    [CreatedTimestamp]     DATETIME      NOT NULL,
    [ModifiedTimestamp]    DATETIME      NOT NULL,
    [ClassicId]            BIGINT        NULL,
    [SalesTrackingCode1Id] BIGINT        NULL,
    [SalesTrackingCode2Id] BIGINT        NULL,
    [SalesTrackingCode3Id] BIGINT        NULL,
    [SalesTrackingCode4Id] BIGINT        NULL,
    [SalesTrackingCode5Id] BIGINT        NULL,
    CONSTRAINT [PK_CustomerReference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerReference_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerReference_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_CustomerReference_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_CustomerReference_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_CustomerReference_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_CustomerReference_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerReference_SalesTrackingCode1Id]
    ON [dbo].[CustomerReference]([SalesTrackingCode1Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerReference_SalesTrackingCode2Id]
    ON [dbo].[CustomerReference]([SalesTrackingCode2Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerReference_SalesTrackingCode3Id]
    ON [dbo].[CustomerReference]([SalesTrackingCode3Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerReference_SalesTrackingCode4Id]
    ON [dbo].[CustomerReference]([SalesTrackingCode4Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerReference_SalesTrackingCode5Id]
    ON [dbo].[CustomerReference]([SalesTrackingCode5Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

