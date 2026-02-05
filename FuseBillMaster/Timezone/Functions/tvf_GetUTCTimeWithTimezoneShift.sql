
CREATE FUNCTION [Timezone].[tvf_GetUTCTimeWithTimezoneShift]
(	
	@TimezoneId BIGINT,
	@UTCDateTime_IN DATETIME,
	@SkipOnSpringForwardGap BIT = 1, -- if the local time is in a gap, 1 skips forward and 0 will return null
	@FirstOnFallBackOverlap BIT = 1,  -- if the local time is ambiguous, 1 uses the first (daylight) instance and 0 will use the second (standard) instance
	@Interval VARCHAR(10),	--Interval for shift (year,quarter,month,dayofyear,day,week,hour,minute,second)
	@Number INT, --Number of increments of interval shift (can be negative)
	@ConvertFromShiftedTimezoneDate BIT = 0 --Use the shifted TimezoneDate to convert back to UTC, instead of DateTime (any time is disregarded)
)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN 
(
	WITH CTE_UTCToTimezone AS (
	SELECT [TimezoneDateTime]
	 ,CASE @Interval
            WHEN 'year' THEN DATEADD(YEAR,@Number,[TimezoneDateTime])
            WHEN 'quarter' THEN DATEADD(QUARTER,@Number,[TimezoneDateTime])
            WHEN 'month' THEN DATEADD(MONTH,@Number,[TimezoneDateTime])
            WHEN 'dayofyear' THEN DATEADD(DAYOFYEAR,@Number,[TimezoneDateTime])
            WHEN 'day' THEN DATEADD(DAY,@Number,[TimezoneDateTime])
            WHEN 'week' THEN DATEADD(WEEK,@Number,[TimezoneDateTime])
            WHEN 'hour' THEN DATEADD(HOUR,@Number,[TimezoneDateTime])
            WHEN 'minute' THEN DATEADD(MINUTE,@Number,[TimezoneDateTime])
            WHEN 'second' THEN DATEADD(SECOND,@Number,[TimezoneDateTime])
	ELSE [TimezoneDateTime] END AS [TimezoneDateTime_Shift]
	FROM Timezone.tvf_GetTimezoneTime(@TimezoneId,@UTCDatetime_IN) 
	)

	SELECT [TimezoneDateTime],[TimezoneDateTime_Shift],[UTCDateTime],[UTCDate]
	FROM CTE_UTCToTimezone
	CROSS APPLY Timezone.tvf_GetUTCTime(@TimezoneId,
		CASE @ConvertFromShiftedTimezoneDate WHEN 1 THEN CONVERT(DATE,[TimezoneDateTime_Shift]) ELSE [TimezoneDateTime_Shift] END
		,@SkipOnSpringForwardGap,@FirstOnFallBackOverlap)
)

GO

