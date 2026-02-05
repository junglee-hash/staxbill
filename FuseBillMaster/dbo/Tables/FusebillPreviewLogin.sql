CREATE TABLE [dbo].[FusebillPreviewLogin] (
    [Id]               BIGINT           IDENTITY (1, 1) NOT NULL,
    [Token]            UNIQUEIDENTIFIER NOT NULL,
    [UserId]           BIGINT           NOT NULL,
    [CreatedTimestamp] DATETIME         NOT NULL,
    [Consumed]         BIT              CONSTRAINT [DF_FusebillPreviewLogin_Consumed] DEFAULT ((0)) NOT NULL,
    [AccountId]        BIGINT           NOT NULL,
    [ForDevice]        BIT              CONSTRAINT [df_FusebillPreviewLogin_ForDevice] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_FusebillPreviewLogin] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_FusebillPreviewLogin_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_FusebillPreviewLogin_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_FusebillPreviewLogin_AccountId]
    ON [dbo].[FusebillPreviewLogin]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

