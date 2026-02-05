CREATE TABLE [dbo].[DefaultTemplatePreference] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [Type]            BIGINT         NOT NULL,
    [Name]            NVARCHAR (50)  NOT NULL,
    [Value]           NVARCHAR (MAX) NOT NULL,
    [EmailCategoryId] INT            NOT NULL,
    CONSTRAINT [PK_DefaultTemplatePreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DefaultTemplatePreference_EmailCategory] FOREIGN KEY ([EmailCategoryId]) REFERENCES [Lookup].[EmailCategory] ([Id])
);


GO

