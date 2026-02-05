CREATE TABLE [dbo].[CustomerAddressPreference] (
    [Id]                                 BIGINT          NOT NULL,
    [ContactName]                        NVARCHAR (250)  NULL,
    [ShippingInstructions]               NVARCHAR (1000) NULL,
    [UseBillingAddressAsShippingAddress] BIT             NOT NULL,
    [CreatedTimestamp]                   DATETIME        NOT NULL,
    [ModifiedTimestamp]                  DATETIME        NOT NULL,
    CONSTRAINT [PK_CustomerAddressPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerAddressPreference_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id])
);


GO

