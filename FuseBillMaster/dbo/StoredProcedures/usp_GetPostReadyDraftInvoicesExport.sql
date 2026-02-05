CREATE   PROCEDURE [dbo].[usp_GetPostReadyDraftInvoicesExport]
 @accountId BIGINT
AS  
BEGIN  
	 -- SET NOCOUNT ON added to prevent extra result sets from  
	 -- interfering with SELECT statements.  
	SET NOCOUNT ON;  
  

  DECLARE @TimezoneId INT
SELECT @TimezoneId = TimezoneId
FROM AccountPreference
WHERE Id = @accountId

	SELECT
		di.Id as [Draft invoice ID]
		, c.Id AS [Customer Stax Bill ID]  
		, c.Reference AS [Customer Reference]
		, c.FirstName AS [Customer First Name]  
		, c.LastName AS [Customer Last Name]  
		, c.CompanyName AS [Customer Company Name]  
		, c.ParentId AS [Customer Parent ID]
		, EffectiveTimestamp.TimezoneDateTime AS [Invoice Created Date]
		, t.Name as [Invoice Net Terms]
		, dis.Name as [Invoice Status]
		, di.Total as [Invoice Total Amount]
		, di.Subtotal as [Invoice Subtotal]
		, ISNULL(SUM(dt.Amount), 0) as [Invoice Total Taxes]
		, ISNULL(SUM(dd.Amount), 0) as [Invoice Total Discounts]
		, cur.IsoName as [Currency]
		, CAST(di.ReferenceDate as Date) as [Reference Date]
		, null as [Target Reference Date]
	FROM DraftInvoice di
	CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, di.EffectiveTimestamp) EffectiveTimestamp
	INNER JOIN Customer c ON c.Id = di.CustomerId
	INNER JOIN CustomerBillingSetting cbs ON cbs.Id = c.Id
	LEFT JOIN BillingPeriod bi ON bi.Id = di.BillingPeriodId
	LEFT JOIN BillingPeriodDefinition bpd ON bpd.Id = bi.BillingPeriodDefinitionId
	INNER JOIN Lookup.Term t ON t.Id = COALESCE(di.TermId, bpd.TermId, cbs.TermId)
	INNER JOIN Lookup.DraftInvoiceStatus dis ON dis.Id = di.DraftInvoiceStatusId
	INNER JOIN Lookup.Currency cur ON cur.Id = c.CurrencyId
	INNER JOIN DraftCharge dc ON di.Id = dc.DraftInvoiceId
	LEFT JOIN DraftTax dt ON di.Id = dt.DraftInvoiceId
	LEFT JOIN DraftDiscount dd ON dc.Id = dd.DraftChargeId

	WHERE c.AccountId = @accountId
		AND c.StatusId = 2 -- Active
		AND c.IsDeleted = 0
		AND di.DraftInvoiceStatusId = 2 -- Ready
	GROUP BY di.Id, c.Id, c.Reference, c.FirstName, c.LastName, c.CompanyName, c.ParentId
		, EffectiveTimestamp.TimezoneDateTime, t.Name, dis.Name, di.Total, di.Subtotal, di.ReferenceDate, cur.IsoName
END

GO

