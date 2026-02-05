-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFullCreditsForSyncToQuickBooks]
	@creditIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @credits table (
	CreditId bigint
	)

	INSERT INTO @credits (CreditId)
	select Data from dbo.Split (@creditIds,'|')

	SELECT c.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Credit c
	INNER JOIN [Transaction] t ON t.Id = c.Id
	INNER JOIN @credits cc ON cc.CreditId = c.Id

	SELECT ca.*
	FROM CreditAllocation ca
	INNER JOIN @credits cc ON cc.CreditId = ca.CreditId

	SELECT i.*
	FROM Invoice i
	INNER JOIN CreditAllocation ca ON i.Id = ca.InvoiceId
	INNER JOIN @credits cc ON cc.CreditId = ca.CreditId

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
	INNER JOIN @credits cc ON cc.CreditId = t.Id
END

GO

