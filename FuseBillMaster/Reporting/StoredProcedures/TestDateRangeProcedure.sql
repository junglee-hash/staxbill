

CREATE PROCEDURE [Reporting].[TestDateRangeProcedure]
	@AccountId bigint,
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 10 * FROM Customer WHERE AccountId = @AccountId
	AND EffectiveTimestamp >= @StartDate AND EffectiveTimestamp < @EndDate
	ORDER BY Id DESC
END

GO

