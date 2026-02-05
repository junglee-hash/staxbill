CREATE TABLE [dbo].[Queries] (
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (100) NOT NULL,
    [Description]     NVARCHAR (100) NULL,
    [StoredProcedure] NVARCHAR (100) NOT NULL,
    [ParamAccountId]  BIT            DEFAULT ((0)) NOT NULL,
    [ParamCustomerId] BIT            DEFAULT ((0)) NOT NULL,
    [ParamDateRange]  BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Queries] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

