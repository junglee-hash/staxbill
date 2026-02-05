-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFullDebitsForSyncToQuickBooks]
	@debitIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @debits table (
	DebitId bigint
	)

	INSERT INTO @debits (DebitId)
	select Data from dbo.Split (@debitIds,'|')

	SELECT d.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Debit d
	INNER JOIN [Transaction] t ON t.Id = d.Id
	INNER JOIN @debits dd ON dd.DebitId = d.Id

	SELECT da.*
	FROM DebitAllocation da
	INNER JOIN @debits dd ON dd.DebitId = da.DebitId

	SELECT c.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Debit d
	INNER JOIN Credit c ON c.Id = d.OriginalCreditId
	INNER JOIN [Transaction] t ON t.Id = c.Id
	INNER JOIN @debits dd ON dd.DebitId = d.Id

	SELECT ca.*
	FROM Debit d
	INNER JOIN Credit c ON c.Id = d.OriginalCreditId
	INNER JOIN CreditAllocation ca ON c.Id = ca.CreditId
	INNER JOIN @debits dd ON dd.DebitId = d.Id

	SELECT i.*
	FROM Debit d
	INNER JOIN Credit c ON c.Id = d.OriginalCreditId
	INNER JOIN CreditAllocation ca ON c.Id = ca.CreditId
	INNER JOIN Invoice i ON i.Id = ca.InvoiceId
	INNER JOIN @debits dd ON dd.DebitId = d.Id

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	FROM Customer c
	INNER JOIN [Transaction] t ON c.Id = t.CustomerId
	INNER JOIN @debits dd ON dd.DebitId = t.Id
END

GO

