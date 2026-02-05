CREATE PROCEDURE [Reporting].[TwinspiresMonthlySummary_ThisAccount]
		@Accountid bigint
		,@StartDate Datetime
		,@EndDate Datetime
AS

set transaction isolation level snapshot

EXEC Reporting.Twinspires_MonthlySummary_v2 @AccountId, @StartDate, @EndDate

GO

