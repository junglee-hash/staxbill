-- =============================================
-- Author:		Drew Gascoigne
-- Create date: 2023-01-17
-- Description:	New sproc to pull out all overdue invoices for a given customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetOverdueInvoicesForCustomer]
@CustomerId bigint,
@AccountId bigint
AS
BEGIN
	Select Distinct
		i.id
	from Invoice i (nolock) 
	INNER JOIN PaymentSchedule ps (nolock)ON i.Id = ps.InvoiceId
	INNER JOIN PaymentScheduleJournal psj (nolock) ON ps.Id = psj.PaymentScheduleId AND psj.StatusId = 3 AND psj.IsActive = 1  
	where 
		i.AccountId = @AccountId and i.CustomerId = @customerId
END

GO

