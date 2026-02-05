CREATE TABLE [dbo].[AccountAddressPreference] (
    [Id]                        BIGINT   NOT NULL,
    [EnforceFullAddress]        BIT      NOT NULL,
    [UseCustomerBillingAddress] BIT      CONSTRAINT [DF_AccountAddressPreference_UseCustomerBillingAddress] DEFAULT ((1)) NOT NULL,
    [ModifiedTimestamp]         DATETIME NOT NULL,
    CONSTRAINT [PK_AccountAddressPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountAddressPreference_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id])
);


GO

