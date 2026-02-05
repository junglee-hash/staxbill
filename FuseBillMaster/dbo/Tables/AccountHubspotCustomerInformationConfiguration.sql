CREATE TABLE [dbo].[AccountHubspotCustomerInformationConfiguration] (
    [Id]              BIGINT IDENTITY (1, 1) NOT NULL,
    [AccountId]       BIGINT NOT NULL,
    [FusebillFieldId] INT    NOT NULL,
    [IsVisible]       BIT    NOT NULL,
    CONSTRAINT [PK_AccountHubspotCustomerInformationConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountHubspotCustomerInformationConfiguration_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountHubspotCustomerInformationConfiguration_FusebillField] FOREIGN KEY ([FusebillFieldId]) REFERENCES [Lookup].[FusebillField] ([Id])
);


GO

