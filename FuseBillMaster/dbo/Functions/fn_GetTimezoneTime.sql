CREATE FUNCTION [dbo].[fn_GetTimezoneTime] 
	(@DateTime AS DATETIME, 
	 @TimezoneId AS bigint)
RETURNS DATETIME
AS
BEGIN
-- DECLARE VARIABLES
	DECLARE @NEWDT AS DATETIME
	DECLARE @OFFSETHR AS INT
	DECLARE @OFFSETMI AS INT
	DECLARE @DSTOFFSETHR AS INT
	DECLARE @DSTOFFSETMI AS INT
	DECLARE @DSTDT AS VARCHAR(10)
	DECLARE @DSTEFFDT AS VARCHAR(10)
	DECLARE @DSTENDDT AS VARCHAR(10)
	
	-- This query gets the timezone information from the TIME_ZONES table for the provided timezone
	SELECT
		@OFFSETHR=OffsetFromUTCHour,
		@OFFSETMI=OffsetFromUTCMinute,
		@DSTOFFSETHR=DSTOffsetFromUTCHour,
		@DSTOFFSETMI=DSTOffsetFromUTCMinute,
		@DSTEFFDT=DSTEffectiveDate,
		@DSTENDDT=DSTEndDate
	FROM Lookup.Timezone
	WHERE Id = @TimezoneId 
	
	DECLARE @StartOfDST datetime = dbo.fn_GetDateFromDaylightSavingsOffset(@DateTime, @DSTEFFDT)
	DECLARE @EndOfDST datetime = dbo.fn_GetDateFromDaylightSavingsOffset(@DateTime, @DSTENDDT)
	-- Convert dates to UTC time since our date is in UTC
	SET @StartOfDST = DATEADD(hh,-@OFFSETHR,@StartOfDST)
	SET @StartOfDST = DATEADD(mi,-@OFFSETMI,@StartOfDST)
	SET @EndOfDST = DATEADD(hh,-@DSTOFFSETHR,@EndOfDST)
	SET @EndOfDST = DATEADD(mi,-@DSTOFFSETMI,@EndOfDST)

	-- Checks to see if the DST parameter for the datetime provided is within the DST parameter for the timezone
	IF @DateTime > @StartOfDST AND @DateTime < @EndOfDST
	BEGIN
		-- Increase the datetime by the hours and minutes assigned to the timezone
		SET @NEWDT = DATEADD(hh,@DSTOFFSETHR,@DateTime)
		SET @NEWDT = DATEADD(mi,@DSTOFFSETMI,@NEWDT)
	END
	-- If the DST parameter for the provided datetime is not within the defined
	-- DST eff and end dates for the timezone then use the standard time offset
	ELSE
	BEGIN
		-- Increase the datetime by the hours and minutes assigned to the timezone
		SET @NEWDT = DATEADD(hh,@OFFSETHR,@DateTime)
		SET @NEWDT = DATEADD(mi,@OFFSETMI,@NEWDT)
	END

	-- Return the new date that has been converted from UTC time
	RETURN @NEWDT
END

GO

