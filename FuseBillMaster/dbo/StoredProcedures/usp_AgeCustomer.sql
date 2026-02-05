/*********************************************************************************
[]


Inputs:
@CustomerId bigint
	,@MinutestoSubtract int 
	,@UpdateCreatedTimestamps int = 0

Work:
subtracts the number of minutes equal to the minutes inputted from all dates except createdtimestamps
future version may also modify created timestamps

Outputs:
@CustomerId

*********************************************************************************/
CREATE procedure [dbo].[usp_AgeCustomer]
	@CustomerId bigint
	,@MinutestoSubtract int 
	,@UpdateCreatedTimestamps int = 0
AS

SET NOCOUNT ON

Update Customer
set 
	ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ModifiedTimestamp)
	,EffectiveTimestamp =  dateadd(Minute,-@MinutestoSubtract,EffectiveTimestamp)
	,ActivationTimestamp = dateadd(Minute,-@MinutestoSubtract,ActivationTimestamp)
FROM 
	Customer
WHERE Id = @CustomerId


update Charge 
set 
	EarningStartDate = dateadd(Minute,-@MinutestoSubtract,EarningStartDate)
	,EarningEndDate = dateadd(Minute,-@MinutestoSubtract,EarningEndDate)
from Customer c inner join [Transaction] t on c.id = t.customerid
inner join charge ch on t.id = ch.Id
WHERE c.Id = @CustomerId

update [Transaction]
set EffectiveTimestamp = dateadd(minute,-@MinutestoSubtract,EffectiveTimestamp)
where CustomerId = @CustomerId

Update BillingPeriod
set 
	ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ModifiedTimestamp)
	,StartDate =  dateadd(Minute,-@MinutestoSubtract,StartDate)
	,RechargeDate =  dateadd(Minute,-@MinutestoSubtract,RechargeDate)
	,EndDate =   dateadd(Minute,-@MinutestoSubtract,EndDate)
where 
	CustomerId = @CustomerId

Update ChargeLastEarning
SET
	 ChargeLastEarning.ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract, cle.ModifiedTimestamp)
from 
	ChargeLastEarning cle inner join charge c
		on cle.id = c.id
	inner join [Transaction] t
	on c.id = t.id
WHERE 
	CustomerId = @CustomerId

update CustomerAddressPreference
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ModifiedTimestamp)
WHERE Id = @CustomerId

update CustomerBillingSetting
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ModifiedTimestamp)
WHERE Id = @CustomerId


update DraftCharge
set
	ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,dc.ModifiedTimestamp)
	,EffectiveTimestamp =  dateadd(Minute,-@MinutestoSubtract,dc.EffectiveTimestamp)
from 
	draftcharge dc
	inner join	DraftInvoice di
		on dc.DraftInvoiceId = di.Id
	inner join BillingPeriod bp
		on di.BillingPeriodId = bp.id
where bp.CustomerId = @CustomerId

update DraftInvoice 
set
	ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,di.ModifiedTimestamp)
	,EffectiveTimestamp =  dateadd(Minute,-@MinutestoSubtract,di.EffectiveTimestamp)
from 
	DraftInvoice di
	inner join BillingPeriod bp
		on di.BillingPeriodId = bp.id
where bp.CustomerId = @CustomerId


Update Invoice
	set
	PostedTimestamp =  dateadd(Minute,-@MinutestoSubtract,i.postedTimestamp)
	,EffectiveTimestamp =  dateadd(Minute,-@MinutestoSubtract,i.EffectiveTimestamp)
	From Invoice i
	inner join BillingPeriod bp
	on i.BillingPeriodId = bp.id
where bp.CustomerId = @CustomerId

Update PaymentActivityJournal 
	set
	EffectiveTimestamp =  dateadd(Minute,-@MinutestoSubtract,EffectiveTimestamp)
	From PaymentActivityJournal 
where CustomerId = @CustomerId

update InvoiceAddress
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ia.ModifiedTimestamp)
	from InvoiceAddress ia
	inner join Invoice i
		on ia.InvoiceId = i.id
	inner join BillingPeriod bp
	on i.BillingPeriodId = bp.id
where bp.CustomerId = @CustomerId

update InvoiceCustomer
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ic.ModifiedTimestamp)
	,EffectiveTimestamp =  dateadd(Minute,-@MinutestoSubtract,ic.EffectiveTimestamp)
	from InvoiceCustomer ic
	inner join Invoice i
		on ic.InvoiceId = i.id
	inner join BillingPeriod bp
	on i.BillingPeriodId = bp.id
where bp.CustomerId = @CustomerId
		
update PaymentScheduleJournal
	set DueDate =  dateadd(Minute,-@MinutestoSubtract,ic.DueDate)
	from PaymentScheduleJournal ic
	inner join PaymentSchedule ps ON ps.Id = ic.PaymentScheduleId
	inner join Invoice i
		on ps.InvoiceId = i.id
	inner join BillingPeriod bp
	on i.BillingPeriodId = bp.id
where bp.CustomerId = @CustomerId

update Subscription
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ModifiedTimestamp)
	,ScheduledActivationTimestamp = dateadd(Minute,-@MinutestoSubtract,ScheduledActivationTimestamp)
	,ProvisionedTimestamp = dateadd(Minute,-@MinutestoSubtract,ProvisionedTimestamp)
where CustomerId = @CustomerId

update SubscriptionProduct 
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,sp.ModifiedTimestamp)
	,StartDate = dateadd(Minute,-@MinutestoSubtract,sp.StartDate)
	from SubscriptionProduct sp
	inner join Subscription s 
	on sp.SubscriptionId = s.Id
where s.CustomerId = @CustomerId



	
update SubscriptionOverride
	set ModifiedTimestamp =  dateadd(Minute,-@MinutestoSubtract,so.ModifiedTimestamp)
from SubscriptionOverride so
	inner join Subscription s
	on so.id = s.id
where CustomerId = @CustomerId

--Tech Debt: Should not be using CreatedTimestamp for logic
update  CollectionScheduleActivity
set CreatedTimestamp = dateadd(Minute,-@MinutestoSubtract,csa.CreatedTimestamp )
from 
	CollectionScheduleActivity csa
WHERE
	csa.CustomerId = @CustomerId	

--Tech Debt: Should not be using CreatedTimestamp for logic	
update CustomerAccountStatusJournal
	set CreatedTimestamp = dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	, EffectiveTimestamp = dateadd(Minute,-@MinutestoSubtract,EffectiveTimestamp)
where CustomerId = @CustomerId



IF @UpdateCreatedTimestamps = 1
BEGIN

	Update Customer
	set 
		CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	FROM 
		Customer
	WHERE 
		Id = @CustomerId

	update [Transaction]
	SET 
		CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	where 
		CustomerId = @CustomerId

	Update BillingPeriod
	set 
		CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	where 
		CustomerId = @CustomerId

	Update ChargeLastEarning
	SET
		 CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,cle.CreatedTimestamp)
	from 
		ChargeLastEarning cle inner join charge c
			on cle.id = c.id
		inner join [Transaction] t
		on c.id = t.id
	WHERE 
		CustomerId = @CustomerId

	update CustomerAddressPreference
		SET CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	WHERE 
		Id = @CustomerId

	update CustomerBillingSetting
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	WHERE 
		Id = @CustomerId

	update DraftCharge
	SET CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,dc.CreatedTimestamp)
	from 
		draftcharge dc
		inner join	DraftInvoice di
			on dc.DraftInvoiceId = di.Id
		inner join BillingPeriod bp
			on di.BillingPeriodId = bp.id
	where bp.CustomerId = @CustomerId

	update DraftInvoice 
	set
		CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,di.CreatedTimestamp)
	from 
		DraftInvoice di
		inner join BillingPeriod bp
			on di.BillingPeriodId = bp.id
	where bp.CustomerId = @CustomerId


	Update Invoice
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,i.CreatedTimestamp)
		From Invoice i
		inner join BillingPeriod bp
		on i.BillingPeriodId = bp.id
	where bp.CustomerId = @CustomerId

	update InvoiceAddress
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ia.CreatedTimestamp)
		from InvoiceAddress ia
		inner join Invoice i
			on ia.InvoiceId = i.id
		inner join BillingPeriod bp
		on i.BillingPeriodId = bp.id
	where bp.CustomerId = @CustomerId

	update InvoiceCustomer
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ic.CreatedTimestamp)
		from InvoiceCustomer ic
		inner join Invoice i
			on ic.InvoiceId = i.id
		inner join BillingPeriod bp
		on i.BillingPeriodId = bp.id
	where bp.CustomerId = @CustomerId
	
	update InvoiceJournal
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,ic.CreatedTimestamp)
		from InvoiceJournal ic
		inner join Invoice i
			on ic.InvoiceId = i.id
		inner join BillingPeriod bp
		on i.BillingPeriodId = bp.id
	where bp.CustomerId = @CustomerId	

	update Subscription
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,CreatedTimestamp)
	where CustomerId = @CustomerId
	
	update SubscriptionOverride
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,so.CreatedTimestamp)
	from SubscriptionOverride so
		inner join Subscription s
		on so.id = s.id
	where CustomerId = @CustomerId

	update SubscriptionPeriod 
		set CreatedTimestamp =  dateadd(Minute,-@MinutestoSubtract,sp.CreatedTimestamp)
		from SubscriptionPeriod sp
		inner join Subscription s
		on sp.SubscriptionId = s.id
	where CustomerId = @CustomerId



END

Select @CustomerId AS CustomerId

SET NOCOUNT OFF

GO

