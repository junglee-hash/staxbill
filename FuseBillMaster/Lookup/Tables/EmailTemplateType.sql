CREATE TABLE [Lookup].[EmailTemplateType] (
    [Id]          INT           NOT NULL,
    [Name]        VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (255) NULL,
    [SortOrder]   TINYINT       NULL,
    CONSTRAINT [PK_EmailTemplateType_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

