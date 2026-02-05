/*********************************************************************************
[]


Inputs:
@DraftInvoiceId bigint
	
Work:
Deletes a draft invoice and all related data

Outputs:

*********************************************************************************/
CREATE procedure [dbo].[usp_DeleteDraftInvoicesForCustomer]
	@CustomerId bigint
AS

SET NOCOUNT ON


DELETE child 
FROM SubscriptionProductActivityJournalDraftCharge child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

DELETE child 
FROM DraftDiscount child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

DELETE child 
FROM DraftChargeProductItem child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

delete dt from DraftTax dt
inner join DraftCharge dc ON dc.Id = dt.DraftChargeId
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

delete child
from DraftSubscriptionProductCharge child
INNER JOIN DraftCharge dc on dc.Id = child.Id
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

delete child
from DraftPurchaseCharge child
INNER JOIN DraftCharge dc on dc.Id = child.Id
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

delete child
from DraftChargeTier child
INNER JOIN DraftCharge dc on dc.Id = child.DraftChargeId
LEFT JOIN DraftInvoice di on di.Id = dc.DraftInvoiceId
WHERE dc.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR dc.StatusId = 3) --ToDelete

delete child
from DraftCharge child
LEFT JOIN DraftInvoice di on di.Id = child.DraftInvoiceId
WHERE child.CustomerId = @CustomerId
AND (di.DraftInvoiceStatusId = 4 --deleted
OR child.StatusId = 3) --ToDelete

delete child
from DraftPaymentSchedule child
INNER JOIN DraftInvoice di on di.Id = child.DraftInvoiceId
WHERE di.CustomerId = @CustomerId
AND (
	di.DraftInvoiceStatusId = 4 --deleted
	OR NOT EXISTS (
		SELECT *
		FROM DraftCharge dc
		WHERE dc.DraftInvoiceId = di.Id
	)
)

delete child
from ProjectedInvoice child
INNER JOIN DraftInvoice di on di.Id = child.ProjectedInvoiceId
WHERE di.CustomerId = @CustomerId
AND (
	di.DraftInvoiceStatusId = 4 --deleted
	OR NOT EXISTS (
		SELECT *
		FROM DraftCharge dc
		WHERE dc.DraftInvoiceId = di.Id
	)
)

delete child
from CustomerEmailLogDraftInvoice child
INNER JOIN DraftInvoice di on di.Id = child.DraftInvoiceId
WHERE di.CustomerId = @CustomerId
AND (
	di.DraftInvoiceStatusId = 4 --deleted
	OR NOT EXISTS (
		SELECT *
		FROM DraftCharge dc
		WHERE dc.DraftInvoiceId = di.Id
	)
)

delete parent
from DraftInvoice parent
WHERE parent.CustomerId = @CustomerId
AND (
	parent.DraftInvoiceStatusId = 4 --deleted
	OR NOT EXISTS (
		SELECT *
		FROM DraftCharge dc
		WHERE dc.DraftInvoiceId = parent.Id
	)
)

SET NOCOUNT OFF

select 0

GO

