CREATE TABLE [Timezone].[ZoneTranslation] (
    [ZoneTranslationId] INT           IDENTITY (1, 1) NOT NULL,
    [TimezoneId]        BIGINT        NULL,
    [WindowsZone]       VARCHAR (255) NOT NULL,
    [Territory]         VARCHAR (10)  NOT NULL,
    [IANAZoneId]        INT           NOT NULL,
    [IANAZone]          VARCHAR (255) NOT NULL,
    [ParentIANAZoneID]  INT           NULL,
    [Default]           BIT           NOT NULL,
    CONSTRAINT [PK_ZoneTranslation] PRIMARY KEY CLUSTERED ([ZoneTranslationId] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [UC_ZoneTranslation_IANAZoneId_Default] UNIQUE NONCLUSTERED ([IANAZoneId] ASC, [Default] ASC) WITH (FILLFACTOR = 100)
);


GO

CREATE NONCLUSTERED INDEX [IX_ZoneTranslation_TimezoneId_IANAZoneId_Default]
    ON [Timezone].[ZoneTranslation]([TimezoneId] ASC, [IANAZoneId] ASC, [Default] ASC) WITH (FILLFACTOR = 100);


GO

