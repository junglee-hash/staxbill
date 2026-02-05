CREATE FUNCTION [dbo].[fn_CalculateExpiringDate]
(
	@NextBillingDate DateTime,
	@NumberOfIntervals int,
	@IntervalId int,
	@ReminingIntervals int 
)
RETURNS DateTime
AS
BEGIN
	DECLARE @EndDate DateTime = @NextBillingDate

	IF @IntervalId = 3
	BEGIN
		SET @EndDate = DATEADD(MONTH, @NumberOfIntervals*@ReminingIntervals, @EndDate)
	END
	IF @IntervalId = 5
	BEGIN
		SET @EndDate = DATEADD(YEAR, @NumberOfIntervals*@ReminingIntervals, @EndDate)
	END

	RETURN @EndDate
END


--(Interval, NumberOfIntervals * RemainingInterval, NextBillingDate)

GO

