CREATE TABLE [dbo].[AccountBrandingPreference] (
    [Id]                     BIGINT         NOT NULL,
    [CompanyName]            NVARCHAR (255) NOT NULL,
    [Address1]               NVARCHAR (255) NULL,
    [Address2]               NVARCHAR (255) NULL,
    [City]                   NVARCHAR (255) NULL,
    [StateId]                BIGINT         NULL,
    [CountryId]              BIGINT         NULL,
    [PostalZip]              NVARCHAR (10)  NULL,
    [SupportEmail]           NVARCHAR (255) NULL,
    [BillingEmail]           NVARCHAR (255) NULL,
    [WebsiteLabel]           NVARCHAR (255) NULL,
    [WebsiteUrl]             NVARCHAR (255) NULL,
    [BillingPhone]           VARCHAR (50)   NULL,
    [SupportPhone]           VARCHAR (50)   NULL,
    [Fax]                    VARCHAR (20)   NULL,
    [FromEmail]              VARCHAR (50)   NOT NULL,
    [ReplyToEmail]           VARCHAR (50)   NOT NULL,
    [FromDisplay]            VARCHAR (50)   NOT NULL,
    [ReplyToDisplay]         VARCHAR (50)   NOT NULL,
    [BccEmail]               VARCHAR (255)  NULL,
    [Logo]                   VARCHAR (500)  NULL,
    [IsRestrictEmailSending] BIT            CONSTRAINT [DF_RestrictEmailSending] DEFAULT ((0)) NOT NULL,
    [StartEmailHour]         INT            NULL,
    [EndEmailHour]           INT            NULL,
    CONSTRAINT [PK_AccountPreferenceBranding] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountBrandingPreference_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_AccountBrandingPreference_State] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id]),
    CONSTRAINT [FK_AccountPreferenceBranding_AccountPreference] FOREIGN KEY ([Id]) REFERENCES [dbo].[AccountPreference] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountBrandingPreference_CountryId]
    ON [dbo].[AccountBrandingPreference]([CountryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_AccountBrandingPreference_StateId]
    ON [dbo].[AccountBrandingPreference]([StateId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

