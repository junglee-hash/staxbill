CREATE TABLE [dbo].[AccountNetsuiteFieldMapping] (
    [Id]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]            BIGINT         NOT NULL,
    [NetsuiteEntityTypeId] INT            NOT NULL,
    [NetsuiteFieldId]      INT            NOT NULL,
    [NetsuiteCustomField]  NVARCHAR (255) NULL,
    [FusebillFieldId]      INT            NOT NULL,
    [CreatedTimestamp]     DATETIME       NOT NULL,
    CONSTRAINT [PK_AccountNetsuiteFieldMapping] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountNetsuiteFieldMapping_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountNetsuiteFieldMapping_FusebillField] FOREIGN KEY ([FusebillFieldId]) REFERENCES [Lookup].[FusebillField] ([Id]),
    CONSTRAINT [FK_AccountNetsuiteFieldMapping_NetsuiteEntity] FOREIGN KEY ([NetsuiteEntityTypeId]) REFERENCES [Lookup].[NetsuiteEntityType] ([Id]),
    CONSTRAINT [FK_AccountNetsuiteFieldMapping_NetsuiteField] FOREIGN KEY ([NetsuiteFieldId]) REFERENCES [Lookup].[NetsuiteField] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountNetsuiteFieldMapping_AccountId]
    ON [dbo].[AccountNetsuiteFieldMapping]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountNetsuiteFieldMapping_FusebillFieldId]
    ON [dbo].[AccountNetsuiteFieldMapping]([FusebillFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountNetsuiteFieldMapping_NetsuiteEntityTypeId]
    ON [dbo].[AccountNetsuiteFieldMapping]([NetsuiteEntityTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountNetsuiteFieldMapping_NetsuiteFieldId]
    ON [dbo].[AccountNetsuiteFieldMapping]([NetsuiteFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

