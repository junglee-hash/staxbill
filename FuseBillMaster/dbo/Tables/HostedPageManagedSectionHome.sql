CREATE TABLE [dbo].[HostedPageManagedSectionHome] (
    [Id]                  BIGINT          NOT NULL,
    [WelcomeBoxInclude]   BIT             NOT NULL,
    [WelcomeBoxTitle]     NVARCHAR (50)   NULL,
    [WelcomeBoxText]      NVARCHAR (2000) NULL,
    [AddFundsLinkInclude] BIT             CONSTRAINT [DF_AddFundsLinkInclude] DEFAULT ((0)) NOT NULL,
    [MakePaymentLabel]    NVARCHAR (100)  CONSTRAINT [DF_MakePaymentLabel] DEFAULT ('Make a payment') NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionHome] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedSectionHome_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

