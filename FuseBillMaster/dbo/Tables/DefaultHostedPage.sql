CREATE TABLE [dbo].[DefaultHostedPage] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [HostedPageTypeId] INT            NOT NULL,
    [Section]          NVARCHAR (50)  NOT NULL,
    [DefaultMarkup]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_DefaultHostedPage] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DefaultHostedPage_HostedPageType] FOREIGN KEY ([HostedPageTypeId]) REFERENCES [Lookup].[HostedPageType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DefaultHostedPage_HostedPageTypeId]
    ON [dbo].[DefaultHostedPage]([HostedPageTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

