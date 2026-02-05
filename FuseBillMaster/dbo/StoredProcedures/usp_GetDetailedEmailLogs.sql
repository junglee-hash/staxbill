Create Procedure [dbo].[usp_GetDetailedEmailLogs]
	@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
set nocount on


declare @TimezoneId int

select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId 


Select 
	c.id as 'Fusebill ID',
	c.CompanyName as 'Customer Company Name',
	c.Reference as 'Customer Reference',
	cel.ToEmail as 'To Email',
	cel.BccEmail as 'Bcc Email',
	cel.Id as 'Email ID',
	dbo.fn_GetTimezoneTime(cel.CreatedTimestamp, @TimezoneId) as 'Email Timestamp',
	se.Event as 'Email Status',
	dbo.fn_GetTimezoneTime(se.CreatedTimestamp, @TimezoneId) as 'Event Timestamp',
	se.Reason as 'Reason',
	se.Attempt as 'Attempt'
from CustomerEmailLog (nolock) cel
	inner join Customer (nolock) c on cel.CustomerId = c.Id
	inner join SendgridEvents (nolock) se on se.SendgridEmailId = cel.SendgridEmailId
where 
	c.AccountId = @AccountId
	and cel.CreatedTimestamp >= @StartDate 
	and cel.CreatedTimestamp <= @EndDate

set nocount off

GO

