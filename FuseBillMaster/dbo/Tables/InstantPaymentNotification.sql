CREATE TABLE [dbo].[InstantPaymentNotification] (
    [Id]                     BIGINT           IDENTITY (1, 1) NOT NULL,
    [CustomerId]             BIGINT           NULL,
    [ReconciliationId]       UNIQUEIDENTIFIER NULL,
    [CallbackTypeId]         INT              NOT NULL,
    [Raw]                    VARCHAR (500)    NOT NULL,
    [FirstIPNTimestamp]      DATETIME         NOT NULL,
    [MostRecentIPNTimestamp] DATETIME         NOT NULL,
    [AccountId]              BIGINT           NULL,
    [WePayUserId]            BIGINT           NULL,
    [Consumed]               BIT              CONSTRAINT [DF_InstantPaymentNotification_Consumed] DEFAULT ((0)) NOT NULL,
    [ExceptionReason]        NVARCHAR (4000)  NULL,
    CONSTRAINT [PK__InstantPaymentNotification] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_InstantPaymentNotificationCallbackTypeId_CallbackType] FOREIGN KEY ([CallbackTypeId]) REFERENCES [Lookup].[CallbackType] ([Id]),
    CONSTRAINT [FK_InstantPaymentNotificationCustomerId_Id] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_InstantPaymentNotification_CustomerId]
    ON [dbo].[InstantPaymentNotification]([CustomerId] ASC) WITH (FILLFACTOR = 100);


GO

