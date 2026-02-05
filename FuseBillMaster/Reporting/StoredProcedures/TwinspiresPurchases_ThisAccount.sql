CREATE PROCEDURE [Reporting].[TwinspiresPurchases_ThisAccount]
		@Accountid bigint
		,@StartDate Datetime
		,@EndDate Datetime
AS

set transaction isolation level snapshot
declare
	@Interval nvarchar(10)

SELECT @Interval = 
CASE 
	WHEN DATEDIFF(day, @StartDate,@EndDate) > 2 THEN 'Monthly'  
	ELSE 'Daily'
END

EXEC Reporting.TwinspiresPurchases_v2 @AccountId, @Interval, @EndDate

GO

