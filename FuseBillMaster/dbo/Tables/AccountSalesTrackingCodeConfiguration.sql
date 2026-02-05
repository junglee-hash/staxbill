CREATE TABLE [dbo].[AccountSalesTrackingCodeConfiguration] (
    [Id]                          BIGINT         NOT NULL,
    [SalesTrackingCode1Label]     NVARCHAR (255) NOT NULL,
    [SalesTrackingCode2Label]     NVARCHAR (255) NOT NULL,
    [SalesTrackingCode3Label]     NVARCHAR (255) NOT NULL,
    [SalesTrackingCode4Label]     NVARCHAR (255) NOT NULL,
    [SalesTrackingCode5Label]     NVARCHAR (255) NOT NULL,
    [CreatedTimestamp]            DATETIME       NOT NULL,
    [ModifiedTimestamp]           DATETIME       NOT NULL,
    [SalesTrackingCode1DefaultId] BIGINT         CONSTRAINT [DF_SalesTrackingCode1DefaultId] DEFAULT (NULL) NULL,
    [SalesTrackingCode2DefaultId] BIGINT         CONSTRAINT [DF_SalesTrackingCode2DefaultId] DEFAULT (NULL) NULL,
    [SalesTrackingCode3DefaultId] BIGINT         CONSTRAINT [DF_SalesTrackingCode3DefaultId] DEFAULT (NULL) NULL,
    [SalesTrackingCode4DefaultId] BIGINT         CONSTRAINT [DF_SalesTrackingCode4DefaultId] DEFAULT (NULL) NULL,
    [SalesTrackingCode5DefaultId] BIGINT         CONSTRAINT [DF_SalesTrackingCode5DefaultId] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_AccountSalesTrackingCodeConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountSalesTrackingCodeConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountSalesTrackingCodeConfiguration_SalesTrackingCode_1] FOREIGN KEY ([SalesTrackingCode1DefaultId]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AccountSalesTrackingCodeConfiguration_SalesTrackingCode_2] FOREIGN KEY ([SalesTrackingCode2DefaultId]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AccountSalesTrackingCodeConfiguration_SalesTrackingCode_3] FOREIGN KEY ([SalesTrackingCode3DefaultId]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AccountSalesTrackingCodeConfiguration_SalesTrackingCode_4] FOREIGN KEY ([SalesTrackingCode4DefaultId]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_AccountSalesTrackingCodeConfiguration_SalesTrackingCode_5] FOREIGN KEY ([SalesTrackingCode5DefaultId]) REFERENCES [dbo].[SalesTrackingCode] ([Id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_FK_SalesTrackingCode1Default]
    ON [dbo].[AccountSalesTrackingCodeConfiguration]([SalesTrackingCode1DefaultId] ASC) WHERE ([SalesTrackingCode1DefaultId] IS NOT NULL) WITH (FILLFACTOR = 100);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_FK_SalesTrackingCode2Default]
    ON [dbo].[AccountSalesTrackingCodeConfiguration]([SalesTrackingCode2DefaultId] ASC) WHERE ([SalesTrackingCode2DefaultId] IS NOT NULL) WITH (FILLFACTOR = 100);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_FK_SalesTrackingCode3Default]
    ON [dbo].[AccountSalesTrackingCodeConfiguration]([SalesTrackingCode3DefaultId] ASC) WHERE ([SalesTrackingCode3DefaultId] IS NOT NULL) WITH (FILLFACTOR = 100);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_FK_SalesTrackingCode4Default]
    ON [dbo].[AccountSalesTrackingCodeConfiguration]([SalesTrackingCode4DefaultId] ASC) WHERE ([SalesTrackingCode4DefaultId] IS NOT NULL) WITH (FILLFACTOR = 100);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_FK_SalesTrackingCode5Default]
    ON [dbo].[AccountSalesTrackingCodeConfiguration]([SalesTrackingCode5DefaultId] ASC) WHERE ([SalesTrackingCode5DefaultId] IS NOT NULL) WITH (FILLFACTOR = 100);


GO

