CREATE TABLE [dbo].[SalesTrackingCode] (
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT          NOT NULL,
    [TypeId]            INT             NOT NULL,
    [Code]              NVARCHAR (255)  NOT NULL,
    [Name]              NVARCHAR (255)  NOT NULL,
    [Description]       NVARCHAR (1000) NULL,
    [Email]             NVARCHAR (255)  NULL,
    [StatusId]          INT             NOT NULL,
    [Deletable]         BIT             DEFAULT ((1)) NOT NULL,
    [CreatedTimestamp]  DATETIME        NOT NULL,
    [ModifiedTimestamp] DATETIME        NOT NULL,
    [Image]             VARCHAR (500)   NULL,
    CONSTRAINT [PK_SalesTrackingCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SalesTrackingCode_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_SalesTrackingCode_Status] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[SalesTrackingCodeStatus] ([Id]),
    CONSTRAINT [FK_SalesTrackingCode_Type] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[SalesTrackingCodeType] ([Id]),
    CONSTRAINT [uc_SalesTrackingCode_AccountId_Code] UNIQUE NONCLUSTERED ([AccountId] ASC, [Code] ASC, [TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SalesTrackingCode_StatusId]
    ON [dbo].[SalesTrackingCode]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SalesTrackingCode_TypeId]
    ON [dbo].[SalesTrackingCode]([TypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

