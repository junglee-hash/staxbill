CREATE TABLE [dbo].[AccountUserRole] (
    [Id]                  BIGINT IDENTITY (1, 1) NOT NULL,
    [RoleTypeId]          INT    NOT NULL,
    [AccountUserId]       BIGINT NOT NULL,
    [RoleId]              BIGINT NULL,
    [SalesTrackingCodeId] BIGINT NULL,
    CONSTRAINT [PK_AccountUserRole] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountUserRole_AccountUser] FOREIGN KEY ([AccountUserId]) REFERENCES [dbo].[AccountUser] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AccountUserRole_CustomRole] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([Id]),
    CONSTRAINT [FK_AccountUserRole_Role] FOREIGN KEY ([RoleTypeId]) REFERENCES [Lookup].[RoleType] ([Id]),
    CONSTRAINT [FK_AccountUserRole_SalesTrackingCode] FOREIGN KEY ([SalesTrackingCodeId]) REFERENCES [dbo].[SalesTrackingCode] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUserRole_RoleId]
    ON [dbo].[AccountUserRole]([RoleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUserRole_RoleTypeId]
    ON [dbo].[AccountUserRole]([RoleTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUserRole_AccountUserId]
    ON [dbo].[AccountUserRole]([AccountUserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

