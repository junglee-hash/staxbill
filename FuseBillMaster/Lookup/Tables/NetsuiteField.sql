CREATE TABLE [Lookup].[NetsuiteField] (
    [Id]                   INT           NOT NULL,
    [Name]                 VARCHAR (50)  NOT NULL,
    [PropertyName]         VARCHAR (255) NULL,
    [AvailableOnEntityIds] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_NetsuiteField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

