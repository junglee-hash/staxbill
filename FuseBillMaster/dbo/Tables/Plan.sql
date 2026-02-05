CREATE TABLE [dbo].[Plan] (
    [Id]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]            BIGINT          NOT NULL,
    [ModifiedTimestamp]    DATETIME        NOT NULL,
    [CreatedTimestamp]     DATETIME        NOT NULL,
    [Code]                 NVARCHAR (255)  NOT NULL,
    [Name]                 NVARCHAR (100)  NOT NULL,
    [Description]          NVARCHAR (1000) NULL,
    [StatusId]             INT             CONSTRAINT [DF_Plan_StatusId] DEFAULT ((1)) NOT NULL,
    [LongDescription]      NVARCHAR (4000) NULL,
    [Reference]            NVARCHAR (255)  NULL,
    [AutoApplyChanges]     BIT             CONSTRAINT [DF_Plan_AutoApplyChanges] DEFAULT ((0)) NOT NULL,
    [SalesforceCompatible] BIT             DEFAULT ((1)) NOT NULL,
    [IsDeleted]            BIT             CONSTRAINT [DF_PlanIsDeleted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Plan] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Plan_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_PlanStatus_Plan] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[PlanStatus] ([Id]),
    CONSTRAINT [uc_Plan_AccountId_Code] UNIQUE NONCLUSTERED ([AccountId] ASC, [Code] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_Plan_AccountId_StatusId]
    ON [dbo].[Plan]([AccountId] ASC, [StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Plan_StatusId]
    ON [dbo].[Plan]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

