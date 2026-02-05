CREATE TABLE [Lookup].[FatalGatewayError] (
    [Id]              BIGINT         NOT NULL,
    [Error]           NVARCHAR (250) NOT NULL,
    [ProcessorTypeId] INT            NOT NULL,
    CONSTRAINT [PK_FatalGatewayError] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_FatalGatewayError_ProcessorType] FOREIGN KEY ([ProcessorTypeId]) REFERENCES [Lookup].[ProcessorType] ([Id])
);


GO

