CREATE TABLE [Lookup].[FusebillField] (
    [Id]                     INT           NOT NULL,
    [Name]                   VARCHAR (50)  NOT NULL,
    [PropertyName]           VARCHAR (255) NULL,
    [AvailableForSalesforce] BIT           DEFAULT ((0)) NOT NULL,
    [AvailableForHubspot]    BIT           CONSTRAINT [DF_AvailableForHubspot] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FusebillField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

