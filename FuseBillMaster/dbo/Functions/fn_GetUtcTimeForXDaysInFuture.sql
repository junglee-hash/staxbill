-- =============================================
-- Author:		dlarkin
-- Create date: 2019-11-27
-- Description:	function will return the utc time of tomorrow (or later) taking into account daylight savings correctly
-- =============================================
CREATE FUNCTION [dbo].[fn_GetUtcTimeForXDaysInFuture]
(
	-- Add the parameters for the function here
	@DaysInFutre INT,
	@RunDate DATETIME,
	@TimezoneId BIGINT
)
RETURNS DATETIME
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result DATETIME

	-- Add the T-SQL statements to compute the return value here

	--SELECT @RunDateTimezoneTime = CONVERT(Date, dbo.fn_GetTimezoneTime(@RunDate, @TimezoneId))
	--SELECT @DayAfterRunDate = DATEADD(Day, @DaysInFutre, @RunDateTimezoneTime)	
	--SELECT @Result = dbo.fn_GetUtcTime(@DayAfterRunDate, @TimezoneId)
	
	SELECT @Result = dbo.fn_GetUtcTime(DATEADD(Day, @DaysInFutre, CONVERT(Date, dbo.fn_GetTimezoneTime(@RunDate, @TimezoneId))), @TimezoneId)

	-- Return the result of the function
	RETURN @Result

END

GO

