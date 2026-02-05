CREATE TABLE [dbo].[SalesforceOneTimeAuthorizationToken] (
    [Id]                 BIGINT           IDENTITY (1, 1) NOT NULL,
    [AuthorizationToken] UNIQUEIDENTIFIER NOT NULL,
    [AccountId]          BIGINT           NOT NULL,
    [CreatedTimestamp]   DATETIME         NOT NULL,
    CONSTRAINT [PK_SalesforceOneTimeAuthorizationToken] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SalesforceOneTimeAuthorizationToken_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SalesforceOneTimeAuthorizationToken_AccountId]
    ON [dbo].[SalesforceOneTimeAuthorizationToken]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

