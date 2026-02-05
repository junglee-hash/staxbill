CREATE   PROCEDURE [dbo].[usp_GetInvoiceSummariesHierarchical]
	@accountId BIGINT,
	@parentId BIGINT,
	@customerIds dbo.IdList READONLY,
	@includeAllChildren BIT,
	@includeAllDescendants BIT,
	@invoiceStatusIds dbo.IdList READONLY,
	@invoiceStatusSet BIT,
	@pageNumber INT,
	@pageSize INT
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	CREATE TABLE #CustomersWithParentIds(
	customerId BIGINT
	,parentId BIGINT
	)

	INSERT INTO #CustomersWithParentIds
	SELECT DISTINCT * FROM (
	--explicitly provided customer Ids
	SELECT
	c.Id AS CustomerId,
	ParentId
	FROM Customer c
	INNER JOIN @customerIds d ON d.Id = c.Id
	--parent's direct children if including all children:
	UNION
	SELECT
	c.Id AS CustomerId,
	ParentId
	FROM Customer c
	WHERE  @includeAllChildren = 1
		AND @includeAllDescendants = 0 --if @includeAllDescendants is 1, we can skip this section of the union because all descendants is a superset of all children
		AND (c.ParentId = @parentId
		OR c.Id = @parentId)
	--parent's descendants if including all descendants:
	UNION 
	SELECT Id AS CustomerId, 
	parentId 
	FROM 
	dbo.AllCustomerDescendants(@parentId)
	WHERE @includeAllDescendants = 1
	) u

	;WITH SettledInvoices AS 
(
	SELECT pn.InvoiceId
    FROM dbo.PaymentNote AS pn 
	INNER JOIN dbo.Payment AS p ON p.Id = pn.PaymentId 
	INNER JOIN dbo.PaymentActivityJournal AS paj ON paj.Id = p.PaymentActivityJournalId AND paj.SettlementStatusId = 2
    GROUP BY pn.InvoiceId
)
	SELECT
		i.Id,
		i.PostedTimestamp,
		ps.DueDate,
		ps.StatusId AS [invoiceStatus],
		i.InvoiceNumber,
		i.OutstandingBalance,
		ps.Amount as PaymentScheduleAmount,
		i.PoNumber,
		COALESCE (i.SumOfCharges - i.SumOfDiscounts + i.SumOfTaxes, 0) AS InvoiceAmount,
		i.CustomerId,
		cp.ParentId as CustomerParentId,
		c.CurrencyId,
		i.SumOfCharges,
		i.EffectiveTimestamp,
		i.LastJournalTimestamp AS ModifiedTimestamp,
		i.QuickBooksAttemptNumber,
		CONVERT(VARCHAR(50), i.QuickBooksId) AS QuickBooksId, 
		CONVERT(VARCHAR(50), i.AvalaraId) AS AvalaraId, 
		COALESCE (CONVERT(BIT, CASE WHEN si.InvoiceId IS NOT NULL THEN 1 ELSE 0 END), NULL) AS Unsettled,
		COALESCE (i.SumOfPayments - i.SumOfRefunds, 0) AS TotalPayments, 
		i.SumOfCreditNotes AS TotalCreditNotes, 
		COALESCE (i.SumOfWriteOffs, 0) AS Writeoffs,
		c.Reference,
		c.CompanyName, 
		Lookup.Title.[Name] as Title,
		c.FirstName, 
		c.MiddleName, 
		c.LastName, 
		c.IsParent AS CustomerIsParent, 
		Lookup.CustomerAccountStatus.[Name] AS AccountingStatus, 
		Lookup.CustomerStatus.[Name] AS CustomerStatus, 
		c.Suffix
	FROM dbo.Invoice i
	INNER JOIN Customer c ON c.Id = i.CustomerId
	INNER JOIN #CustomersWithParentIds cp on cp.customerId = i.customerId
	INNER JOIN dbo.PaymentSchedule ps on ps.InvoiceId = i.Id
	INNER JOIN Lookup.CustomerAccountStatus ON c.AccountStatusId = Lookup.CustomerAccountStatus.Id 
	INNER JOIN Lookup.CustomerStatus ON c.StatusId = Lookup.CustomerStatus.Id 
	LEFT JOIN Lookup.Title ON c.TitleId = Lookup.Title.Id 
	LEFT OUTER JOIN SettledInvoices AS si ON si.InvoiceId = i.Id
	WHERE i.AccountId = @accountId
	AND i.HideOnSSP = 0 --currently this sproc is only used from the SSP
	AND 
		(	ps.StatusId IN (SELECT Id from @invoiceStatusIds) 
			OR @invoiceStatusSet = 0
		)
	ORDER BY i.Id DESC
	OFFSET (@PageNumber * @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY

	SELECT
		Count(1) as [Count]
	FROM dbo.Invoice i
	INNER JOIN #CustomersWithParentIds c on c.customerId = i.customerId
	INNER JOIN dbo.PaymentSchedule ps on ps.InvoiceId = i.Id
	WHERE i.AccountId = @accountId
	AND i.HideOnSSP = 0 --currently this sproc is only used from the SSP
	AND 
		(	ps.StatusId IN (SELECT Id from @invoiceStatusIds) 
			OR @invoiceStatusSet = 0
		)


	DROP TABLE #CustomersWithParentIds

GO

