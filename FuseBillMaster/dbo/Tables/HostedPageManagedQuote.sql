CREATE TABLE [dbo].[HostedPageManagedQuote] (
    [Id]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [UniqueId]     UNIQUEIDENTIFIER NOT NULL,
    [HostedPageId] BIGINT           NOT NULL,
    [FriendlyName] NVARCHAR (100)   NOT NULL,
    [Key]          NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_HostedPageManagedQuote] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedQuote_HostedPage] FOREIGN KEY ([HostedPageId]) REFERENCES [dbo].[HostedPage] ([Id])
);


GO

