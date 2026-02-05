CREATE TABLE [dbo].[AccountDisplaySetting] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT         NOT NULL,
    [EntityTypeId]      INT            NULL,
    [CategoryId]        TINYINT        NOT NULL,
    [Key]               VARCHAR (255)  NULL,
    [Label]             VARCHAR (255)  NULL,
    [Value]             NVARCHAR (100) NOT NULL,
    [CreatedTimestamp]  DATETIME       CONSTRAINT [DF_AccountDisplaySetting_CreatedTimestamp] DEFAULT (getutcdate()) NOT NULL,
    [ModifiedTimestamp] DATETIME       CONSTRAINT [DF_AccountDisplaySetting_ModifiedTimestamp] DEFAULT (getutcdate()) NOT NULL,
    [LookupId]          INT            NULL,
    [Reference]         VARCHAR (100)  NULL,
    CONSTRAINT [PK_AccountDisplaySetting] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountDisplaySetting_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountDisplaySetting_Category] FOREIGN KEY ([CategoryId]) REFERENCES [Lookup].[AccountDisplaySettingCategory] ([Id]),
    CONSTRAINT [FK_AccountDisplaySetting_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountDisplaySetting_AccountId]
    ON [dbo].[AccountDisplaySetting]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

