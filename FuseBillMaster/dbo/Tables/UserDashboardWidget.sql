CREATE TABLE [dbo].[UserDashboardWidget] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [UserId]            BIGINT   NOT NULL,
    [DashboardWidgetId] BIGINT   NOT NULL,
    [SortOrder]         INT      NOT NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_UserDashboardWidget] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_UserDashboardWidget_DefaultDashboardWidget] FOREIGN KEY ([DashboardWidgetId]) REFERENCES [dbo].[DefaultDashboardWidget] ([Id]),
    CONSTRAINT [FK_UserDashboardWidget_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

