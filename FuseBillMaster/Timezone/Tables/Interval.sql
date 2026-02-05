CREATE TABLE [Timezone].[Interval] (
    [IntervalId]    INT          IDENTITY (1, 1) NOT NULL,
    [IANAZoneId]    INT          NOT NULL,
    [UtcStart]      DATETIME     NOT NULL,
    [UtcEnd]        DATETIME     NOT NULL,
    [LocalStart]    DATETIME     NOT NULL,
    [LocalEnd]      DATETIME     NOT NULL,
    [OffsetMinutes] SMALLINT     NOT NULL,
    [Abbreviation]  VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_Interval] PRIMARY KEY CLUSTERED ([IntervalId] ASC) WITH (FILLFACTOR = 100)
);


GO

CREATE NONCLUSTERED INDEX [IX_Interval_IANAZoneId_LocalStart_LocalEnd_UtcStart_INCL]
    ON [Timezone].[Interval]([IANAZoneId] ASC, [LocalStart] ASC, [LocalEnd] ASC, [UtcStart] ASC)
    INCLUDE([OffsetMinutes], [Abbreviation]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Interval_IANAZoneId_UtcStart_UtcEnd_INCL]
    ON [Timezone].[Interval]([IANAZoneId] ASC, [UtcStart] ASC, [UtcEnd] ASC)
    INCLUDE([OffsetMinutes], [Abbreviation]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Interval_UtcStart_UtcEnd_IANAZoneId_INCL]
    ON [Timezone].[Interval]([UtcStart] ASC, [UtcEnd] ASC, [IANAZoneId] ASC)
    INCLUDE([OffsetMinutes]) WITH (FILLFACTOR = 100);


GO

