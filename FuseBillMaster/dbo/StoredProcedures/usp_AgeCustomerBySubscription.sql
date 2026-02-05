
/*********************************************************************************
[]


Inputs:
CustomerId to age
Desired Renewal Date - if not populated the billing end date of the customer is used

Work:
calculates the number of minutes between now and the date the customer is to be aged to

Outputs:


*********************************************************************************/
CREATE procedure [dbo].[usp_AgeCustomerBySubscription]
@CustomerId bigint
AS

set nocount on

DECLARE
	@UtcDesiredRenewalDate datetime
	,@MinutesToSubtract int
	--,@CustomerId bigint

	--set @CustomerId = @SubscriptionId

SELECT
	@UtcDesiredRenewalDate = min(bp.EndDate)
FROM
	Customer c
	
	inner join Subscription s
	on c.id = s.CustomerId
	inner join BillingPeriodDefinition bpd
	on s.BillingPeriodDefinitionId =  bpd.Id
	inner join BillingPeriod bp on bp.BillingPeriodDefinitionId = bpd.Id
		and bp.PeriodStatusId = 1
WHERE s.Id = @CustomerId

if @UtcDesiredRenewalDate is null
set @UtcDesiredRenewalDate = GETUTCDATE()

set @MinutesToSubtract = datediff(minute,GETUTCDATE(),@UtcDesiredRenewalDate)

exec usp_AgeCustomer @CustomerId, @MinutesToSubtract


SET NOCOUNT OFF

GO

