CREATE TABLE [dbo].[ServiceTask] (
    [Id]                 BIGINT        IDENTITY (1, 1) NOT NULL,
    [JobId]              BIGINT        NOT NULL,
    [EntityId]           BIGINT        NOT NULL,
    [EntityTypeId]       INT           NOT NULL,
    [StatusId]           INT           NOT NULL,
    [Notes]              VARCHAR (255) NULL,
    [CompletedTimestamp] DATETIME      NULL,
    [ParentEntityId]     BIGINT        NULL,
    CONSTRAINT [PK_ServiceTask] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ServiceTask_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_ServiceTask_ServiceJob] FOREIGN KEY ([JobId]) REFERENCES [dbo].[ServiceJob] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ServiceTask_JobId]
    ON [dbo].[ServiceTask]([JobId] ASC)
    INCLUDE([Id], [EntityId], [EntityTypeId], [StatusId], [Notes], [CompletedTimestamp], [ParentEntityId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [COVIX_ServiceTask_GetNonDuplicateServiceTasks]
    ON [dbo].[ServiceTask]([EntityId] ASC, [EntityTypeId] ASC, [StatusId] ASC)
    INCLUDE([Id], [JobId]) WITH (FILLFACTOR = 100);


GO

