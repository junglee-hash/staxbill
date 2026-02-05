
CREATE FUNCTION [Timezone].[tvf_GetTimezoneTime]
(	
	@TimezoneId AS BIGINT,
	@UTCDateTime AS DATETIME
)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN 
(
	SELECT 
	CASE WHEN @UTCDateTime > '99990101' THEN CONVERT(DATE,@UTCDateTime)
			ELSE CONVERT(DATE,DATEADD(MINUTE,OffsetMinutes,@UTCDateTime)) END AS TimezoneDate
	,CASE WHEN @UTCDateTime > '99990101' THEN CONVERT(DATETIME,@UTCDateTime)
		ELSE DATEADD(MINUTE,OffsetMinutes,@UTCDateTime) END AS TimezoneDateTime
	,CASE WHEN @UTCDateTime > '99990101' THEN @UTCDateTime
		ELSE TODATETIMEOFFSET(DATEADD(MINUTE,OffsetMinutes,@UTCDateTime),OffsetMinutes) END AS TimezoneDateTimeOffset
	FROM [Timezone].[Interval] i
	INNER JOIN Timezone.tvf_GetZoneId(@TimezoneId) z
		ON z.ZoneId = i.IANAZoneId
	WHERE [UtcStart] <= @UTCDateTime
	AND [UtcEnd] > @UTCDateTime
)

GO

