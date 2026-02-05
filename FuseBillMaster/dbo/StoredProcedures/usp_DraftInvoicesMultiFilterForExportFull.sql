CREATE PROCEDURE [dbo].[usp_DraftInvoicesMultiFilterForExportFull]   
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
--Create temporary table to store summarized values  
create table #DraftInvoiceTempTable  
(  
	ID bigint,    
	SortOrder bigint,   
	SumOfCharges decimal(18,6),   
	SumOfDiscounts decimal(18,6),   
	SumOfTaxes decimal(18,6),  
	Amount decimal(18,6),  
	PostingDate DateTime, 
	DueDate DateTime,    
	TermName varchar(50),  
	CustomerId bigint,  
	AccountId bigint,  
	AvalaraId uniqueidentifier null,  
	PoNumber varchar(255) null,
	ReferenceDate DateTime,
	Currency varchar(255) null,  
	BillingPeriodStartDate datetime,  
	BillingPeriodEndDate datetime,  
	[status] varchar(255) null  
);

--Calculate charges per invoice  
WITH DraftInvoiceSumOfCharges  
AS (  
 Select di.Id, Sum(dc.Amount) as Amount from DraftCharge dc  
 inner join @draftInvoiceIds di on di.Id = dc.DraftInvoiceId  
 group by di.Id  
),  
--Calculate taxes per invoice  
DraftInvoiceSumOfTaxes  
AS (  
 Select di.Id, Sum(dt.Amount) as Amount from DraftTax dt  
 inner join @draftInvoiceIds di on di.Id = dt.DraftInvoiceId  
 group by di.Id  
)  
--calculate discount per invoice  
, DraftInvoiceSumOfDiscounts  
AS (  
 Select di.id, Sum(dd.Amount) as Amount from DraftDiscount dd  
 inner join DraftCharge dc on dc.Id = dd.DraftChargeId  
 inner join @draftInvoiceIds di on di.Id = dc.DraftInvoiceId  
 group by di.Id  
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
  di.ReferenceDate,
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

Insert Into #DraftInvoiceTempTable  
Select   
	dids.Id,   
	dids.SortOrder,   
	dcharges.Amount,  
	ddiscounts.Amount,  
	dtaxes.Amount,  
	(IsNull(dcharges.Amount, 0) - IsNull(ddiscounts.Amount,0)) + IsNull(dtaxes.Amount,0) AS Amount,  
	ddata.PostingDate,  
	ddata.DueDate,  
	ddata.TermName,  
	ddata.CustomerId,  
	ddata.AccountId,  
	ddata.AvalaraId,  
	ddata.PoNumber,  
	ddata.ReferenceDate,  
	ddata.Currency,  
	ddata.BillingPeriodStartDate,  
	ddata.BillingPeriodEndDate,  
	ddata.[status]  
from @draftInvoiceIds dids  
	inner join DraftInvoice di on di.Id = dids.Id  
	Left join DraftInvoiceSumOfCharges dcharges on dcharges.Id = dids.Id  
	Left join DraftInvoiceSumOfDiscounts ddiscounts on ddiscounts.Id = dids.Id  
	Left join DraftInvoiceSumOfTaxes dtaxes on dtaxes.Id = dids.Id  
	inner join DraftInvoiceDetails ddata on ddata.Id = dids.Id  

select ditemp.ID as [Draft invoice ID], ditemp.PoNumber as [PO Number], ditemp.BillingPeriodStartDate,ditemp.BillingPeriodEndDate, ditemp.PostingDate as [Estimated Posting Date]  
	, ditemp.DueDate as [Estimated Due Date], ditemp.TermName as [Net Terms], ditemp.status, ditemp.Amount, ditemp.SumOfCharges,   
	ditemp.SumOfTaxes as [Total Taxes],  ditemp.SumOfDiscounts as [Total Discounts],   
	ditemp.Currency,  ditemp.AvalaraId as [Avalara ID], cd.*, FORMAT(ditemp.ReferenceDate, 'MM/dd/yyyy') as [Invoice Reference Date]  
from #CustomerData cd   
	inner join #DraftInvoiceTempTable ditemp on ditemp.customerid = cd.[Fusebill ID]  
	inner join @draftInvoiceIds dinvList on dinvList.id = ditemp.ID  
WHERE ditemp.AccountId = @AccountId  
order by dinvList.SortOrder Asc  
  
drop table  #CustomerData  
Drop Table #DraftInvoiceTempTable

END

GO

