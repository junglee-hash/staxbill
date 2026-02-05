CREATE TABLE [dbo].[DailyAccountCustomerSummary] (
    [Id]                                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [Report Date]                             DATE            NOT NULL,
    [AccountId]                               BIGINT          NOT NULL,
    [Total Draft Customer Count]              INT             NOT NULL,
    [Total Active Customer Count]             INT             NOT NULL,
    [Total Hold Customer Count]               INT             NOT NULL,
    [Total Suspended Customer Count]          INT             NOT NULL,
    [Total Cancelled Customer Count]          INT             NOT NULL,
    [Customers Created Today Count]           INT             NOT NULL,
    [Customers Activated Today Count]         INT             NOT NULL,
    [Customers Cancelled Today Count]         INT             NOT NULL,
    [Total Customers in Good Standing]        INT             NOT NULL,
    [Total Customers in Poor Standing]        INT             NOT NULL,
    [Total Customers in Collections Standing] INT             NOT NULL,
    [TimezoneId]                              INT             NOT NULL,
    [Gross Monthly Recurring Revenue]         DECIMAL (18, 2) NOT NULL,
    [Net Monthly Recurring Revenue]           DECIMAL (18, 2) NOT NULL,
    [CurrencyId]                              INT             NOT NULL,
    CONSTRAINT [pk_DailyAccountCustomerSummary] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

