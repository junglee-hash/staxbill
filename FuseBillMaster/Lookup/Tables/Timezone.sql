CREATE TABLE [Lookup].[Timezone] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [StandardName]                NVARCHAR (100) NOT NULL,
    [DaylightName]                NVARCHAR (100) NOT NULL,
    [DisplayName]                 NVARCHAR (100) NOT NULL,
    [BaseUtcOffset]               VARCHAR (20)   NOT NULL,
    [ClrId]                       NVARCHAR (100) NOT NULL,
    [SupportsDaylightSavingTime]  VARCHAR (20)   NOT NULL,
    [OffsetFromUTCHour]           INT            NOT NULL,
    [OffsetFromUTCMinute]         INT            NOT NULL,
    [DSTOffsetFromUTCHour]        INT            NOT NULL,
    [DSTOffsetFromUTCMinute]      INT            NOT NULL,
    [DSTEffectiveDate]            INT            NOT NULL,
    [DSTEndDate]                  INT            NOT NULL,
    [StandardTimeAbbreviation]    VARCHAR (5)    CONSTRAINT [DF_Timezone_StandardTimeAbbreviation] DEFAULT ('') NOT NULL,
    [DaylightTimeAbbreviation]    VARCHAR (5)    CONSTRAINT [DF_Timezone_DaylightTimeAbbreviation] DEFAULT ('') NOT NULL,
    [DSTEffectiveDateWithoutHour] INT            NULL,
    [DSTEndDateWithoutHour]       INT            NULL,
    [MomentName]                  NVARCHAR (200) NOT NULL,
    CONSTRAINT [PK_Timezone] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

