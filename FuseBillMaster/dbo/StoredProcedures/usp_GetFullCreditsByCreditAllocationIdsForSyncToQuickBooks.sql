-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFullCreditsByCreditAllocationIdsForSyncToQuickBooks]
	@creditAllocationIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @creditAllocations table (
	CreditAllocationId bigint
	)

	declare @credits table (
	CreditId bigint
	)

	INSERT INTO @creditAllocations (CreditAllocationId)
	select Data from dbo.Split (@creditAllocationIds,'|')

	INSERT INTO @credits (CreditId)
	SELECT DISTINCT cr.Id
	FROM Credit cr
	INNER JOIN [Transaction] t ON t.Id = cr.Id
	INNER JOIN CreditAllocation ca ON cr.Id = ca.CreditId
	INNER JOIN @creditAllocations cc ON cc.CreditAllocationId = ca.Id

	SELECT cr.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Credit cr
	INNER JOIN [Transaction] t ON t.Id = cr.Id
	INNER JOIN @credits cc ON cc.CreditId = cr.Id

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

