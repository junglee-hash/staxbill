CREATE TABLE [dbo].[HostedPageManagedSectionStatement] (
    [Id]                 BIGINT NOT NULL,
    [ShowByTransaction]  BIT    CONSTRAINT [DF_ShowByTransaction] DEFAULT ((1)) NOT NULL,
    [ShowBySubscription] BIT    CONSTRAINT [DF_ShowBySubscription] DEFAULT ((1)) NOT NULL,
    [ShowByInvoice]      BIT    CONSTRAINT [DF_ShowByInvoice] DEFAULT ((1)) NOT NULL,
    [ShowSummarized]     BIT    CONSTRAINT [DF_ShowSummarized] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionStatement] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HostedPageManagedSectionStatement_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

