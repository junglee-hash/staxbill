CREATE PROCEDURE [dbo].[usp_InvoicesMultiFilterForExport] 
	--DECLARE
	@AccountId bigint, 
	@invoiceIds AS [dbo].[IdListSorted] ReadOnly 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


Declare
	@TimezoneId int

select @TimezoneId = ad.TimezoneId 
from AccountPreference ad 
where ad.Id = @AccountId



SELECT * INTO #CustomerData
FROM dbo.BasicCustomerDataByAccount(@AccountId)

;WITH UnsettledPayment AS (
	SELECT InvoiceId
	FROM PaymentNote pn
	INNER JOIN Payment p ON p.Id = pn.PaymentId
	INNER JOIN PaymentActivityJournal paj ON paj.Id = p.PaymentActivityJournalId
		AND paj.SettlementStatusId = 2
	GROUP BY InvoiceId
)
    SELECT 
	cd.*
	,CASE WHEN i.TotalInstallments = 1 
		THEN CONVERT(varchar(100), i.[InvoiceNumber]) 
		ELSE CONVERT(varchar(100), CONCAT(i.[InvoiceNumber], '-', ps.[InstallmentNumber])) 
		END as [Invoice Number]
	, i.PoNumber as [PO Number]
	, dbo.fn_GetTimezoneTime(i.[EffectiveTimestamp], ap.TimezoneId) as [Effective Timestamp]
	, dbo.fn_GetTimezoneTime(i.[PostedTimestamp], ap.TimezoneId) as [Posted Timestamp]
	, dbo.fn_GetTimezoneTime(psj.[DueDate], ap.TimezoneId) as [Due Timestamp]
 	, iss.Name as [Status]
	, ISNULL(JR.SumOfCharges - JR.SumOfDiscounts + JR.SumOfTaxes, 0) as [Amount]
	, JR.SumOfCharges
	, JR.SumOfTaxes as [Total Taxes]
	, JR.SumOfDiscounts as [Total Discounts]
	, ISNULL(JR.SumOfPayments - JR.SumOfRefunds, 0) as [Total Payments]
	, JR.SumOfCreditNotes as [Total Credit Notes]
	, ISNULL(JR.SumOfWriteOffs, 0) as [Write offs]
	, PSJ.OutstandingBalance as [Balance]
	, cur.IsoName as Currency
	, Convert(varchar(50),i.AvalaraId) as [Avalara ID]
	, Convert(varchar(50),i.QuickBooksId) as [QuickBooks ID]
	, Convert(varchar(50),i.ErpNetsuiteId) as [Netsuite Id]
	, CONVERT(bit, CASE WHEN up.InvoiceId IS NOT NULL THEN 1 ELSE 0 END) as [Is any payment unsettled?]
	, i.[Id]
	, COALESCE(CONVERT(VARCHAR, FORMAT(dbo.fn_GetTimezoneTime(i.DatePaid, ap.TimezoneId), 'MM/dd/yyyy'), 100), '') as [Date Paid]
	, FORMAT(i.ReferenceDate, 'MM/dd/yyyy') as [Invoice Reference Date]

    FROM @invoiceIds as invList   
		INNER JOIN dbo.Invoice as  i on  invList.Id = i.Id
		INNER JOIN dbo.InvoiceCustomer as c ON i.id = c.InvoiceId
		INNER JOIN dbo.InvoiceJournal AS JR ON i.Id = JR.InvoiceId AND JR.IsActive = 1 
		INNER JOIN dbo.PaymentSchedule AS PS ON PS.InvoiceId = i.Id 
		INNER JOIN dbo.PaymentScheduleJournal AS PSJ ON PSJ.PaymentScheduleId = PS.Id AND PSJ.IsActive = 1 
		INNER JOIN Lookup.Currency cur ON cur.Id = c.CurrencyId
		INNER JOIN Lookup.InvoiceStatus iss ON iss.Id = PSJ.StatusId
		INNER JOIN AccountPreference ap ON ap.Id = i.AccountId
		INNER JOIN #CustomerData cd on cd.[Fusebill ID] = i.CustomerId
		LEFT JOIN UnsettledPayment up ON i.Id = up.InvoiceId
WHERE i.AccountId = @AccountId
order by invList.SortOrder Asc

drop table  #CustomerData

END

GO

