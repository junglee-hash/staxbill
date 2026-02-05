CREATE TABLE [dbo].[HubSpotAuthenticationToken] (
    [Id]               BIGINT           IDENTITY (1, 1) NOT NULL,
    [Token]            UNIQUEIDENTIFIER NOT NULL,
    [AccountId]        BIGINT           NOT NULL,
    [CreatedTimestamp] DATETIME         NOT NULL,
    CONSTRAINT [PK_HubSpotAuthenticationToken] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HubSpotAuthenticationToken_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [UX_HubSpotAuthenticationToken] UNIQUE NONCLUSTERED ([Token] ASC) WITH (FILLFACTOR = 100)
);


GO

CREATE NONCLUSTERED INDEX [IX_HubSpotAuthenticationToken_Account_CreatedTimestamp]
    ON [dbo].[HubSpotAuthenticationToken]([AccountId] ASC, [CreatedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

