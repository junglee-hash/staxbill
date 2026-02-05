CREATE PROCEDURE [Reporting].[JustLogin_RevenueDetail]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS
BEGIN

set nocount on
set transaction isolation level snapshot

DECLARE @TimezoneId BIGINT

--Removed timezone conversion to resolve STORY 16659 
--	Custom report input dates were being double offset as input parameters previously were previously passed in as UTC date, not UTC datetime with offset to return account timezone midnight
SELECT 
	--@StartDate = dbo.fn_GetUtcTime(@StartDate, TimezoneId)
	--,@EndDate = dbo.fn_GetUtcTime(@EndDate, TimezoneId)
	--,
	@TimezoneId = TimezoneId
FROM AccountPreference
WHERE Id = @AccountId

DECLARE @results TABLE (
	EffectiveTimestamp DATETIME
	,TransactionType NVARCHAR(15)
	,Number NVARCHAR(500)
	,CompanyName NVARCHAR(255)
	,SalesTrackingCode1Code NVARCHAR(255)
	,SalesTrackingCode1Name NVARCHAR(255)
	,BillingEntityCodeCode NVARCHAR(255)
	,BillingEntityCodeName NVARCHAR(255)
	,SalesTrackingCode3Code NVARCHAR(255)
	,SalesTrackingCode3Name NVARCHAR(255)
	,SalesTrackingCode4Code NVARCHAR(255)
	,SalesTrackingCode4Name NVARCHAR(255)
	,GSTTaxCodeCode NVARCHAR(255)
	,GSTTaxCodeName NVARCHAR(255)
	,GSTRate DECIMAL(18,6)
	,Currency NVARCHAR(50)
	,InvoiceAmount MONEY
	,SumOfDiscounts MONEY
	,SubTotal MONEY
	,SumOfTaxes MONEY
	,NetTotal MONEY
)

;WITH InvoiceDetails AS(
SELECT
	dbo.fn_GetTimezoneTime(di.EffectiveTimestamp,@TimezoneId) as EffectiveTimestamp
	,'Invoice' as TransactionType
	,CONVERT(nvarchar,di.InvoiceNumber) as Number
	,ISNULL(ic.CompanyName,'') as CompanyName
	,ISNULL(stc1.Code,'') as SalesTrackingCode1Code
	,ISNULL(stc1.Name,'') as SalesTrackingCode1Name
	,ISNULL(stc2.Code,'') as BillingEntityCodeCode
	,ISNULL(stc2.Name,'') as BillingEntityCodeName
	,ISNULL(stc3.Code,'') as SalesTrackingCode3Code
	,ISNULL(stc3.Name,'') as SalesTrackingCode3Name
	,ISNULL(stc4.Code,'') as SalesTrackingCode4Code
	,ISNULL(stc4.Name,'') as SalesTrackingCode4Name
	,ISNULL(stc5.Code,'') as GSTTaxCodeCode
	,ISNULL(stc5.Name,'') as GSTTaxCodeName
	,cu.IsoName as Currency
	,dct.Amount as ChargeAmount
	,ISNULL(ddt.Amount,0) as DiscountAmount
	,ISNULL(dtt.Amount,0) as TaxAmount
	,ISNULL(tr.Percentage,0) * 100 as TaxRate
FROM Invoice di
INNER JOIN InvoiceCustomer ic ON di.Id = ic.InvoiceId
INNER JOIN CustomerReference cr ON cr.Id = di.CustomerId
LEFT JOIN SalesTrackingCode stc1 ON stc1.Id = cr.SalesTrackingCode1Id
LEFT JOIN SalesTrackingCode stc2 ON stc2.Id = cr.SalesTrackingCode2Id
LEFT JOIN SalesTrackingCode stc3 ON stc3.Id = cr.SalesTrackingCode3Id
LEFT JOIN SalesTrackingCode stc4 ON stc4.Id = cr.SalesTrackingCode4Id
LEFT JOIN SalesTrackingCode stc5 ON stc5.Id = cr.SalesTrackingCode5Id
INNER JOIN Lookup.Currency cu ON cu.Id = ic.CurrencyId
INNER JOIN Charge dc ON di.Id = dc.InvoiceId
INNER JOIN [Transaction] dct ON dct.Id = dc.Id
LEFT JOIN Discount dd ON dc.Id = dd.ChargeId
LEFT JOIN [Transaction] ddt ON ddt.Id = dd.Id
LEFT JOIN Tax dt ON dc.Id = dt.ChargeId
LEFT JOIN [Transaction] dtt ON dtt.Id = dt.Id
LEFT JOIN TaxRule tr ON tr.Id = dt.TaxRuleId
WHERE
	di.AccountId = @AccountId
	AND di.EffectiveTimestamp >= @StartDate
	AND di.EffectiveTimestamp < @EndDate
)
INSERT INTO @results
SELECT
	EffectiveTimestamp
	,TransactionType
	,Number
	,CompanyName
	,SalesTrackingCode1Code
	,SalesTrackingCode1Name
	,BillingEntityCodeCode
	,BillingEntityCodeName
	,SalesTrackingCode3Code
	,SalesTrackingCode3Name
	,SalesTrackingCode4Code
	,SalesTrackingCode4Name
	,GSTTaxCodeCode
	,GSTTaxCodeName
	,AVG(TaxRate) as GSTRate
	,Currency
	,SUM(ChargeAmount) as InvoiceAmount
	,SUM(DiscountAmount) as InvoiceDiscountAmount
	,SUM(ChargeAmount) - SUM(DiscountAmount) as SubTotal
	,SUM(TaxAmount) as InvoiceTaxAmount
	,SUM(ChargeAmount) - SUM(DiscountAmount) + SUM(TaxAmount) as Total
FROM InvoiceDetails
GROUP BY 
	EffectiveTimestamp
	,TransactionType
	,Number
	,CompanyName
	,SalesTrackingCode1Code
	,SalesTrackingCode1Name
	,BillingEntityCodeCode
	,BillingEntityCodeName
	,SalesTrackingCode3Code
	,SalesTrackingCode3Name
	,SalesTrackingCode4Code
	,SalesTrackingCode4Name
	,GSTTaxCodeCode
	,GSTTaxCodeName
	,Currency


;WITH CreditNoteDetails AS(
SELECT
	dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,@TimezoneId) as EffectiveTimestamp
	,'Credit Note' as TransactionType
	,ISNULL(rc.Reference,CONVERT(nvarchar,rc.CreditNoteId)) as Number
	,ISNULL(ic.CompanyName,'') as CompanyName
	,ISNULL(stc1.Code,'') as SalesTrackingCode1Code
	,ISNULL(stc1.Name,'') as SalesTrackingCode1Name
	,ISNULL(stc2.Code,'') as BillingEntityCodeCode
	,ISNULL(stc2.Name,'') as BillingEntityCodeName
	,ISNULL(stc3.Code,'') as SalesTrackingCode3Code
	,ISNULL(stc3.Name,'') as SalesTrackingCode3Name
	,ISNULL(stc4.Code,'') as SalesTrackingCode4Code
	,ISNULL(stc4.Name,'') as SalesTrackingCode4Name
	,ISNULL(stc5.Code,'') as GSTTaxCodeCode
	,ISNULL(stc5.Name,'') as GSTTaxCodeName
	,cu.IsoName as Currency
	,-t.Amount as ReverseAmount
	,-ISNULL(rdt.Amount,0) as DiscountAmount
	,-ISNULL(rtt.Amount,0) as TaxAmount
	,ISNULL(tr.Percentage,0) * 100 as TaxRate
FROM ReverseCharge rc
INNER JOIN [Transaction] t ON t.Id = rc.Id
INNER JOIN Charge ch ON ch.Id = rc.OriginalChargeId
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
INNER JOIN InvoiceCustomer ic ON i.Id = ic.InvoiceId
INNER JOIN CustomerReference cr ON cr.Id = i.CustomerId
LEFT JOIN SalesTrackingCode stc1 ON stc1.Id = cr.SalesTrackingCode1Id
LEFT JOIN SalesTrackingCode stc2 ON stc2.Id = cr.SalesTrackingCode2Id
LEFT JOIN SalesTrackingCode stc3 ON stc3.Id = cr.SalesTrackingCode3Id
LEFT JOIN SalesTrackingCode stc4 ON stc4.Id = cr.SalesTrackingCode4Id
LEFT JOIN SalesTrackingCode stc5 ON stc5.Id = cr.SalesTrackingCode5Id
INNER JOIN Lookup.Currency cu ON cu.Id = ic.CurrencyId
LEFT JOIN ReverseDiscount rd ON rc.Id = rd.ReverseChargeId
LEFT JOIN [Transaction] rdt ON rd.Id = rdt.Id
LEFT JOIN ReverseTax rt ON rc.Id = rt.ReverseChargeId
LEFT JOIN [Transaction] rtt ON rt.Id = rtt.Id
LEFT JOIN Tax tx ON tx.Id = rt.OriginalTaxId
LEFT JOIN TaxRule tr ON tr.Id = tx.TaxRuleId
WHERE
	i.AccountId = @AccountId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
)
INSERT INTO @results
SELECT
	EffectiveTimestamp
	,TransactionType
	,Number
	,CompanyName
	,SalesTrackingCode1Code
	,SalesTrackingCode1Name
	,BillingEntityCodeCode
	,BillingEntityCodeName
	,SalesTrackingCode3Code
	,SalesTrackingCode3Name
	,SalesTrackingCode4Code
	,SalesTrackingCode4Name
	,GSTTaxCodeCode
	,GSTTaxCodeName
	,MAX(TaxRate) as GSTRate
	,Currency
	,SUM(ReverseAmount) as InvoiceAmount
	,SUM(DiscountAmount) as InvoiceDiscountAmount
	,SUM(ReverseAmount) - SUM(DiscountAmount) as SubTotal
	,SUM(TaxAmount) as InvoiceTaxAmount
	,SUM(ReverseAmount) - SUM(DiscountAmount) + SUM(TaxAmount) as Total
FROM CreditNoteDetails
GROUP BY 
	EffectiveTimestamp
	,TransactionType
	,Number
	,CompanyName
	,SalesTrackingCode1Code
	,SalesTrackingCode1Name
	,BillingEntityCodeCode
	,BillingEntityCodeName
	,SalesTrackingCode3Code
	,SalesTrackingCode3Name
	,SalesTrackingCode4Code
	,SalesTrackingCode4Name
	,GSTTaxCodeCode
	,GSTTaxCodeName
	,Currency


SELECT
	EffectiveTimestamp as Date
	,TransactionType as [Transaction Type]
	,Number as [No.]
	,CompanyName as Name
	,SalesTrackingCode1Code as [Sales Tracking Code1-Code]
	,SalesTrackingCode1Name as [Sales Tracking Code1-Name]
	,BillingEntityCodeCode as [Billing Entity-Code]
	,BillingEntityCodeName as [Billing Entity-Name]
	,SalesTrackingCode3Code as [Sales Tracking Code3-Code]
	,SalesTrackingCode3Name as [Sales Tracking Code3-Name]
	,SalesTrackingCode4Code as [Sales Tracking Code4-Code]
	,SalesTrackingCode4Name as [Sales Tracking Code4-Name]
	,GSTTaxCodeCode as [GST Tax Code-Code]
	,GSTTaxCodeName as [GST Tax Code-Name]
	,GSTRate as [GST Rate]
	,Currency
	,InvoiceAmount as [Amount before Discounts]
	,SumOfDiscounts as [Discount Amount]
	,SubTotal as [Amount before GST]
	,SumOfTaxes as [GST Amount]
	,NetTotal as [Amount after GST]
FROM @results

END

GO

