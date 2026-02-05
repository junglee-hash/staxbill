/*********************************************************************************
[]


Inputs:
@AccountId bigint
@CustomerId bigint = null
	
Work:
Deletes a draft invoice and all related data

Outputs:

*********************************************************************************/
CREATE procedure [dbo].[usp_DeleteProjectedDraftInvoicesForAccount]
	@AccountId bigint,
	@CustomerId bigint = null,
	@DeleteProjectedBillingPeriods bit = 0
AS

SET NOCOUNT ON


DELETE child 
FROM SubscriptionProductActivityJournalDraftCharge child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

DELETE child 
FROM DraftDiscount child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

DELETE child 
FROM DraftChargeProductItem child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete dt from DraftTax dt
inner join DraftCharge dc ON dc.Id = dt.DraftChargeId
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete child
from DraftSubscriptionProductCharge child
INNER JOIN DraftCharge dc on dc.Id = child.Id
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete child
from DraftPurchaseCharge child
INNER JOIN DraftCharge dc on dc.Id = child.Id
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete child
from DraftChargeTier child
INNER JOIN DraftCharge dc on dc.Id = child.DraftChargeId
INNER JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete child
from DraftCharge child
INNER JOIN DraftInvoice di on di.Id = child.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete child
from DraftPaymentSchedule child
INNER JOIN DraftInvoice di on di.Id = child.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete child
from ProjectedInvoice child
INNER JOIN Customer c ON c.Id = child.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

DELETE child 
FROM CustomerEmailLogDraftInvoice child
INNER JOIN DraftInvoice di on di.Id = child.DraftInvoiceId AND di.DraftInvoiceStatusId = 5
INNER JOIN Customer c ON c.Id = di.CustomerId
WHERE c.AccountId = @AccountId
AND ISNULL(@CustomerId, c.Id) = c.Id

delete parent
from DraftInvoice parent
INNER JOIN Customer c ON c.Id = parent.CustomerId
WHERE c.AccountId = @AccountId AND parent.DraftInvoiceStatusId = 5
AND ISNULL(@CustomerId, c.Id) = c.Id

if (@DeleteProjectedBillingPeriods = 1)
BEGIN
	delete bp
	from BillingPeriod bp
	INNER JOIN Customer c ON c.Id = bp.CustomerId
	WHERE c.AccountId = @AccountId AND bp.PeriodStatusId = 3
	AND ISNULL(@CustomerId, c.Id) = c.Id
END

SET NOCOUNT OFF

select 0

GO

