CREATE TABLE [Reporting].[Twinspires_DailyActivityDetails] (
    [CAM ID]                      NVARCHAR (255) NULL,
    [Subscription Product ID]     BIGINT         NULL,
    [Purchase ID]                 BIGINT         NULL,
    [Affiliate ID]                NVARCHAR (255) NULL,
    [Transaction Date]            DATETIME       NULL,
    [Transaction ID]              VARCHAR (60)   NULL,
    [Product code]                NVARCHAR (255) NULL,
    [Plan Name]                   NVARCHAR (100) NULL,
    [Reference]                   NVARCHAR (255) NULL,
    [Regular Price]               MONEY          NULL,
    [Actual Price Charged]        MONEY          NULL,
    [Reason for Price Difference] VARCHAR (100)  NULL,
    [Payment Method]              VARCHAR (100)  NULL,
    [Current Account Balance]     VARCHAR (60)   NULL,
    [customer_group]              NVARCHAR (255) NULL,
    [FusebillId]                  BIGINT         NULL,
    [AccountId]                   BIGINT         NULL,
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

