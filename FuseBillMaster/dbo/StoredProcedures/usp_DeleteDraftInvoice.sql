CREATE PROC [dbo].[usp_DeleteDraftInvoice]
	@Id bigint
AS
SET NOCOUNT ON

DELETE child 
FROM SubscriptionProductActivityJournalDraftCharge child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
WHERE dc.DraftInvoiceId = @Id

DELETE child 
FROM DraftDiscount child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
WHERE dc.DraftInvoiceId = @Id

DELETE child 
FROM DraftChargeProductItem child
INNER JOIN DraftCharge dc ON dc.Id = child.DraftChargeId
WHERE dc.DraftInvoiceId = @Id

delete dt from DraftTax dt
inner join DraftCharge dc ON dc.Id = dt.DraftChargeId
WHERE dc.DraftInvoiceId = @Id

delete child
from DraftSubscriptionProductCharge child
INNER JOIN DraftCharge dc on dc.Id = child.Id
WHERE dc.DraftInvoiceId = @Id

delete child
from DraftPurchaseCharge child
INNER JOIN DraftCharge dc on dc.Id = child.Id
WHERE dc.DraftInvoiceId = @Id

delete child
from DraftChargeTier child
INNER JOIN DraftCharge dc on dc.Id = child.DraftChargeId
WHERE dc.DraftInvoiceId = @Id

delete child
from DraftCharge child
WHERE child.DraftInvoiceId = @Id

delete child
from DraftPaymentSchedule child
WHERE child.DraftInvoiceId = @Id

delete child
from CustomerEmailLogDraftInvoice child
WHERE child.DraftInvoiceId = @Id

DELETE FROM [DraftInvoice]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

