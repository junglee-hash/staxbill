CREATE TABLE [dbo].[AccountNetsuiteCreditItemMapping] (
    [Id]                             BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountNetsuiteConfigurationId] BIGINT         NOT NULL,
    [NetsuiteItemId]                 NVARCHAR (255) NOT NULL,
    [CreatedTimestamp]               DATETIME       NOT NULL,
    [ModifiedTimestamp]              DATETIME       NOT NULL,
    CONSTRAINT [PK_AccountNetsuiteCreditItemMapping] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountNetsuiteCreditItemMapping_AccountNetsuiteConfiguration] FOREIGN KEY ([AccountNetsuiteConfigurationId]) REFERENCES [dbo].[AccountNetsuiteConfiguration] ([Id]) ON DELETE CASCADE
);


GO

