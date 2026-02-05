CREATE TABLE [dbo].[GLCode] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT         NOT NULL,
    [Code]              NVARCHAR (255) NOT NULL,
    [Name]              NVARCHAR (100) NOT NULL,
    [StatusId]          INT            NOT NULL,
    [Used]              BIT            NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    CONSTRAINT [PK_GLCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_GLCode_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_GLCode_Status] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[GLCodeStatus] ([Id]),
    CONSTRAINT [uc_GLCode_AccountId_Code] UNIQUE NONCLUSTERED ([AccountId] ASC, [Code] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_GLCode_StatusId]
    ON [dbo].[GLCode]([StatusId] ASC) WITH (FILLFACTOR = 100);


GO

