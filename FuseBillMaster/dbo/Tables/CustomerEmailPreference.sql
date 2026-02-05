CREATE TABLE [dbo].[CustomerEmailPreference] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerId]        BIGINT   NOT NULL,
    [EmailType]         INT      NOT NULL,
    [Enabled]           BIT      NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    [EmailCategoryId]   INT      NULL,
    CONSTRAINT [PK_CustomerEmailPreferenceNew] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerEmailPreference_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_CustomerEmailPreference_EmailCategory] FOREIGN KEY ([EmailCategoryId]) REFERENCES [Lookup].[EmailCategory] ([Id]),
    CONSTRAINT [FK_CustomerEmailPreference_EmailTemplateType] FOREIGN KEY ([EmailType]) REFERENCES [Lookup].[EmailTemplateType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailPreference_CustomerId]
    ON [dbo].[CustomerEmailPreference]([CustomerId] ASC)
    INCLUDE([Id], [EmailType], [Enabled], [CreatedTimestamp], [ModifiedTimestamp]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

