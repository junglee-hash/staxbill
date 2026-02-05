CREATE TABLE [dbo].[FusebillSupportLogin] (
    [Id]               BIGINT           IDENTITY (1, 1) NOT NULL,
    [Token]            UNIQUEIDENTIFIER NOT NULL,
    [UserId]           BIGINT           NOT NULL,
    [CreatedTimestamp] DATETIME         NOT NULL,
    [Consumed]         BIT              CONSTRAINT [DF_FusebillSupportLogin_Consumed] DEFAULT ((0)) NOT NULL,
    [AccountId]        BIGINT           NOT NULL,
    [CustomerId]       BIGINT           NULL,
    CONSTRAINT [PK_FusebillSupportLogin] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FusebillSupportLogin_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_FusebillSupportLogin_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_FusebillSupportLogin_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_FusebillSupportLogin_AccountId]
    ON [dbo].[FusebillSupportLogin]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_FusebillSupportLogin_CustomerId]
    ON [dbo].[FusebillSupportLogin]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_FusebillSupportLogin_UserId]
    ON [dbo].[FusebillSupportLogin]([UserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

