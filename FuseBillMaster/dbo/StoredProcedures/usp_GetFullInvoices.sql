CREATE   PROCEDURE [dbo].[usp_GetFullInvoices]
	@invoiceIds AS dbo.IDList READONLY,
	@excludeZeroDollarCharges bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @invoices table
(
InvoiceId bigint
)

INSERT INTO @invoices (InvoiceId)
SELECT ids.Id
FROM @invoiceIds ids

SELECT i.* FROM [dbo].[Invoice] i
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

SELECT ic.* FROM [dbo].[InvoiceCustomer] ic
INNER JOIN @invoices ii ON ic.InvoiceId = ii.InvoiceId

SELECT ia.*
	, ia.AddressTypeId as AddressType
FROM [dbo].[InvoiceAddress] ia
INNER JOIN @invoices ii ON ia.InvoiceId = ii.InvoiceId

SELECT ic.* FROM [dbo].[InvoiceCustomerAdditional] ic
INNER JOIN @invoices ii ON ic.InvoiceId = ii.InvoiceId

SELECT ia.*
FROM [dbo].[InvoiceAddressAdditional] ia
INNER JOIN [dbo].[InvoiceCustomerAdditional] ic ON ic.Id = ia.InvoiceCustomerAdditionalId
INNER JOIN @invoices ii ON ic.InvoiceId = ii.InvoiceId

SELECT ps.*
		,ps.StatusId as [Status]
FROM [dbo].[PaymentSchedule] ps
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId

SELECT ir.*
FROM [dbo].[InvoiceRevision] ir
INNER JOIN @invoices ii ON ir.InvoiceId = ii.InvoiceId

SELECT psj.*
	, psj.StatusId as [Status]
FROM [PaymentSchedule] ps
INNER JOIN [dbo].[PaymentScheduleJournal] psj ON ps.Id = psj.PaymentScheduleId AND psj.IsActive = 1
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId

SELECT ij.* FROM [dbo].[InvoiceJournal] ij
INNER JOIN @invoices ii ON ij.InvoiceId = ii.InvoiceId
WHERE ij.IsActive = 1

SELECT c.*
	, t.*
	, c.EarningTimingTypeId as EarningTimingType
	, c.EarningTimingIntervalId as EarningTimingInterval
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Charge] c
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId
INNER JOIN [Transaction] t ON t.Id = c.Id
WHERE t.Amount > 0 OR @excludeZeroDollarCharges = 0

SELECT cle.*
FROM [dbo].ChargeLastEarning cle
INNER JOIN [dbo].[Charge] c ON c.Id = cle.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT cg.* FROM [dbo].[ChargeGroup] cg
INNER JOIN @invoices ii ON cg.InvoiceId = ii.InvoiceId

SELECT d.*
	, t.*
	, d.DiscountTypeId as DiscountType
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Discount] d
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
INNER JOIN [Transaction] t ON t.Id = d.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT e.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Earning] e
INNER JOIN [dbo].[Charge] c ON c.Id = e.ChargeId
INNER JOIN [Transaction] t ON t.Id = e.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT re.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseEarning] re
INNER JOIN [Transaction] t ON t.Id = re.Id
INNER JOIN [dbo].[ReverseCharge] rc ON rc.Id = re.ReverseChargeId
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT rd.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseDiscount] rd
INNER JOIN [Transaction] t ON t.Id = rd.Id
INNER JOIN [dbo].[Discount] d ON d.Id = rd.OriginalDiscountId
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT rc.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseCharge] rc
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
INNER JOIN [Transaction] t ON t.Id = rc.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT gl.*
	, gl.StatusId as [Status]
FROM [dbo].[GLCode] gl
INNER JOIN [dbo].[Charge] c ON gl.Id = c.GLCodeId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT spc.* FROM [dbo].[SubscriptionProductCharge] spc
INNER JOIN [dbo].[Charge] c ON spc.Id = c.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT pc.*
FROM [dbo].[PurchaseCharge] pc
INNER JOIN [dbo].[Charge] c ON c.Id = pc.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as PricingModelType
	, p.EarningTimingTypeId as EarningTimingType
	, p.EarningTimingIntervalId as EarningTimingInterval
FROM [dbo].[PurchaseCharge] pc
INNER JOIN [dbo].[Purchase] p ON p.Id = pc.PurchaseId
INNER JOIN [dbo].[Charge] c ON c.Id = pc.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT tax.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Tax] tax
INNER JOIN @invoices ii ON tax.InvoiceId = ii.InvoiceId
INNER JOIN [Transaction] t ON t.Id = tax.Id

SELECT rt.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[ReverseTax] rt
INNER JOIN [Transaction] t ON t.Id = rt.Id
INNER JOIN [dbo].[Tax] tax ON tax.Id = rt.OriginalTaxId
INNER JOIN @invoices ii ON tax.InvoiceId = ii.InvoiceId

SELECT d.*
FROM [dbo].[Dispute] d
INNER JOIN @invoices ii ON d.InvoiceId = ii.InvoiceId

SELECT w.*
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[WriteOff] w
INNER JOIN @invoices ii ON w.InvoiceId = ii.InvoiceId
INNER JOIN [Transaction] t ON t.Id = w.Id

SELECT pn.* 
FROM [dbo].[PaymentNote] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[PaymentNote] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId
INNER JOIN [Payment] p ON p.Id = pn.PaymentId
INNER JOIN [Transaction] t ON t.Id = p.Id

SELECT pn.* 
FROM [dbo].[RefundNote] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[RefundNote] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId
INNER JOIN [Refund] p ON p.Id = pn.RefundId
INNER JOIN [Transaction] t ON t.Id = p.Id

SELECT cn.* 
FROM [dbo].[CreditNote] cn
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId

SELECT cn.* 
FROM [dbo].[CreditNoteGroup] cn
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId

SELECT cn.* 
FROM [dbo].[CreditAllocation] cn
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[CreditAllocation] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId
INNER JOIN [Credit] p ON p.Id = pn.CreditId
INNER JOIN [Transaction] t ON t.Id = p.Id

SELECT cn.* 
FROM [dbo].[DebitAllocation] cn
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[DebitAllocation] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId
INNER JOIN [Debit] p ON p.Id = pn.DebitId
INNER JOIN [Transaction] t ON t.Id = p.Id

SELECT cn.* 
FROM [dbo].[OpeningBalanceAllocation] cn
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId

SELECT p.* 
	, t.*
	, t.TransactionTypeId as TransactionType
FROM [dbo].[OpeningBalanceAllocation] pn
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId
INNER JOIN [OpeningBalance] p ON p.Id = pn.OpeningBalanceId
INNER JOIN [Transaction] t ON t.Id = p.Id

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
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId
 INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = sp.PlanProductUniqueId
WHERE sp.StatusId != 2
ORDER BY pp.SortOrder

SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as [Status]
FROM [dbo].[Product] p
INNER JOIN Purchase pu ON p.Id = pu.ProductId
INNER JOIN [dbo].[PurchaseCharge] dpc ON pu.Id = dpc.PurchaseId
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId
UNION ALL
SELECT p.*
      ,p.[ProductTypeId] as ProductType
      ,p.[ProductStatusId] as [Status]
FROM [dbo].[Product] p
INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
INNER JOIN [dbo].[SubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId

SELECT c.*
	, c.TitleId as [Title]
	, c.StatusId as [Status]
	, c.AccountStatusId as [AccountStatus]
	, c.NetsuiteEntityTypeId as [NetsuiteEntityType]
	, c.SalesforceAccountTypeId as [SalesforceAccountType]
	, c.SalesforceSynchStatusId as [SalesforceSynchStatus]
FROM Customer c
INNER JOIN Invoice i ON c.Id = i.CustomerId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId
UNION
SELECT c.*
	, c.TitleId as [Title]
	, c.StatusId as [Status]
	, c.AccountStatusId as [AccountStatus]
	, c.NetsuiteEntityTypeId as [NetsuiteEntityType]
	, c.SalesforceAccountTypeId as [SalesforceAccountType]
	, c.SalesforceSynchStatusId as [SalesforceSynchStatus]
FROM Customer c
INNER JOIN InvoiceCustomerAdditional ic ON c.Id = ic.CustomerId
INNER JOIN @invoices ii on ic.InvoiceId = ii.InvoiceId

SELECT cbs.*
	, cbs.TermId as [Term]
	, cbs.IntervalId as [Interval]
	, cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption]
	, cbs.RechargeTypeId as [RechargeType]
	, cbs.HierarchySuspendOptionId as [HierarchySuspendOption]
FROM CustomerBillingSetting cbs
INNER JOIN Invoice i ON cbs.Id = i.CustomerId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId
UNION
SELECT cbs.*
	, cbs.TermId as [Term]
	, cbs.IntervalId as [Interval]
	, cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption]
	, cbs.RechargeTypeId as [RechargeType]
	, cbs.HierarchySuspendOptionId as [HierarchySuspendOption]
FROM CustomerBillingSetting cbs
INNER JOIN InvoiceCustomerAdditional ic ON cbs.Id = ic.CustomerId
INNER JOIN @invoices ii on ic.InvoiceId = ii.InvoiceId

SELECT cbs.*
	, cbs.TrackedItemDisplayFormatId as [TrackedItemDisplayFormat]
FROM CustomerInvoiceSetting cbs
INNER JOIN Invoice i ON cbs.Id = i.CustomerId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

SELECT pc.*
FROM [dbo].[ChargeTier] pc
INNER JOIN [dbo].[Charge] c ON c.Id = pc.ChargeId
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT s.*
	,s.[StatusId] as [Status]
    ,s.[IntervalId] as Interval
FROM Subscription s
INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
INNER JOIN [dbo].[SubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId

SELECT p.*
	, p.StatusId as [Status]
	, p.PricingModelTypeId as [PricingModelType]
	, p.EarningTimingIntervalId as [EarningTimingInterval]
	, p.EarningTimingTypeId as [EarningTimingType]
FROM Purchase p
INNER JOIN [dbo].[PurchaseCharge] dpc ON p.Id = dpc.PurchaseId
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId

SELECT es.*
FROM EarningSchedule es
INNER JOIN [dbo].[Charge] c ON es.ChargeId = c.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT eds.*
FROM EarningDiscountSchedule eds
INNER JOIN [dbo].[Charge] c ON eds.ChargeId = c.Id
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId

SELECT iis.*  
FROM InvoiceSignature iis
INNER JOIN Invoice i ON iis.Id = i.InvoiceSignatureId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

END

GO

