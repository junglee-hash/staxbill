

/*
declare 
@AccountId bigint = 10
,@CurrencyId bigint = 1
,@UTCStartDateTime datetime = '2014-01-01 5:00:00'
,@UTCEndDateTime datetime = getutcdate()


exec usp_CreditReportSummary @AccountId ,@CurrencyId,@UTCStartDateTime,@UTCEndDateTime

*/


CREATE Procedure [dbo].[usp_CreditReportSummary]
	@AccountId bigint
	,@CurrencyId bigint = 1
	,@UTCStartDateTime datetime
	,@UTCEndDateTime datetime

AS

Declare @Summary money

select @Summary = 
	Sum(t.Amount* tt.ARBalanceMultiplier )
from 
	[Transaction] t 
	inner join Customer c 
	on t.CustomerId = c.Id 
	inner join AccountPreference a
	on c.AccountId = a.Id
	inner join Lookup.TransactionType tt
	on t.TransactionTypeId = tt.Id

where 
	c.AccountId = @AccountId
	and c.CurrencyId = @CurrencyId
	and t.EffectiveTimestamp >=@UTCStartDateTime 
	and t.EffectiveTimestamp < @UTCEndDateTime 
	and t.transactionTypeId in (17,18)
group by c.AccountId

select isnull(@Summary,0) as Summary

GO

