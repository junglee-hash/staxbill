CREATE TABLE [dbo].[Role] (
    [Id]                        BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                 BIGINT         NOT NULL,
    [ModifiedTimestamp]         DATETIME       NOT NULL,
    [CreatedTimestamp]          DATETIME       NOT NULL,
    [Name]                      NVARCHAR (100) NOT NULL,
    [Description]               NVARCHAR (255) NULL,
    [Locked]                    BIT            DEFAULT ((0)) NOT NULL,
    [LockedToSalesTrackingCode] BIT            DEFAULT ((0)) NOT NULL,
    [SalesTrackingCodeTypeId]   INT            NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Role_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [uc_Role_AccountId_Name] UNIQUE NONCLUSTERED ([AccountId] ASC, [Name] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

