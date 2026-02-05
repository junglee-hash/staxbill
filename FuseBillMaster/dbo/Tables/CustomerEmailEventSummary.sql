CREATE TABLE [dbo].[CustomerEmailEventSummary] (
    [CustomerEmailLogId]    BIGINT          NOT NULL,
    [ToEmail]               VARCHAR (255)   NOT NULL,
    [ProcessedTimestamp]    DATETIME        NULL,
    [DeliveredTimestamp]    DATETIME        NULL,
    [OpenedTimestamp]       DATETIME        NULL,
    [LatestSendGridEventId] BIGINT          NULL,
    [LastUpdatedTimestamp]  DATETIME        NULL,
    [DeliveryResult]        NVARCHAR (50)   NULL,
    [Attempt]               INT             NULL,
    [Reason]                NVARCHAR (2000) NULL,
    [AccountId]             BIGINT          NULL,
    CONSTRAINT [PK_CustomerEmailEventSummary] PRIMARY KEY CLUSTERED ([CustomerEmailLogId] ASC, [ToEmail] ASC),
    CONSTRAINT [FK_CustomerEmailEventSummary_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_CustomerEmailEventSummary_CustomerEmailLog] FOREIGN KEY ([CustomerEmailLogId]) REFERENCES [dbo].[CustomerEmailLog] ([Id]),
    CONSTRAINT [FK_CustomerEmailEventSummary_SendGridEvents] FOREIGN KEY ([LatestSendGridEventId]) REFERENCES [dbo].[SendgridEvents] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_DeliveryResult_Account_Incl]
    ON [dbo].[CustomerEmailEventSummary]([AccountId] ASC, [DeliveryResult] ASC)
    INCLUDE([CustomerEmailLogId], [ToEmail]);


GO

