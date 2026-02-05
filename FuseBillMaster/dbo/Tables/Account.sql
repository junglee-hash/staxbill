CREATE TABLE [dbo].[Account] (
    [Id]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]            DATETIME        NOT NULL,
    [ModifiedTimestamp]           DATETIME        NOT NULL,
    [ContactEmail]                NVARCHAR (255)  NULL,
    [CompanyName]                 NVARCHAR (255)  NULL,
    [FusebillTest]                BIT             CONSTRAINT [DF_Account_FusebillTest] DEFAULT ((0)) NULL,
    [Signed]                      BIT             CONSTRAINT [DF_Account_Signed] DEFAULT ((0)) NULL,
    [Live]                        BIT             CONSTRAINT [DF_Account_Live] DEFAULT ((0)) NULL,
    [PublicApiKey]                VARCHAR (255)   NOT NULL,
    [OriginUrlForPublicApiKey]    NVARCHAR (2000) NULL,
    [TypeId]                      TINYINT         NULL,
    [LiveTimestamp]               DATETIME        NULL,
    [DeletedTimestamp]            DATETIME        NULL,
    [DeletedBy]                   NVARCHAR (255)  NULL,
    [AccountServiceProviderId]    BIGINT          CONSTRAINT [DF_AccountServiceProvider] DEFAULT ((1)) NOT NULL,
    [FusebillIncId]               BIGINT          NULL,
    [Note]                        VARCHAR (250)   NULL,
    [IncludeInAutomatedProcesses] BIT             CONSTRAINT [DF_IncludeInAutomatedProcesses] DEFAULT ((0)) NOT NULL,
    [ProcessEarningRegardless]    BIT             CONSTRAINT [DF_ProcessEarningRegardless] DEFAULT ((0)) NOT NULL,
    [ShutdownDate]                DATETIME        NULL,
    [ShutdownReason]              NVARCHAR (1000) NULL,
    [ShutdownUser]                NVARCHAR (255)  NULL,
    CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Account_AccountServiceProviderId] FOREIGN KEY ([AccountServiceProviderId]) REFERENCES [dbo].[AccountServiceProviderTemplate] ([Id]),
    CONSTRAINT [FK_Account_AccountType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[AccountType] ([Id]),
    CONSTRAINT [UK_Account_PublicApiKey] UNIQUE NONCLUSTERED ([PublicApiKey] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_Account_CompanyName]
    ON [dbo].[Account]([CompanyName] ASC)
    INCLUDE([Id], [ContactEmail]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

