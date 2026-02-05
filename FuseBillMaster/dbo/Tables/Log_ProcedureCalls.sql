CREATE TABLE [dbo].[Log_ProcedureCalls] (
    [CallTimestamp]   DATETIME       NULL,
    [StoredProcedure] VARCHAR (255)  NULL,
    [AccountId]       BIGINT         NULL,
    [ExtraDetails]    VARCHAR (4000) NULL,
    [Id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

