Create PROCEDURE [dbo].[Staffside_InvoiceCollectOptionTriggers]
	@StartDate DATETIME
	,@EndDate DATETIME
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

Select 
	c.AccountId, 
	a.CompanyName, 
	a.ContactEmail, 
	paj.[Trigger], 
	paj.CreatedTimestamp, 
	paj.ReconciliationId, 
	paj.Id as 'Paj Id', 
	pt.[Name] as 'Payment Type'
from PaymentActivityJournal paj
	inner join Customer c on c.id = paj.CustomerId
	inner join Account a on a.id = c.AccountId
	inner join Lookup.PaymentType pt on pt.Id = paj.PaymentTypeId
where 
	paj.CreatedTimestamp > @StartDate 
	and paj.CreatedTimestamp < @EndDate
	and paj.[Trigger] like '%Invoice Collect Option%'
order by paj.id desc

GO

