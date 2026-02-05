CREATE procedure [dbo].[usp_GetFinancialCalendar]
--declare
	@AccountId bigint 
	,@UtcStartDateTime datetime
	,@UtcEndDateTime datetime
	,@CurrencyId int
	,@IncludeInvoices bit
	,@IncludeDraftInvoices bit
	,@IncludePayments bit 
	,@IncludeRefunds bit
	,@IncludeFailedPayments bit
	,@IncludeProjectedInvoices bit
	,@IncludeReversals bit
	,@IncludeCredits bit
	,@IncludeWriteOffs bit
WITH RECOMPILE
as

set transaction isolation level snapshot
set nocount on
--select 
--     @AccountId = 3432053
--     ,@CurrencyId = 1
--     ,@UtcStartDateTime = '1900-01-01'
--     ,@UtcEndDateTime = dateadd(month,1,getutcdate())
--     ,@IncludeInvoices = 1
--     ,@IncludeDraftInvoices = 1
--     ,@IncludePayments = 1
--     ,@IncludeRefunds = 1
--     ,@IncludeFailedPayments = 1
--     ,@IncludeProjectedInvoices = 1
--     ,@IncludeReversals =1
--     ,@IncludeCredits =1
--     ,@IncludeWriteOffs =1


declare @TimezoneId int

select @TimezoneId = TimezoneId 
from 
       AccountPreference 
where 
       Id = @AccountId

--Create temporary table to store the entirety of the results for the query within
create table #ResultTable
(
       CalendarDate datetime
       ,ForCounting bigint
       ,ForSumAmount decimal (18,2)
       ,Type int
	   ,SubType int
)

--invoices first, trying Charges and Discounts
--Select the active journal related to a invoice within the timerange in order to get its sum of charges/discounts/taxes
if @IncludeInvoices = 1
begin

	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,[Type]
		,SubType
	)
	select
		t.TimezoneDate as CalendarDate
		,ij.InvoiceId
		,ij.SumOfCharges-ij.SumOfDiscounts+ij.SumOfTaxes
		,0 as [Type]
		,0 as SubType
	FROM
		InvoiceJournal ij
		inner join Invoice i on i.Id = ij.InvoiceId
		inner join customer c on i.CustomerId = c.Id
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, i.PostedTimestamp) t
	where
		i.AccountId = @AccountId     
		and i.EffectiveTimestamp >= @UtcStartDateTime
		and i.EffectiveTimestamp < @UtcEndDateTime
		AND c.CurrencyId = @CurrencyId
		AND ij.IsActive = 1

end

--Get the total for all draft invoices within the time range
if @IncludeDraftInvoices = 1
begin
	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select 
		t.TimezoneDate as CalendarDate
		,i.id
		,i.Total
		,1 as Type
		,0 as SubType
	from 
		draftinvoice i 
		inner join customer c on i.CustomerId = c.Id
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, i.EffectiveTimestamp) t
	where 
		c.AccountId = @AccountId
		and i.DraftInvoiceStatusId = 2
		and c.CurrencyId = @CurrencyId
		and i.EffectiveTimestamp >= @UtcStartDateTime
		and i.EffectiveTimestamp < @UtcEndDateTime
end

--Get the total for all projected invoices within the time range
if @IncludeProjectedInvoices = 1
begin

	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select 
		t.TimezoneDate as CalendarDate
		,i.id
		,i.ProjectedTotal
		,9 as Type
		,0 as SubType
	from 
		ProjectedInvoice i 
		inner join customer c on i.CustomerId = c.Id
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, i.EffectiveTimestamp) t
	where 
		c.AccountId = @AccountId
		and c.CurrencyId = @CurrencyId
		and i.EffectiveTimestamp >= @UtcStartDateTime
		and i.EffectiveTimestamp < @UtcEndDateTime
end

--Get all failed payments via the PAJ's within the given timerange
if @IncludeFailedPayments = 1
begin

	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	Select
		t.TimezoneDate as CalendarDate
		,paj.Id
		,paj.Amount
		,4 as Type
		,CASE WHEN paj.AttemptNumber = 0 THEN 0 ELSE 1 END as SubType
	from
		PaymentActivityJournal paj
		inner join Customer c on paj.CustomerId = c.Id
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, paj.CreatedTimestamp) t
	where 
		c.AccountId = @AccountId
		and c.CurrencyId = @CurrencyId
		and paj.CreatedTimestamp >= @UtcStartDateTime
		and paj.CreatedTimestamp < @UtcEndDateTime
		and paj.PaymentActivityStatusId = 2
		and paj.PaymentTypeId = 2
end

--Inserting all the used transaction types below into this table with the required data
--We are doing this so that we dont have to hit the entirety of the transactions
--table for each and every select done below
select 
	t.EffectiveTimestamp as [EffectiveTimestamp]
	,t.Id as [Id]
	,t.Amount as [Amount]
	,t.TransactionTypeId as [TransactionTypeId]
INTO #TransactionsTable
from 
	[Transaction] t 
where 
	t.AccountId = @AccountId
	and t.CurrencyId = @CurrencyId
	and t.EffectiveTimestamp >= @UtcStartDateTime
	and t.EffectiveTimestamp < @UtcEndDateTime
	and t.TransactionTypeId in (3, 4, 5, 25, 17, 10, 7, 24, 15, 22)
	--Payments, Full refund, Partial refund, NSF, Credits, Write off, Reverse charge, Reverse charge earned, Reverse Discount, Reversed Deferred Discount

--Getting payments from transaction table using our temp table created above
if @IncludePayments = 1
begin
	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select 
		w.TimezoneDate as CalendarDate
		,t.Id
		,t.Amount
		,2 as Type
		,CASE WHEN paj.AttemptNumber = 0 THEN 0 ELSE 1 END as SubType
	from 
		#TransactionsTable t 
	inner join Payment p ON p.Id = t.Id
	inner join PaymentActivityJournal paj ON p.PaymentActivityJournalId = paj.Id
	CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) w
	where 
		t.TransactionTypeId = 3 -- Payments
end

--Getting Full refund, Partial refund, NSF from transaction table using our temp table created above
if @IncludeRefunds = 1
begin 
	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select 
		w.TimezoneDate as CalendarDate
		,t.Id
		,t.Amount
		,3 as Type
		,0 as SubType
	from 
		#TransactionsTable t                
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) w
	where 
		t.TransactionTypeId in (4, 5, 25) --Full refund, Partial refund, NSF
end

--Getting Credit from transaction table using our temp table created above
if @IncludeCredits = 1
begin
	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select 
		w.TimezoneDate as CalendarDate
		,t.Id
		,t.Amount
		,6 as Type
		,0 as SubType
	from 
		#TransactionsTable t
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) w
	where 
		t.TransactionTypeId = 17 -- Credit
end

--Getting Write off from transaction table using our temp table created above
if @IncludeWriteOffs = 1
begin
	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select 
		w.TimezoneDate as CalendarDate
		,t.Id
		,t.Amount
		,7 as Type
		,0 as SubType
	from 
		#TransactionsTable t
		CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) w
	where 
		t.TransactionTypeId = 10 --Write off
end

--Getting Reverse charge, Reverse charge earned from transaction table using our temp table created above
if @IncludeReversals = 1
begin
	insert into #ResultTable
	(
		CalendarDate
		,ForCounting
		,ForSumAmount
		,Type
		,SubType
	)
	select
		CalendarDate
		,'' as ForCounting
		,sum(Amount) as ForSumAmount
		,8 as Type
		,0 as SubType
	from
		(
			select 
				w.TimezoneDate as CalendarDate
				,t.Id as ReversalId
				,t.Amount
			from 
				#TransactionsTable t 
				CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) w
			where 
				t.TransactionTypeId in (7, 24) --Reverse charge, Reverse charge earned
		union all
			select 
				w.TimezoneDate as CalendarDate
				,r.ReverseChargeId as ReversalId
				,-t.Amount
			from 
				#TransactionsTable t 
				inner join ReverseDiscount r on t.Id = r.Id -- had to keep join in for group by to sum properly
				CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) w
			where 
				t.TransactionTypeId in (24, 15,22) -- Reverse Discount, Reversed Deferred Discount
		)Reversals
	group by CalendarDate,ReversalId
end

--Unioning together the results from all the queries above
select 
	dateadd(minute,SubType,dateadd(hour,Type,CalendarDate)) as CalendarDate
	,count(ForCounting) as Count
	,sum(ForSumAmount) as Amount
	,Type
	,SubType
from 
	#ResultTable
group by 
	dateadd(hour,Type,CalendarDate)
	,Type
	,SubType
union all
select 
	dateadd(minute,SubType,dateadd(hour,Type,'1900-01-01')) as CalendarDate
	,count(ForCounting) as Count
	,sum(ForSumAmount) as Amount
	,Type
	,SubType
from 
	#ResultTable
group by 
	Type
	,SubType

set nocount off

--Dropping the 2 temporary files that were created
drop table #ResultTable
drop table #TransactionsTable

GO

