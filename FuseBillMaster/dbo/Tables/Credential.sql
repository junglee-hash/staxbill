CREATE TABLE [dbo].[Credential] (
    [UserId]            BIGINT         NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [Username]          NVARCHAR (255) NOT NULL,
    [Password]          NVARCHAR (255) NOT NULL,
    [Salt]              VARCHAR (1000) NOT NULL,
    [UsesNewEncryption] BIT            CONSTRAINT [df_UsesNewEncryption] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Credential] PRIMARY KEY CLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Credential_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id]),
    CONSTRAINT [UK_Credential_Username] UNIQUE NONCLUSTERED ([Username] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

