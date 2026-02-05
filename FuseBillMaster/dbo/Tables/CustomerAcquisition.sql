CREATE TABLE [dbo].[CustomerAcquisition] (
    [Id]                BIGINT        NOT NULL,
    [AdContent]         VARCHAR (255) NULL,
    [Campaign]          VARCHAR (255) NULL,
    [Keyword]           VARCHAR (255) NULL,
    [LandingPage]       VARCHAR (255) NULL,
    [Medium]            VARCHAR (255) NULL,
    [Source]            VARCHAR (255) NULL,
    [CreatedTimestamp]  DATETIME      NOT NULL,
    [ModifiedTimestamp] DATETIME      NOT NULL,
    [SystemSource]      VARCHAR (255) NULL,
    CONSTRAINT [PK_CustomerAcquisition] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerAcquisition_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id])
);


GO

