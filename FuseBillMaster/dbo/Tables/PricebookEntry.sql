CREATE TABLE [dbo].[PricebookEntry] (
    [Id]                   BIGINT   IDENTITY (1, 1) NOT NULL,
    [PricebookId]          BIGINT   NOT NULL,
    [CreatedTimestamp]     DATETIME NOT NULL,
    [ModifiedTimestamp]    DATETIME NOT NULL,
    [OrderToCashCycleId]   BIGINT   NOT NULL,
    [SalesTrackingCode1Id] BIGINT   NULL,
    [SalesTrackingCode2Id] BIGINT   NULL,
    [SalesTrackingCode3Id] BIGINT   NULL,
    [SalesTrackingCode4Id] BIGINT   NULL,
    [SalesTrackingCode5Id] BIGINT   NULL,
    [IsDefault]            BIT      NOT NULL,
    [Priority]             INT      CONSTRAINT [DF_Priority] DEFAULT ((0)) NOT NULL,
    [StartingDate]         DATETIME CONSTRAINT [DF_StartingDate] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_PricebookEntry] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PricebookEntry_OrderToCashCycle] FOREIGN KEY ([OrderToCashCycleId]) REFERENCES [dbo].[OrderToCashCycle] ([Id]),
    CONSTRAINT [FK_PricebookEntry_Pricebook] FOREIGN KEY ([PricebookId]) REFERENCES [dbo].[Pricebook] ([Id]),
    CONSTRAINT [FK_PricebookEntry_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_PricebookEntry_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_PricebookEntry_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_PricebookEntry_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_PricebookEntry_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id])
);


GO

