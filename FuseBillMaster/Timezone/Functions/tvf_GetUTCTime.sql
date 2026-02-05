
CREATE FUNCTION [Timezone].[tvf_GetUTCTime]
(	
	@TimezoneId AS BIGINT,
	@TimezoneDateTime AS DATETIME,
	@SkipOnSpringForwardGap BIT = 1, -- if the local time is in a gap, 1 skips forward and 0 will return null
	@FirstOnFallBackOverlap BIT = 1  -- if the local time is ambiguous, 1 uses the first (daylight) instance and 0 will use the second (standard) instance
)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN 
(
	WITH CTE_Offset AS
		(
		SELECT p1.[Priority],p1.[OffsetMinutes]
		FROM ( 
			--OffsetMinutes for case when SpringForwardGap does not occur
			SELECT TOP 1 
			1 AS [Priority]
			,[OffsetMinutes]
			FROM [Timezone].[Interval] i
			INNER JOIN Timezone.tvf_GetZoneId(@TimezoneId) z ON z.ZoneId = i.IANAZoneId
  			WHERE [LocalStart] <= @TimezoneDateTime
			AND [LocalEnd] > @TimezoneDateTime
			ORDER BY
				--Fall Back decision (which of ambiguous values to take)
				CASE
					WHEN @FirstOnFallBackOverlap = 1 THEN [UtcStart]
					END ASC,
				CASE
					WHEN @FirstOnFallBackOverlap = 0 THEN [UtcStart]
					END DESC 
			   ) p1
		UNION ALL 
		SELECT p2.[Priority],p2.[OffsetMinutes]
		  FROM ( 
			--OffsetMinutes for case when SpringForwardGap occurs
			SELECT TOP 1
			2 AS [Priority]
			,[OffsetMinutes]
			FROM [Timezone].[Interval] i
			INNER JOIN Timezone.tvf_GetZoneId(@TimezoneId) z ON z.ZoneId = i.IANAZoneId
			WHERE i.[LocalEnd] <= @TimezoneDateTime
			ORDER BY i.[UtcStart] DESC
			   ) p2
		)

	SELECT 
	CASE WHEN @TimezoneDateTime > '99990101' THEN CONVERT(DATE,@TimezoneDateTime)
		ELSE CONVERT(DATE,DATEADD(MINUTE,-OffsetMinutes,@TimezoneDateTime)) END AS UTCDate
	,CASE WHEN @TimezoneDateTime > '99990101' THEN CONVERT(DATETIME,@TimezoneDateTime)
		ELSE DATEADD(MINUTE,-OffsetMinutes,@TimezoneDateTime) END AS UTCDateTime
	,CASE WHEN @TimezoneDateTime > '99990101' THEN @TimezoneDateTime
		ELSE TODATETIMEOFFSET(DATEADD(MINUTE,-OffsetMinutes,@TimezoneDateTime),0) END AS UTCDateTimeOffset --Zero will set UTC offset correctly
	FROM (
		SELECT TOP 1 --Will return Priority 1 row if exists
			CASE 
			WHEN [Priority] = 2 AND @SkipOnSpringForwardGap = 0 THEN NULL --Determines output based on @SkipOnSpringForwardGap
			ELSE [OffsetMinutes] END AS [OffsetMinutes]
		FROM CTE_Offset
		ORDER BY [Priority]
		) cte
)

GO

