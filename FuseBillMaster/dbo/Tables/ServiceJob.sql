CREATE TABLE [dbo].[ServiceJob] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT         NOT NULL,
    [TypeId]             INT            NOT NULL,
    [StatusId]           INT            NOT NULL,
    [StartTimestamp]     DATETIME       NULL,
    [CompletedTimestamp] DATETIME       NULL,
    [CreatedTimestamp]   DATETIME       NOT NULL,
    [ModifiedTimestamp]  DATETIME       NOT NULL,
    [AdditionalData]     VARCHAR (2000) NULL,
    [ParentEntityId]     BIGINT         NULL,
    [TotalCount]         INT            NULL,
    [TotalSuccessful]    INT            NULL,
    [TotalFailed]        INT            NULL,
    [IsOffline]          BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ServiceJob] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ServiceJob_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_ServiceJob_JobStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[ServiceJobStatus] ([Id]),
    CONSTRAINT [FK_ServiceJob_JobType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[ServiceJobType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_ServiceJob_AccountId]
    ON [dbo].[ServiceJob]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ServiceJob_StatusId]
    ON [dbo].[ServiceJob]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ServiceJob_TypeId]
    ON [dbo].[ServiceJob]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

