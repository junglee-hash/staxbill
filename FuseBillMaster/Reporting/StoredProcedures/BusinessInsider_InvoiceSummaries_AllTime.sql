
CREATE PROCEDURE [Reporting].[BusinessInsider_InvoiceSummaries_AllTime]
--DECLARE
	@AccountId BIGINT 
AS
BEGIN

set nocount on
set transaction isolation level snapshot

DECLARE @TimezoneId BIGINT

SELECT @TimezoneId = TimezoneId
FROM AccountPreference
WHERE Id = @AccountId

SELECT
	i.CustomerId as FusebillId
	,ISNULL(c.Reference,'') as CustomerId
	,ISNULL(c.FirstName,'') as FirstName
	,ISNULL(c.LastName,'') as LastName
	,ISNULL(c.CompanyName,'') as CompanyName
	,i.InvoiceNumber
	,dbo.fn_GetTimezoneTime(i.PostedTimestamp, @TimezoneId) as PostedTimestamp
	,ij.SumOfCharges
	,ij.SumOfDiscounts
	,ij.SumOfCharges - ij.SumOfDiscounts as SubTotal
	,ij.SumOfTaxes
	,ij.SumOfCharges - ij.SumOfDiscounts + ij.SumOfTaxes as Total
	,ij.SumOfCreditNotes
	,ins.Name as [Invoice Status]
FROM InvoiceJournal ij
INNER JOIN Invoice i ON i.Id = ij.InvoiceId
INNER JOIN InvoiceCustomer c ON i.Id = c.InvoiceId
INNER JOIN PaymentSchedule AS PS ON PS.InvoiceId = i.Id 
INNER JOIN PaymentScheduleJournal AS PSJ ON PSJ.PaymentScheduleId = PS.Id AND PSJ.IsActive = 1
INNER JOIN Lookup.InvoiceStatus ins on ins.Id = PSJ.StatusId
WHERE i.AccountId = @AccountId
	AND ij.IsActive = 1
ORDER BY i.CustomerId

END

GO

