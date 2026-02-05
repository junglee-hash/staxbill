

/*
declare 
@AccountId bigint = 10
,@CurrencyId bigint = 1
,@UTCStartDateTime datetime = '2014-01-01 5:00:00'
,@UTCEndDateTime datetime = getutcdate()


exec usp_CreditReportCount @AccountId ,@CurrencyId,@UTCStartDateTime,@UTCEndDateTime

*/


CREATE Procedure [dbo].[usp_CreditReportCount]
	@AccountId bigint
	,@CurrencyId bigint = 1
	,@UTCStartDateTime datetime
	,@UTCEndDateTime datetime

AS


select 
	Count(t.Id) as Count
from 
	[Transaction] t 
	inner join Customer c 
	on t.CustomerId = c.Id 

where 
	c.AccountId = @AccountId
	and c.CurrencyId = @CurrencyId
	and t.EffectiveTimestamp >=@UTCStartDateTime 
	and t.EffectiveTimestamp < @UTCEndDateTime 
	and t.transactionTypeId in (17,18)

GO

