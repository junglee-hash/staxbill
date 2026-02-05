CREATE TABLE [dbo].[AnrokConfiguration] (
    [Id]                BIGINT        NOT NULL,
    [Enabled]           BIT           NOT NULL,
    [ApiKey]            VARCHAR (255) NOT NULL,
    [EncryptSalt]       VARCHAR (100) NOT NULL,
    [DevMode]           BIT           NOT NULL,
    [CreatedTimestamp]  DATETIME      NOT NULL,
    [ModifiedTimestamp] DATETIME      NOT NULL,
    [DefaultProductId]  VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_AnrokConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AnrokConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id])
);


GO

