CREATE TABLE [dbo].[SelfServicePortalToken] (
    [Id]                BIGINT           IDENTITY (1, 1) NOT NULL,
    [Token]             UNIQUEIDENTIFIER NOT NULL,
    [CustomerId]        BIGINT           NOT NULL,
    [CreatedTimestamp]  DATETIME         NOT NULL,
    [IsConsumed]        BIT              NOT NULL,
    [TokenTypeID]       INT              CONSTRAINT [DF_SelfServicePortalToken_TokenTypeID] DEFAULT ((1)) NOT NULL,
    [RebrandlyId]       VARCHAR (100)    NULL,
    [RebrandlyShortUrl] VARCHAR (100)    NULL,
    [UserId]            BIGINT           NULL,
    CONSTRAINT [PK_SelfServicePortalToken] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([TokenTypeID]) REFERENCES [Lookup].[SSPTokenType] ([Id]),
    CONSTRAINT [FK_SelfServicePortalToken_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_SelfServicePortalToken_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id]),
    CONSTRAINT [UX_SelfServicePortalToken] UNIQUE NONCLUSTERED ([Token] ASC, [IsConsumed] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SelfServicePortalToken_CustomerId]
    ON [dbo].[SelfServicePortalToken]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SelfServicePortalToken_TokenTypeID]
    ON [dbo].[SelfServicePortalToken]([TokenTypeID] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_SelfServicePortalToken_CustomerId_TokenTypeId_Consumed]
    ON [dbo].[SelfServicePortalToken]([IsConsumed] ASC, [TokenTypeID] ASC)
    INCLUDE([Id], [CustomerId]);


GO

