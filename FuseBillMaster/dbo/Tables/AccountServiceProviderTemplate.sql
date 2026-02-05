CREATE TABLE [dbo].[AccountServiceProviderTemplate] (
    [Id]                           BIGINT         NOT NULL,
    [ServiceProvider]              NVARCHAR (100) NOT NULL,
    [ServiceProviderLabel]         NVARCHAR (100) NOT NULL,
    [ServiceProviderIdLabel]       VARCHAR (100)  NOT NULL,
    [ServiceProviderBaseUrl]       VARCHAR (100)  NOT NULL,
    [HasCurrencyAccess]            BIT            NOT NULL,
    [HasOtherGatewayAccess]        BIT            NOT NULL,
    [HasPaypalAccess]              BIT            NOT NULL,
    [HasDigitalRiverAccess]        BIT            NOT NULL,
    [ServiceProviderSupportEmail]  VARCHAR (50)   NULL,
    [ServiceProviderSupportDomain] NVARCHAR (50)  NULL,
    CONSTRAINT [PK_AccountServiceProviderTemplate] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

