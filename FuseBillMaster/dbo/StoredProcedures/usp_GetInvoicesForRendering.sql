CREATE   PROCEDURE [dbo].[usp_GetInvoicesForRendering]  
 @invoiceIds AS dbo.IDList READONLY,  
 @excludeZeroDollarCharges bit  
AS  
BEGIN  
-- SET NOCOUNT ON added to prevent extra result sets from  
-- interfering with SELECT statements.  
SET NOCOUNT ON;  
  
DECLARE @invoices TABLE  
(  
 InvoiceId BIGINT
)  
  
INSERT INTO @invoices (InvoiceId)  
SELECT ids.Id 
FROM @invoiceIds ids 
  
--This procedure is only ever called in a context where every single invoice belongs
--to the same account. It is therefore safe to grab the first invoice's account ID and
--assume every invoice shares it
DECLARE @AccountChargeGroupSortOrderPreference INT
SELECT @AccountChargeGroupSortOrderPreference = (
	SELECT TOP 1 aip.ChargeGroupOrderId 
	FROM @invoices ii 
	INNER JOIN Invoice i on i.Id = ii.InvoiceId
	INNER JOIN dbo.AccountInvoicePreference aip on aip.Id = i.AccountId
)

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
 , ia.AddressTypeId as AddressType  
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
  
SELECT psj.Id  
 , psj.PaymentScheduleId  
 , psj.DueDate  
 , psj.StatusId as [Status]  
 , psj.OutstandingBalance  
 , psj.CreatedTimestamp  
 , psj.IsActive  
FROM [PaymentSchedule] ps  
INNER JOIN [dbo].[PaymentScheduleJournal] psj ON ps.Id = psj.PaymentScheduleId AND psj.IsActive = 1  
INNER JOIN @invoices ii ON ps.InvoiceId = ii.InvoiceId  
  
SELECT ij.* FROM [dbo].[InvoiceJournal] ij  
INNER JOIN @invoices ii ON ij.InvoiceId = ii.InvoiceId  
WHERE ij.IsActive = 1  
  
SELECT c.*
 , c.EarningTimingTypeId as EarningTimingType  
 , c.EarningTimingIntervalId as EarningTimingInterval  
 , t.CreatedTimestamp  
 , t.CustomerId  
 , t.Amount  
 , t.EffectiveTimestamp  
 , t.TransactionTypeId as TransactionType  
 , t.[Description]  
 , t.CurrencyId  
 , t.SortOrder  
 , t.AccountId  
 , t.ModifiedTimestamp  
FROM [dbo].[Charge] c  
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId  
INNER JOIN [Transaction] t ON t.Id = c.Id  
WHERE t.Amount > 0 OR @excludeZeroDollarCharges = 0  
  

DECLARE @sqltext NVARCHAR(200)
SELECT @sqltext = 
	CASE 
	WHEN @AccountChargeGroupSortOrderPreference = 1 --DoNotSort
		THEN
		'
		SELECT cg.* FROM [dbo].[ChargeGroup] cg  
		INNER JOIN @invoiceIds ii ON cg.InvoiceId = ii.Id 
		' 
	WHEN @AccountChargeGroupSortOrderPreference = 2 --SubscriptionIDAscending
		THEN
		'
		SELECT cg.* FROM [dbo].[ChargeGroup] cg  
		INNER JOIN @invoiceIds ii ON cg.InvoiceId = ii.Id  
		ORDER BY cg.SubscriptionId ASC
		' 
		ELSE -- SubscriptionIDDescending
		'
		SELECT cg.* FROM [dbo].[ChargeGroup] cg  
		INNER JOIN @invoiceIds ii ON cg.InvoiceId = ii.Id  
		ORDER BY cg.SubscriptionId DESC
		'
	END
EXECUTE sp_executesql @sqltext, N'@invoiceIds dbo.IDList READONLY', @invoiceIds = @invoiceIds;
  

SELECT d.*
	, t.*
	, d.DiscountTypeId as DiscountType
	, t.TransactionTypeId as TransactionType
FROM [dbo].[Discount] d  
INNER JOIN [dbo].[Charge] c ON c.Id = d.ChargeId  
INNER JOIN [Transaction] t ON t.Id = d.Id  
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId  
  
SELECT gl.Id  
 , gl.AccountId  
 , gl.Code  
 , gl.Name  
 , gl.StatusId as [Status]  
 , gl.Used  
 , gl.CreatedTimestamp  
 , gl.ModifiedTimestamp  
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
 , t.CreatedTimestamp  
 , t.CustomerId  
 , t.Amount  
 , t.EffectiveTimestamp  
 , t.TransactionTypeId as TransactionType  
 , t.[Description]  
 , t.CurrencyId  
 , t.SortOrder  
 , t.AccountId  
 , t.ModifiedTimestamp  
FROM [dbo].[Tax] tax  
INNER JOIN @invoices ii ON tax.InvoiceId = ii.InvoiceId  
INNER JOIN [Transaction] t ON t.Id = tax.Id  
  
SELECT *  
FROM [dbo].[PaymentNote] pn  
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId 
  
SELECT cn.*  
FROM [dbo].[CreditNote] cn  
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId  
  
SELECT cn.*  
FROM [dbo].[CreditNoteGroup] cn  
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId  
  
SELECT *  
FROM [dbo].[CreditAllocation] cn  
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId  
  
SELECT *  
FROM [dbo].[DebitAllocation] cn  
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId  
  
SELECT *  
FROM [dbo].[OpeningBalanceAllocation] cn  
INNER JOIN @invoices ii ON cn.InvoiceId = ii.InvoiceId  
  
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
  
SELECT s.*  
 ,s.[StatusId] as [Status]  
    ,s.[IntervalId] as Interval  
FROM Subscription s  
INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId  
INNER JOIN [dbo].[SubscriptionProductCharge] dpc ON sp.Id = dpc.SubscriptionProductId  
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id  
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId  
  
SELECT p.*  
      ,p.[ProductTypeId] as ProductType  
      ,p.[ProductStatusId] as Status  
FROM [dbo].[Product] p  
INNER JOIN Purchase pu ON p.Id = pu.ProductId  
INNER JOIN [dbo].[PurchaseCharge] dpc ON pu.Id = dpc.PurchaseId  
INNER JOIN [dbo].[Charge] dc ON dc.Id = dpc.Id  
INNER JOIN @invoices ii ON dc.InvoiceId = ii.InvoiceId  
UNION ALL  
SELECT p.*  
      ,p.[ProductTypeId] as ProductType  
      ,p.[ProductStatusId] as Status  
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
  
SELECT cbs.*  
 , cbs.TermId as [Term]  
 , cbs.IntervalId as [Interval]  
 , cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption]  
 , cbs.RechargeTypeId as [RechargeType]  
 , cbs.HierarchySuspendOptionId as [HierarchySuspendOption]  
FROM CustomerBillingSetting cbs  
INNER JOIN Invoice i ON cbs.Id = i.CustomerId  
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId  
  
SELECT cbs.*  
 , cbs.TrackedItemDisplayFormatId as [TrackedItemDisplayFormat]  
FROM CustomerInvoiceSetting cbs  
INNER JOIN Invoice i ON cbs.Id = i.CustomerId  
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId  
  
SELECT pc.*  
FROM [dbo].[ChargeTier] pc  
INNER JOIN [dbo].[Charge] c ON c.Id = pc.ChargeId  
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId  
  
SELECT p.*  
  , t.*  
  , t.TransactionTypeId as TransactionType  
FROM [dbo].[PaymentNote] pn  
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId  
INNER JOIN [dbo].[Payment] p ON p.Id = pn.PaymentId  
INNER JOIN [Transaction] t ON t.Id = p.Id  
  
SELECT paj.*  
  , paj.PaymentActivityStatusId as PaymentActivityStatus  
  , paj.PaymentMethodTypeId as PaymentMethodType  
  , paj.PaymentSourceId as PaymentSource  
  , paj.PaymentTypeId as PaymentType  
  , paj.SettlementStatusId as SettlementStatus  
  , paj.DisputeStatusId as DisputeStatus
FROM [dbo].[PaymentNote] pn  
INNER JOIN @invoices ii ON pn.InvoiceId = ii.InvoiceId  
INNER JOIN [dbo].[Payment] p ON p.Id = pn.PaymentId  
INNER JOIN [dbo].[PaymentActivityJournal] paj ON paj.Id = p.PaymentActivityJournalId  
  
SELECT rtx.*,  
 t.*,  
 t.TransactionTypeId as TransactionType  
FROM [dbo].[ReverseTax] rtx  
INNER JOIN [dbo].[Transaction] t on t.Id = rtx.Id  
INNER JOIN [dbo].[Tax] tx on tx.Id = rtx.OriginalTaxId  
INNER JOIN @invoices ii ON tx.InvoiceId = ii.InvoiceId

SELECT rdx.*,  
 t.*,  
 t.TransactionTypeId as TransactionType  
FROM [dbo].[ReverseDiscount] rdx  
INNER JOIN [dbo].[Transaction] t on t.Id = rdx.Id  
INNER JOIN [dbo].[Discount] d on d.Id = rdx.OriginalDiscountId  
INNER JOIN [dbo].[Charge] rc on rc.Id = d.ChargeId
INNER JOIN @invoices ii ON rc.InvoiceId = ii.InvoiceId
  
SELECT ir.*  
FROM [dbo].[NetsuiteErrorLog] ir  
INNER JOIN @invoices ii ON ir.EntityId = ii.InvoiceId
	AND ir.EntityTypeId = 11 -- Invoice

SELECT rc.*  
, t.*  
, t.TransactionTypeId as TransactionType  
FROM [dbo].[ReverseCharge] rc
INNER JOIN [dbo].[Charge] c ON c.Id = rc.OriginalChargeId
INNER JOIN [dbo].[Transaction] t ON t.Id = rc.Id  
INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId  
  
SELECT c.*  
, t.*  
, t.TransactionTypeId as TransactionType  
FROM [dbo].[Credit] c  
INNER JOIN [dbo].[CreditAllocation] ca on ca.CreditId = c.Id  
INNER JOIN [dbo].[Transaction] t ON t.id = c.Id  
INNER JOIN @invoices ii ON ca.InvoiceId = ii.InvoiceId  
  
SELECT ref.*  
  , t.*  
  , t.TransactionTypeId as TransactionType  
FROM [dbo].[Refund] ref  
INNER JOIN [dbo].[RefundNote] rn on rn.RefundId = ref.Id  
INNER JOIN @invoices ii ON rn.InvoiceId = ii.InvoiceId  
INNER JOIN [Transaction] t ON t.Id = ref.Id  
  
SELECT rn.* 
FROM [dbo].[RefundNote] rn  
INNER JOIN @invoices ii ON rn.InvoiceId = ii.InvoiceId

SELECT paj.*  
	, paj.PaymentActivityStatusId as PaymentActivityStatus  
	, paj.PaymentMethodTypeId as PaymentMethodType  
	, paj.PaymentSourceId as PaymentSource  
	, paj.PaymentTypeId as PaymentType  
	, paj.SettlementStatusId as SettlementStatus 
	, paj.DisputeStatusId as DisputeStatus
FROM [dbo].[RefundNote] rn  
INNER JOIN @invoices ii ON rn.InvoiceId = ii.InvoiceId  
inner join Refund ref on ref.Id = rn.RefundId
inner join PaymentActivityJournal paj on paj.Id = ref.PaymentActivityJournalId
  
SELECT d.*  
, t.*  
, t.TransactionTypeId as TransactionType  
FROM [dbo].[Debit] d  
INNER JOIN [dbo].[DebitAllocation] da on da.DebitId = d.Id  
INNER JOIN [dbo].[Transaction] t ON t.id = d.Id  
INNER JOIN @invoices ii ON da.InvoiceId = ii.InvoiceId  
  
SELECT es.*
FROM @invoices ii JOIN Charge c ON ii.InvoiceId = c.InvoiceId 
	JOIN EarningSchedule es ON c.Id = es.ChargeId

SELECT iis.*  
FROM InvoiceSignature iis
INNER JOIN Invoice i ON iis.Id = i.InvoiceSignatureId
INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

END

GO

