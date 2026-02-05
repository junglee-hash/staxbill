CREATE TABLE [Lookup].[SalesforceField] (
    [Id]           INT           NOT NULL,
    [Name]         VARCHAR (50)  NOT NULL,
    [PropertyName] VARCHAR (255) NULL,
    CONSTRAINT [PK_SalesforceField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

