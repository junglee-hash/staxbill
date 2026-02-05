CREATE TABLE [dbo].[AccountPreference] (
    [Id]                BIGINT   NOT NULL,
    [TimezoneId]        BIGINT   NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    [MinPasswordLength] INT      CONSTRAINT [DF_MinPasswordLength] DEFAULT ((8)) NOT NULL,
    [MaxFailedLogins]   INT      CONSTRAINT [DF_MaxFailedLogins] DEFAULT ((10)) NOT NULL,
    [MfaRequired]       BIT      CONSTRAINT [DF_MfaRequired] DEFAULT ((1)) NOT NULL,
    [MfaTrustPeriod]    INT      DEFAULT ((7)) NOT NULL,
    CONSTRAINT [PK_AccountPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountPreference_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountPreference_Timezone] FOREIGN KEY ([TimezoneId]) REFERENCES [Lookup].[Timezone] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountPreference_TimezoneId]
    ON [dbo].[AccountPreference]([TimezoneId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

