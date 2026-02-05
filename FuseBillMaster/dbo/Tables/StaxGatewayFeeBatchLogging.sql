CREATE TABLE [dbo].[StaxGatewayFeeBatchLogging] (
    [Id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [StaxGatewayFeeLoggingId] BIGINT         NOT NULL,
    [CreatedTimestamp]        DATETIME       NOT NULL,
    [ModifiedTimestamp]       DATETIME       NOT NULL,
    [TotalRecords]            INT            NULL,
    [MatchedRecords]          INT            NULL,
    [UpdatedRecords]          INT            NULL,
    [BatchId]                 NVARCHAR (500) NULL,
    CONSTRAINT [PK_StaxGatewayFeeBatchLogging] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_StaxGatewayFeeBatchLogging_StaxGatewayFeeLogging] FOREIGN KEY ([StaxGatewayFeeLoggingId]) REFERENCES [dbo].[StaxGatewayFeeLogging] ([Id])
);


GO

