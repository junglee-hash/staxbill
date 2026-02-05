CREATE TABLE [dbo].[AccountApiKey] (
    [Id]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                BIGINT         NOT NULL,
    [Key]                      NVARCHAR (255) NOT NULL,
    [ApiKeyTypeId]             INT            NOT NULL,
    [ApiKeyStatusId]           INT            NULL,
    [PerDayLimit]              BIGINT         NULL,
    [IsWhitelisted]            BIT            CONSTRAINT [IsWhitelisted] DEFAULT ((0)) NOT NULL,
    [PerMinuteLimit]           BIGINT         NULL,
    [RecaptchaTypeId]          INT            CONSTRAINT [df_RecaptchaTypeId] DEFAULT ((1)) NOT NULL,
    [ExternalRecaptchaKey]     NVARCHAR (255) NULL,
    [ExternalRecaptchaKeySalt] VARCHAR (1000) NULL,
    [PublicRecaptchaKey]       NVARCHAR (255) NULL,
    [PublicRecaptchaKeySalt]   VARCHAR (1000) NULL,
    [SecretRecaptchaKey]       NVARCHAR (255) NULL,
    [SecretRecaptchaKeySalt]   VARCHAR (1000) NULL,
    CONSTRAINT [PK_AccountApiKey] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountApiKey_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountApiKey_ApiKeyStatus] FOREIGN KEY ([ApiKeyStatusId]) REFERENCES [Lookup].[ApiKeyStatus] ([Id]),
    CONSTRAINT [FK_AccountApiKey_ApiKeyType] FOREIGN KEY ([ApiKeyTypeId]) REFERENCES [Lookup].[ApiKeyType] ([Id]),
    CONSTRAINT [FK_RecaptchaTypeId] FOREIGN KEY ([RecaptchaTypeId]) REFERENCES [Lookup].[RecaptchaType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountApiKey_AccountId]
    ON [dbo].[AccountApiKey]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountApiKey_ApiKeyTypeId]
    ON [dbo].[AccountApiKey]([ApiKeyTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_AccountApiKey_Key]
    ON [dbo].[AccountApiKey]([Key] ASC) WITH (FILLFACTOR = 100);


GO

