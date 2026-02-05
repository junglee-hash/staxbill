CREATE FUNCTION [dbo].[fn_CalculateNextEndDate]
(
	@StartDate DateTime,
	@NumberOfIntervals int,
	@IntervalId int,
	@TargetDay int,
	@TimezoneId int
)
RETURNS DateTime
AS
BEGIN
	DECLARE @EndDate DateTime = @StartDate
	select @EndDate = dbo.fn_GetTimezoneTime(@EndDate,@TimezoneId)

	IF @IntervalId = 3
	BEGIN
		SET @EndDate = DATEADD(MONTH, @NumberOfIntervals, @EndDate)
	END
	IF @IntervalId = 5
	BEGIN
		SET @EndDate = DATEADD(YEAR, @NumberOfIntervals, @EndDate)
	END

	DECLARE @CurrentDay int = DATEPART(DAY, @EndDate)
	DECLARE @DaysInMonth int = DATEPART(DAY, EOMONTH(@EndDate))

	WHILE @CurrentDay != CASE WHEN @TargetDay < @DaysInMonth THEN @TargetDay ELSE @DaysInMonth END
	BEGIN
		SET @EndDate = DATEADD(DAY, -1, @EndDate)
		SET @CurrentDay = DATEPART(DAY, @EndDate)
	END

	select @EndDate = dbo.fn_GetUtcTime(@EndDate,@TimezoneId)

	RETURN @EndDate
END

GO

