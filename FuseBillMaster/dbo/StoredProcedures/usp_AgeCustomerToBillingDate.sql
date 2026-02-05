
/*********************************************************************************
[]


Inputs:
CustomerId to age
Desired Renewal Date - if not populated the billing end date of the customer is used

Work:
calculates the number of minutes between now and the date the customer is to be aged to

Outputs:


*********************************************************************************/
Create procedure [dbo].[usp_AgeCustomerToBillingDate]
@CustomerId bigint
AS

set nocount on

DECLARE
	@UtcDesiredRenewalDate datetime
	,@BillingDate datetime
	,@MinutesToSubtract int


SELECT
	@UtcDesiredRenewalDate = bp.EndDate
FROM
	Customer c
	inner join BillingPeriod bp
	on c.id = bp.CustomerId and bp.PeriodStatusId = 1
WHERE 
	c.Id = @CustomerId

if @UtcDesiredRenewalDate is null
set @UtcDesiredRenewalDate = GETUTCDATE()

set @MinutesToSubtract = datediff(minute,GETUTCDATE(),@UtcDesiredRenewalDate)

exec usp_AgeCustomer @CustomerId, @MinutesToSubtract


SET NOCOUNT OFF

GO

