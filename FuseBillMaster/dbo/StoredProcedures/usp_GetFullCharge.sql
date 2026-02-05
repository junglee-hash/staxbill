CREATE PROCEDURE [dbo].[usp_GetFullCharge]
	@chargeId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @invoiceId bigint = (SELECT InvoiceId FROM Charge WHERE Id = @chargeId)

SELECT c.*
	, t.*
	, c.EarningTimingTypeId as EarningTimingType
	, c.EarningTimingIntervalId as EarningTimingInterval
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Charge] c
INNER JOIN [Transaction] t ON t.Id = c.Id
WHERE c.Id = @chargeId

SELECT i.* FROM [dbo].[Invoice] i
WHERE i.Id = @invoiceId

SELECT ps.*
	,ps.StatusId as [Status]
FROM [dbo].[PaymentSchedule] ps
WHERE ps.InvoiceId = @invoiceId

SELECT psj.*
	, psj.StatusId as [Status]
FROM [PaymentSchedule] ps
INNER JOIN [dbo].[PaymentScheduleJournal] psj ON ps.Id = psj.PaymentScheduleId AND psj.IsActive = 1
WHERE ps.InvoiceId = @invoiceId

SELECT ij.* FROM [dbo].[InvoiceJournal] ij
WHERE ij.InvoiceId = @invoiceId AND ij.IsActive = 1

SELECT cle.*
FROM [dbo].ChargeLastEarning cle
WHERE cle.Id = @chargeId

SELECT cg.* FROM [dbo].[ChargeGroup] cg
WHERE cg.InvoiceId = @invoiceId

SELECT d.*
	, t.*
	, d.DiscountTypeId as DiscountType
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Discount] d
INNER JOIN [dbo].[Transaction] t ON t.Id = d.Id
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
WHERE c.Id = @chargeId

SELECT e.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Earning] e
INNER JOIN [dbo].[Transaction] t ON t.Id = e.Id
INNER JOIN [dbo].[Charge] c ON c.Id = e.ChargeId
WHERE c.Id = @chargeId

SELECT de.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[EarningDiscount] de
INNER JOIN [dbo].[Transaction] t ON t.Id = de.Id
INNER JOIN [dbo].[Discount] d ON d.Id = de.DiscountId
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
WHERE c.Id = @chargeId

SELECT re.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseEarning] re
INNER JOIN [Transaction] t ON t.Id = re.Id
INNER JOIN [dbo].[ReverseCharge] rc ON rc.Id = re.ReverseChargeId
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
WHERE c.Id = @chargeId

SELECT rd.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseDiscount] rd
INNER JOIN [Transaction] t ON t.Id = rd.Id
INNER JOIN [dbo].[Discount] d ON d.Id = rd.OriginalDiscountId
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
WHERE c.Id = @chargeId

SELECT rc.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseCharge] rc
INNER JOIN [Transaction] t ON t.Id = rc.Id
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
WHERE c.Id = @chargeId

SELECT gl.*
	, gl.StatusId as [Status]
FROM [dbo].[GLCode] gl
INNER JOIN [dbo].[Charge] c ON gl.Id = c.GLCodeId
WHERE c.Id = @chargeId

SELECT spc.* FROM [dbo].[SubscriptionProductCharge] spc
INNER JOIN [dbo].[Charge] c ON spc.Id = c.Id
WHERE c.Id = @chargeId

SELECT pc.*
FROM [dbo].[PurchaseCharge] pc
INNER JOIN [dbo].[Charge] c ON c.Id = pc.Id
WHERE c.Id = @chargeId

SELECT tax.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Tax] tax
INNER JOIN [Transaction] t ON t.Id = tax.Id
WHERE tax.InvoiceId = @invoiceId

SELECT rt.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseTax] rt
INNER JOIN [Transaction] t ON t.Id = rt.Id
INNER JOIN [dbo].[Tax] tax ON tax.Id = rt.OriginalTaxId
WHERE tax.InvoiceId = @invoiceId

SELECT w.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[WriteOff] w
INNER JOIN [Transaction] t ON t.Id = w.Id
WHERE w.InvoiceId = @invoiceId

SELECT pn.* 
FROM [dbo].[PaymentNote] pn
WHERE pn.InvoiceId = @invoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[PaymentNote] pn
INNER JOIN [Payment] p ON p.Id = pn.PaymentId
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE pn.InvoiceId = @invoiceId

SELECT pn.* 
FROM [dbo].[RefundNote] pn
WHERE pn.InvoiceId = @invoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[RefundNote] pn
INNER JOIN [Refund] p ON p.Id = pn.RefundId
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE pn.InvoiceId = @invoiceId

SELECT cn.* 
FROM [dbo].[CreditNote] cn
WHERE cn.InvoiceId = @invoiceId

SELECT cn.* 
FROM [dbo].[CreditNoteGroup] cn
WHERE cn.InvoiceId = @invoiceId

SELECT cn.* 
FROM [dbo].[CreditAllocation] cn
WHERE cn.InvoiceId = @invoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[CreditAllocation] pn
INNER JOIN [Credit] p ON p.Id = pn.CreditId
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE pn.InvoiceId = @invoiceId

SELECT cn.* 
FROM [dbo].[DebitAllocation] cn
WHERE cn.InvoiceId = @invoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[DebitAllocation] pn
INNER JOIN [Debit] p ON p.Id = pn.DebitId
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE pn.InvoiceId = @invoiceId

SELECT cn.* 
FROM [dbo].[OpeningBalanceAllocation] cn
WHERE cn.InvoiceId = @invoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[OpeningBalanceAllocation] pn
INNER JOIN [OpeningBalance] p ON p.Id = pn.OpeningBalanceId
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE pn.InvoiceId = @invoiceId

SELECT pc.*
FROM [dbo].[ChargeTier] pc
WHERE pc.ChargeId = @chargeId

SELECT sp.*
      ,sp.[StatusId] as [Status]
      ,sp.[EarningTimingTypeId] as EarningTimingType
      ,sp.[EarningTimingIntervalId] as EarningTimingInterval
      ,[ProductTypeId] as ProductTypeId
      ,sp.[ResetTypeId] as ResetType
      ,[RecurChargeTimingTypeId] as RecurChargeTimingType
      ,[RecurProrateGranularityId] as RecurProrateGranularity
      ,[QuantityChargeTimingTypeId] as QuantityChargeTimingType
      ,[QuantityProrateGranularityId] as QuantityProrateGranularity
      ,[PricingModelTypeId] as PricingModelType
      ,[EarningIntervalId] as EarningInterval
	  ,sp.CustomServiceDateIntervalId as CustomServiceDateInterval
	  ,sp.CustomServiceDateProjectionId as CustomServiceDateProjection
FROM [dbo].[SubscriptionProduct] sp
INNER JOIN [dbo].[SubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
WHERE dpc.Id = @chargeId

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as [Status]
FROM [dbo].[Product] p
INNER JOIN Purchase pu ON p.Id = pu.ProductId
INNER JOIN [dbo].[PurchaseCharge] dpc ON pu.Id = dpc.PurchaseId
WHERE dpc.Id = @chargeId
UNION ALL
SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as [Status]
FROM [dbo].[Product] p
INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
INNER JOIN [dbo].[SubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
WHERE dpc.Id = @chargeId

SELECT s.*
	,s.[StatusId] as [Status]
    ,s.[IntervalId] as Interval
FROM Subscription s
INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
INNER JOIN [dbo].[SubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
WHERE dpc.Id = @chargeId

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as [PricingModelType]
	, p.EarningTimingIntervalId as [EarningTimingInterval]
	, p.EarningTimingTypeId as [EarningTimingType]
FROM Purchase p
INNER JOIN [dbo].[PurchaseCharge] dpc ON p.Id = dpc.PurchaseId
WHERE dpc.Id = @chargeId

SELECT es.*
FROM EarningSchedule es
WHERE es.ChargeId = @chargeId

SELECT es.*
FROM EarningDiscountSchedule es
WHERE es.ChargeId = @chargeId

END

GO

