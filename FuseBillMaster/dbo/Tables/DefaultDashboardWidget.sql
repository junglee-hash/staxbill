CREATE TABLE [dbo].[DefaultDashboardWidget] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [Key]                VARCHAR (50)   NOT NULL,
    [Name]               VARCHAR (100)  NOT NULL,
    [Description]        VARCHAR (1000) NOT NULL,
    [ColumnSize]         INT            NOT NULL,
    [ChildPermissionId]  BIGINT         NOT NULL,
    [ParentPermissionId] BIGINT         NOT NULL,
    [HelpTitle]          VARCHAR (50)   NULL,
    [HelpTopic]          VARCHAR (100)  NULL,
    [DashboardGroupId]   INT            NOT NULL,
    CONSTRAINT [PK_DefaultDashboardWidget] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DefaultDashboardWidget_ChildPermission] FOREIGN KEY ([ChildPermissionId]) REFERENCES [Lookup].[Permission] ([Id]),
    CONSTRAINT [fk_DefaultDashboardWidget_DashboardGroup] FOREIGN KEY ([DashboardGroupId]) REFERENCES [Lookup].[DashboardGroup] ([Id]),
    CONSTRAINT [FK_DefaultDashboardWidget_ParentPermission] FOREIGN KEY ([ParentPermissionId]) REFERENCES [Lookup].[Permission] ([Id])
);


GO

