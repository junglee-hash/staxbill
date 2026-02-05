CREATE PROCEDURE [Reporting].[TwinspiresPurchases_10185]
		@AccountId bigint
		,@StartDate Datetime
		,@EndDate Datetime
AS

set transaction isolation level snapshot

set @AccountId = 10185

declare
	@Interval nvarchar(10)

SELECT @Interval = 
CASE 
	WHEN DATEDIFF(day, @StartDate,@EndDate) > 2 THEN 'Monthly'  
	ELSE 'Daily'
END

EXEC Reporting.TwinspiresPurchases_v2 @AccountId, @Interval, @EndDate

GO

