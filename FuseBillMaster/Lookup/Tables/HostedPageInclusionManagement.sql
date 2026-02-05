CREATE TABLE [Lookup].[HostedPageInclusionManagement] (
    [Id]   TINYINT       NOT NULL,
    [Name] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_HostedPageInclusionManagement] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

