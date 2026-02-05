
CREATE procedure [Reporting].[TwinspiresPurchases_v2]
--declare
@AccountId bigint = 10136
,@Interval nvarchar(10) = 'Daily'
,@EndDate datetime = NULL
AS

set transaction isolation level snapshot
set nocount on
declare 
@StartDate datetime
,@TimezoneId int

if @EndDate IS NULL
begin
	set @EndDate = getutcdate()
end

set @EndDate = convert(date,@EndDate)

set @StartDate = dateadd(day,-1,@EndDate)

if @Interval = 'Monthly'
begin
	set @StartDate = dateadd(month,-1,@EndDate)
end

--Dates are being written to the Twinspires table in Twinspires account timezone, no time conversion needed

Select 
	[CAM ID]
	,[Subscription Product ID]
	,[Purchase ID]
	,[Affiliate ID]
	--Dates are being written to the Twinspires table in Twinspires account timezone, no time conversion needed
	,convert(varchar(60),convert(smalldatetime,[Transaction Date])) as [Transaction Date]
	,[Transaction ID]
	,[Product code]
	,[Plan Name]
	,[Reference]
	,[Regular Price]
	,[Actual Price Charged]
	,[Reason for Price Difference]
	,[Payment Method]
	,[Current Account Balance]
	,[customer_group]
	,[FusebillId]
FROM
	Reporting.Twinspires_DailyActivityDetails
where
	([Transaction Date] >= @StartDate AND [Transaction Date] < @EndDate	)
	AND
	([Product code] NOT LIKE '%plan%' OR CONVERT(decimal,[Current Account Balance]) <= 0)
	AND
	AccountId = @AccountId

set nocount off

GO

