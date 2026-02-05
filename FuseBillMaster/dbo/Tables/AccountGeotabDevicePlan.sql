CREATE TABLE [dbo].[AccountGeotabDevicePlan] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]          BIGINT         NOT NULL,
    [Name]               NVARCHAR (255) NOT NULL,
    [PlanId]             INT            NULL,
    [Level]              INT            NULL,
    [ValidForOrder]      BIT            NULL,
    [IsThirdPartyDevice] BIT            CONSTRAINT [DF_AccountGeotabDevicePlanIsThirdPartyDevice] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountGeotabDevicePlan] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AccountGeotabDevicePlan_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

