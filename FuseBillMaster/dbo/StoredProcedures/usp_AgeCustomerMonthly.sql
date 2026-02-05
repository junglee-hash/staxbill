
/*********************************************************************************
[]


Inputs:
CustomerId to age
Desired Renewal Date - if not populated the billing end date of the customer is used

Work:
calculates the number of minutes between now and the date the customer is to be aged to

Outputs:


*********************************************************************************/
create procedure [dbo].[usp_AgeCustomerMonthly]
@CustomerId bigint,
@Months bigint
AS

set nocount on

DECLARE
	@UtcDesiredRenewalDate datetime
	,@MinutesToSubtract int

select @UtcDesiredRenewalDate = dateadd(month,-@Months,GETUTCDATE())

set @MinutesToSubtract = datediff(minute,@UtcDesiredRenewalDate,GETUTCDATE())

exec usp_AgeCustomer @CustomerId, @MinutesToSubtract 




SET NOCOUNT OFF

GO

