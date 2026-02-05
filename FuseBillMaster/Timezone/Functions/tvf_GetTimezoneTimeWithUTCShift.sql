
CREATE FUNCTION [Timezone].[tvf_GetTimezoneTimeWithUTCShift]
(	
	@TimezoneId BIGINT,
	@TimezoneDateTime_IN DATETIME,
	@SkipOnSpringForwardGap BIT = 1, -- if the local time is in a gap, 1 skips forward and 0 will return null
	@FirstOnFallBackOverlap BIT = 1,  -- if the local time is ambiguous, 1 uses the first (daylight) instance and 0 will use the second (standard) instance
	@Interval VARCHAR(10),	--Interval for shift (year,quarter,month,dayofyear,day,week,hour,minute,second)
	@Number INT, --Number of increments of interval shift (can be negative)
	@ConvertFromShiftedUTCDate BIT = 0 --Use the shifted TimezoneDate to convert back to UTC, instead of DateTime (any time is disregarded)
)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN 
(
	WITH CTE_TimezoneToUTC AS (
	SELECT [UTCDateTime]
	 ,CASE @Interval
            WHEN 'year' THEN DATEADD(YEAR,@Number,[UTCDateTime])
            WHEN 'quarter' THEN DATEADD(QUARTER,@Number,[UTCDateTime])
            WHEN 'month' THEN DATEADD(MONTH,@Number,[UTCDateTime])
            WHEN 'dayofyear' THEN DATEADD(DAYOFYEAR,@Number,[UTCDateTime])
            WHEN 'day' THEN DATEADD(DAY,@Number,[UTCDateTime])
            WHEN 'week' THEN DATEADD(WEEK,@Number,[UTCDateTime])
            WHEN 'hour' THEN DATEADD(HOUR,@Number,[UTCDateTime])
            WHEN 'minute' THEN DATEADD(MINUTE,@Number,[UTCDateTime])
            WHEN 'second' THEN DATEADD(SECOND,@Number,[UTCDateTime])
	ELSE [UTCDateTime] END AS [UTCDateTime_Shift]
	FROM Timezone.tvf_GetUTCTime(@TimezoneId,@TimezoneDatetime_IN,@SkipOnSpringForwardGap,@FirstOnFallBackOverlap) 
	)

	SELECT [UTCDateTime],[UTCDateTime_Shift],[TimezoneDateTime],[TimezoneDate]
	FROM CTE_TimezoneToUTC
	CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId,CASE @ConvertFromShiftedUTCDate WHEN 1 THEN CONVERT(DATE,[UTCDateTime_Shift]) ELSE [UTCDateTime_Shift] END)
)

GO

