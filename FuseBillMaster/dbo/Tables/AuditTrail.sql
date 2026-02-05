CREATE TABLE [dbo].[AuditTrail] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT         NOT NULL,
    [CustomerId]         BIGINT         NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [LogExpiryTimestamp] DATETIME       NULL,
    [CategoryId]         INT            NOT NULL,
    [SourceId]           INT            NOT NULL,
    [CustomSource]       NVARCHAR (255) NULL,
    [EntityId]           INT            NOT NULL,
    [EntityValue]        NVARCHAR (255) NULL,
    [ActionId]           INT            NOT NULL,
    [ResultId]           INT            NOT NULL,
    [UserId]             BIGINT         NULL,
    [Details]            NVARCHAR (MAX) NULL,
    [IpAddress]          VARCHAR (100)  NULL,
    CONSTRAINT [PK_AuditTrail] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AuditTrail_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AuditTrail_Action] FOREIGN KEY ([ActionId]) REFERENCES [Lookup].[Action] ([Id]),
    CONSTRAINT [FK_AuditTrail_AuditCategory] FOREIGN KEY ([CategoryId]) REFERENCES [Lookup].[AuditCategory] ([Id]),
    CONSTRAINT [FK_AuditTrail_AuditResult] FOREIGN KEY ([ResultId]) REFERENCES [Lookup].[AuditResult] ([Id]),
    CONSTRAINT [FK_AuditTrail_AuditSource] FOREIGN KEY ([SourceId]) REFERENCES [Lookup].[AuditSource] ([Id]),
    CONSTRAINT [FK_AuditTrail_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AuditTrail_EntityType] FOREIGN KEY ([EntityId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_AuditTrail_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AuditTrail_AccountId]
    ON [dbo].[AuditTrail]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_AuditTrail_CustomerId_AccountId]
    ON [dbo].[AuditTrail]([CustomerId] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100);


GO

