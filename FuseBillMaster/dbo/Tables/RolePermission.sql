CREATE TABLE [dbo].[RolePermission] (
    [Id]           BIGINT IDENTITY (1, 1) NOT NULL,
    [RoleId]       BIGINT NOT NULL,
    [PermissionId] BIGINT NOT NULL,
    [ParentId]     BIGINT NULL,
    [SortOrder]    INT    NOT NULL,
    [Allowed]      BIT    NOT NULL,
    CONSTRAINT [PK_RolePermission] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_RolePermission_Permission] FOREIGN KEY ([PermissionId]) REFERENCES [Lookup].[Permission] ([Id]),
    CONSTRAINT [FK_RolePermission_Role] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[Role] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_RolePermission_PermissionId]
    ON [dbo].[RolePermission]([PermissionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_RolePermission_RoleId]
    ON [dbo].[RolePermission]([RoleId] ASC)
    INCLUDE([Id], [PermissionId], [ParentId], [SortOrder], [Allowed]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

