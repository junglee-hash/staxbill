CREATE TABLE [Lookup].[PaymentType] (
    [Id]               INT          NOT NULL,
    [Name]             VARCHAR (50) NOT NULL,
    [AmountMultiplier] SMALLINT     CONSTRAINT [DF_PaymentType_AmountMultiplier] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PaymentType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

