CREATE TABLE [dbo].[PaymentActivityJournal] (
    [Id]                                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [CustomerId]                           BIGINT           NOT NULL,
    [Amount]                               MONEY            NOT NULL,
    [AuthorizationCode]                    VARCHAR (255)    NULL,
    [PaymentSourceId]                      INT              NOT NULL,
    [PaymentActivityStatusId]              INT              NOT NULL,
    [PaymentTypeId]                        INT              NOT NULL,
    [CreatedTimestamp]                     DATETIME         NOT NULL,
    [ModifiedTimestamp]                    DATETIME         NOT NULL,
    [EffectiveTimestamp]                   DATETIME         NOT NULL,
    [AuthorizationResponse]                VARCHAR (500)    NULL,
    [PaymentMethodTypeId]                  INT              NOT NULL,
    [CurrencyId]                           BIGINT           NOT NULL,
    [PaymentPlatformCode]                  VARCHAR (255)    NULL,
    [GatewayId]                            BIGINT           NULL,
    [GatewayName]                          NVARCHAR (255)   NULL,
    [PaymentMethodId]                      BIGINT           NULL,
    [SecondaryTransactionNumber]           VARCHAR (255)    NULL,
    [AttemptNumber]                        TINYINT          DEFAULT ((0)) NOT NULL,
    [ParentCustomerId]                     BIGINT           NULL,
    [ReconciliationId]                     UNIQUEIDENTIFIER NULL,
    [SettlementStatusId]                   TINYINT          CONSTRAINT [df_SettlementStatusId] DEFAULT ((1)) NOT NULL,
    [SettlementStatusModifiedTimestamp]    DATETIME         NULL,
    [SettlementStatusLastCheckedTimestamp] DATETIME         NULL,
    [SettlementStatusNextCheckTimestamp]   DATETIME         NULL,
    [SettlementStatusMessage]              VARCHAR (500)    NULL,
    [GatewayFee]                           DECIMAL (18, 6)  NULL,
    [PrimaryGatewayFailure]                VARCHAR (500)    NULL,
    [SurchargingFee]                       MONEY            NULL,
    [Trigger]                              NVARCHAR (255)   NULL,
    [TriggeringUserId]                     BIGINT           NULL,
    [IsDebit]                              BIT              CONSTRAINT [DF_IsDebit_Paj] DEFAULT (NULL) NULL,
    [ProcessorTypeId]                      INT              NULL,
    [AccountId]                            BIGINT           NOT NULL,
    [DisputeStatusId]                      TINYINT          NULL,
    [ExternalDisputeId]                    VARCHAR (255)    NULL,
    CONSTRAINT [PK_PaymentActivityJournal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PaymentActivityJournal_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PaymentActivityJournal_DisputeStatusId] FOREIGN KEY ([DisputeStatusId]) REFERENCES [Lookup].[DisputeStatus] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_ParentCustomer] FOREIGN KEY ([ParentCustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_PaymentMethod] FOREIGN KEY ([PaymentMethodId]) REFERENCES [dbo].[PaymentMethod] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PaymentActivityJournal_PaymentMethodType] FOREIGN KEY ([PaymentMethodTypeId]) REFERENCES [Lookup].[PaymentMethodType] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_PaymentSource] FOREIGN KEY ([PaymentSourceId]) REFERENCES [Lookup].[PaymentSource] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_PaymentStatus] FOREIGN KEY ([PaymentActivityStatusId]) REFERENCES [Lookup].[PaymentActivityStatus] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_PaymentType] FOREIGN KEY ([PaymentTypeId]) REFERENCES [Lookup].[PaymentType] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_Processor] FOREIGN KEY ([ProcessorTypeId]) REFERENCES [Lookup].[ProcessorType] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_SettlementStatusId] FOREIGN KEY ([SettlementStatusId]) REFERENCES [Lookup].[SettlementStatus] ([Id]),
    CONSTRAINT [FK_PaymentActivityJournal_TriggeringUserId] FOREIGN KEY ([TriggeringUserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_CurrencyId]
    ON [dbo].[PaymentActivityJournal]([CurrencyId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_PaymentActivityStatusId_PaymentTypeId_CreatedTimestamp]
    ON [dbo].[PaymentActivityJournal]([PaymentActivityStatusId] ASC, [PaymentTypeId] ASC, [CreatedTimestamp] ASC)
    INCLUDE([Id], [CustomerId], [Amount], [PaymentSourceId], [PaymentMethodTypeId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_PaymentTypeId]
    ON [dbo].[PaymentActivityJournal]([PaymentTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [COVIX_PaymentActivityJournal_PaymentActivityStatusId_PaymentTypeId_EffectiveTimestamp_CurrencyId]
    ON [dbo].[PaymentActivityJournal]([PaymentActivityStatusId] ASC, [PaymentTypeId] ASC, [EffectiveTimestamp] ASC, [CustomerId] ASC, [CurrencyId] ASC);


GO

CREATE NONCLUSTERED INDEX [FKIX_PaymentActivityJournal_PaymentMethodId]
    ON [dbo].[PaymentActivityJournal]([PaymentMethodId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_CustomerId]
    ON [dbo].[PaymentActivityJournal]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_PaymentPlatformCode]
    ON [dbo].[PaymentActivityJournal]([PaymentPlatformCode] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_SettlementStatusId]
    ON [dbo].[PaymentActivityJournal]([SettlementStatusId] ASC)
    INCLUDE([CustomerId], [SettlementStatusNextCheckTimestamp]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentActivityJournal_AccountId]
    ON [dbo].[PaymentActivityJournal]([AccountId] ASC)
    INCLUDE([Id]);


GO

