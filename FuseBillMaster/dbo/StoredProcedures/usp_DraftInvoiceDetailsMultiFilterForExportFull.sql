CREATE   PROCEDURE [dbo].[usp_DraftInvoiceDetailsMultiFilterForExportFull]   
 --DECLARE  
 @AccountId bigint,   
 @draftInvoiceIds AS [dbo].[IdListSorted] ReadOnly   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
Declare @TimezoneId int  
  
select @TimezoneId = ad.TimezoneId   
from AccountPreference ad   
where ad.Id = @AccountId  
  
SELECT * INTO #CustomerData  
FROM dbo.FullCustomerDataByAccount(@AccountId, null, GETUTCDATE())  

--Calculate taxes per charge  
;WITH DraftInvoiceSumOfTaxes  
AS (  
 Select dc.Id, Sum(dt.Amount) as Amount from DraftTax dt  
 inner join DraftCharge dc on dc.Id = dt.DraftChargeId  
 inner join @draftInvoiceIds di on di.Id = dt.DraftInvoiceId  
 group by dc.Id  
)  
--calculate discount per charge  
, DraftInvoiceSumOfDiscounts  
AS (  
 Select dc.id, Sum(dd.Amount) as Amount from DraftDiscount dd  
 inner join DraftCharge dc on dc.Id = dd.DraftChargeId  
 inner join @draftInvoiceIds di on di.Id = dc.DraftInvoiceId  
 group by dc.Id  
),
--Draft invoice posted/due dates and terms  
DraftInvoiceDetails  
AS (    
 Select   
  di.id,  
  di.EffectiveTimestamp as PostingDate,  
	CASE  
		WHEN tm.[Name] like 'Net%' THEN dbo.fn_GetTimezoneTime(DATEADD(day, tm.DaysOffset, di.EffectiveTimestamp), @TimezoneId)  --when net terms calculate the date simply by adding date offset  
		WHEN tm.[Name] like 'Day%' THEN   --when day of month calculate date   
		Case	
			WHEN tm.DaysOffset >= DAY(dbo.fn_GetTimezoneTime(di.EffectiveTimestamp, @TimezoneId)) then
				case
					when tm.DaysOffSet <= Day(EOMONTH(di.EffectiveTimestamp))
						then DateFromParts(
							Year(dbo.fn_GetTimezoneTime(di.EffectiveTimestamp, @TimezoneId)), 
							Month(dbo.fn_GetTimezoneTime(di.EffectiveTimestamp, @TimezoneId)), 
							tm.DaysOffset)   --then use this month with daysoffset for day
					else
						DateFromParts(
							Year(dbo.fn_GetTimezoneTime(di.EffectiveTimestamp, @TimezoneId)), 
							Month(dbo.fn_GetTimezoneTime(di.EffectiveTimestamp, @TimezoneId)), 
							Day(EOMONTH(di.EffectiveTimestamp)))   --then use this month with calculating last day of the month, need to respect Feb 28, Leap Year of 29, months with 30 and 31 for all different values
				end
			ELSE   
				DateFromParts(
					Year(dbo.fn_GetTimezoneTime(DATEADD(Month, 1, di.EffectiveTimestamp), @TimezoneId)), 
					Month(dbo.fn_GetTimezoneTime(DATEADD(Month, 1, di.EffectiveTimestamp), @TimezoneId)), 
					tm.DaysOffset)	--move the month forward by 1, then use that date to create the datetime with the date offset  
		END  
		WHEN tm.[Name] like 'MFI%'   --When month following invoice  
			THEN datefromparts(
				Year(dbo.fn_GetTimezoneTime(DATEADD(Month, 1, di.EffectiveTimestamp), @TimezoneId)), 
				Month(dbo.fn_GetTimezoneTime(DATEADD(Month, 1, di.EffectiveTimestamp), @TimezoneId)), 1)	--then move the month to the next month, and set the date to the first
	ELSE 
		null  
	END as DueDate,
  tm.[Name] as TermName,  
  c.id as CustomerId,  
  c.AccountId as AccountId,  
  di.AvalaraId,  
  di.PoNumber,  
  cur.IsoName as Currency,  
  dbo.fn_GetTimezoneTime(bp.StartDate, ap.TimezoneId) AS BillingPeriodStartDate,  
  dbo.fn_GetTimezoneTime(bp.EndDate, ap.TimezoneId)  AS BillingPeriodEndDate,  
  dinvst.Name as Status  
 from DraftInvoice di  
 inner join @draftInvoiceIds dids on dids.Id = di.Id  
 inner join Customer c on c.Id = di.CustomerId  
 inner join CustomerBillingSetting cbs on cbs.Id = c.Id  
 LEFT JOIN dbo.BillingPeriod bp ON di.BillingPeriodId = bp.Id and bp.PeriodStatusId = 1  
 LEFT JOIN dbo.BillingPeriodDefinition bpd on bpd.Id = bp.BillingPeriodDefinitionId  
 LEFT JOIN Lookup.DraftInvoiceStatus dinvst ON di.DraftInvoiceStatusId = dinvst.Id  
 LEFT JOIN Lookup.Currency cur  ON cur.Id = c.CurrencyId  
 INNER JOIN AccountPreference ap ON ap.Id = c.AccountId  
 --Calculate the term.. Use the term on the invoice if exist, if not check the billing period definition for the terms,   
 --if not then use the value from the customer billing setting  
 Inner JOIN Lookup.Term tm ON COALESCE(di.TermId, bpd.termId, cbs.termId) = tm.Id  
)
SELECT
	dc.DraftInvoiceId as [Draft Invoice ID]
	,did.PostingDate as [Estimated Posting Date]
	,cu.IsoName as Currency
	,di.Total as [Draft Invoice Total]
	,dc.Id as [Draft Transaction ID]
	,dc.Name as [Draft Charge Name]
	,dc.Quantity
	,dc.UnitPrice
	,dc.Amount as GrossAmount
	,ISNULL(dd.Amount, 0) as DiscountAmount
	,ISNULL(dt.Amount, 0) as TaxAmount
	,dc.Amount - ISNULL(dd.Amount, 0) + ISNULL(dt.Amount, 0) as NetAmount
	,dspc.StartServiceDateLabel
	,dspc.EndServiceDateLabel
	,eti.Name as EarningTimingInterval
	,ett.Name as EarningTimingType
	,dspc.SubscriptionProductId
	,ISNULL(spo.Name,sp.PlanProductName) as SubscriptionProductName
	,ISNULL(spo.Description,sp.PlanProductDescription) as SubscriptionProductDescription
	,sp.PlanProductName
	,sp.PlanProductCode
	,sp.PlanProductDescription
	,sp.SubscriptionId
	,ISNULL(so.Name,s.PlanName) as SubscriptionName
	,ISNULL(so.Description,s.PlanDescription) as SubscriptionDescription
	,s.PlanName
	,s.PlanCode
	,s.Reference as SubscriptionReference
	,dpc.PurchaseId
	,pu.Name as PurchaseName
	,pu.Description as PurchaseDescription
	,pr.Name as ProductName
	,pr.Code as ProductCode
	,gl.Name as GLCodeName
	,gl.Code as GLCode
	,cd.*
	,ISNULL(di.PoNumber, '') as [PO Number]
	,FORMAT(di.ReferenceDate, 'MM/dd/yyyy')  as [Invoice Reference Date]
FROM DraftCharge dc
INNER JOIN @draftInvoiceIds dinvList ON dinvList.Id = dc.DraftInvoiceId
INNER JOIN DraftInvoice di ON di.Id = dc.DraftInvoiceId
INNER JOIN #CustomerData cd ON cd.[Fusebill ID] = di.CustomerId
LEFT JOIN DraftInvoiceSumOfDiscounts dd ON dd.Id = dc.Id
LEFT JOIN DraftInvoiceSumOfTaxes dt ON dt.Id = dc.Id
INNER JOIN Customer c ON c.Id = di.CustomerId
INNER JOIN Lookup.Currency cu ON cu.Id = c.CurrencyId
LEFT JOIN DraftSubscriptionProductCharge dspc ON dspc.Id = dc.Id
INNER JOIN Lookup.EarningTimingInterval eti ON eti.Id = dc.EarningTimingIntervalId
INNER JOIN Lookup.EarningTimingType ett oN ett.Id = dc.EarningTimingTypeId
LEFT JOIN SubscriptionProduct sp ON dspc.SubscriptionProductId = sp.Id
LEFT JOIN SubscriptionProductOverride spo ON spo.Id = sp.Id
LEFT JOIN Subscription s ON s.Id = sp.SubscriptionId
LEFT JOIN SubscriptionOverride so ON so.Id = s.Id
LEFT JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
LEFT JOIN Purchase pu ON pu.Id = dpc.PurchaseId
LEFT JOIN Product pr ON pr.Id = ISNULL(sp.ProductId,pu.ProductId)
LEFT JOIN GLCode gl ON gl.Id = pr.GLCodeId
INNER JOIN DraftInvoiceDetails did ON did.Id = di.Id
ORDER BY dinvList.SortOrder ASC, dc.SortOrder ASC

drop table  #CustomerData  

END

GO

