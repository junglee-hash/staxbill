CREATE TABLE [dbo].[GLCodeLedger] (
    [Id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [GlCodeId]                BIGINT         NOT NULL,
    [AccountDisplaySettingId] BIGINT         NOT NULL,
    [Reference]               NVARCHAR (100) NULL,
    CONSTRAINT [PK_GLCodeLegers] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_GLCodeLedgers_GlCodeId] FOREIGN KEY ([GlCodeId]) REFERENCES [dbo].[GLCode] ([Id])
);


GO

