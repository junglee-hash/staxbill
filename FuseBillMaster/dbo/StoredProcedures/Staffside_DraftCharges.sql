
CREATE PROCEDURE [dbo].[Staffside_DraftCharges]
	@CustomerId BIGINT
AS
--Note: Currently this only has Draft Subscription Product Charges, can union in Purchases in the future if needed

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT
	dc.Id as DraftChargeId
	,dc.CreatedTimestamp
	,dc.ModifiedTimestamp
	,dc.Quantity
	,dc.UnitPrice
	,dc.Amount
	,dc.DraftInvoiceId
	,dc.Name
	,dc.Description
	,tt.Name as TransactionType
	,cu.IsoName as Currency
	,dc.EffectiveTimestamp
	,dc.ProratedUnitPrice
	,dc.RangeQuantity
	,dc.TaxableAmount
	,dcs.Name as Status
	,dc.SortOrder
	,dc.DraftInvoiceId
	,dis.Name as DraftInvoiceStatus
	,di.CreatedTimestamp as DraftInvoiceCreated
	,di.ModifiedTimestamp as DraftInvoiceModified
	,di.Subtotal
	,di.Total
	,c.Id as FusebillId
	,c.Reference as CustomerId
	,cs.Name as CustomerStatus
	,c.ModifiedTimestamp as CustomerModified
	,s.Id as SubscriptionId
	,COALESCE(so.Name,s.PlanName) as SubscriptionName
	,s.PlanCode
	,s.ModifiedTimestamp as SubscriptionModified
	,ss.Name as SubscriptionStatus
	,sp.Id as SubscriptionProductId
	,sp.PlanProductName
	,sp.PlanProductCode
	,sps.Name as SubscriptionProductStatus
	,sp.Included
	,sp.ModifiedTimestamp as SubscriptionProductModified
FROM DraftCharge dc
INNER JOIN DraftSubscriptionProductCharge dspc ON dspc.Id = dc.Id
INNER JOIN DraftInvoice di ON di.Id = dc.DraftInvoiceId
INNER JOIN SubscriptionProduct sp ON sp.Id = dspc.SubscriptionProductId
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
LEFT JOIN SubscriptionOverride so ON so.Id = s.Id
INNER JOIN Customer c ON c.Id = s.CustomerId
INNER JOIN Lookup.TransactionType tt ON tt.Id = dc.TransactionTypeId
INNER JOIN Lookup.Currency cu ON cu.Id = dc.CurrencyId
INNER JOIN Lookup.DraftChargeStatus dcs ON dcs.Id = dc.StatusId
INNER JOIN Lookup.DraftInvoiceStatus dis ON dis.Id = di.DraftInvoiceStatusId
INNER JOIN Lookup.SubscriptionProductStatus sps ON sps.Id = sp.StatusId
INNER JOIN Lookup.SubscriptionStatus ss ON ss.Id = s.StatusId
INNER JOIN Lookup.CustomerStatus cs ON cs.Id = c.StatusId
WHERE s.CustomerId = @CustomerId
ORDER BY dc.DraftInvoiceId,s.StatusId

GO

