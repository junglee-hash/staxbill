CREATE TABLE [dbo].[AccountChannelBulkEventExclusion] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT   NOT NULL,
    [ChannelId]        INT      NOT NULL,
    [CreatedTimestamp] DATETIME NULL,
    CONSTRAINT [PK_AccountChannelBulkEventExclusion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountChannelBulkEventExclusion_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountChannelBulkEventExclusion_AccountId]
    ON [dbo].[AccountChannelBulkEventExclusion]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

