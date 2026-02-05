CREATE   PROCEDURE [dbo].[usp_GetAccountGridInvoiceSummary]
	@AccountId BIGINT,
	@PageNumber BIGINT,
	@PageSize BIGINT,
	@InvoiceNumber INT = NULL,
	@PoNumber VARCHAR(255) = NULL,
	@CustomerId BIGINT = NULL,
	@Reference VARCHAR(255) = NULL,
	@CustomerParentId BIGINT = NULL,
	@DueDateStart DATETIME = NULL,
	@DueDateEnd DATETIME = NULL,
	@PostedDateStart DATETIME = NULL,
	@PostedDateEnd DATETIME = NULL,
	@InvoiceStatusId BIGINT = NULL,
	@QuickBooksOnlineSynchId BIGINT = NULL,
	@CurrencyId BIGINT = NULL,
	@SortOrder VARCHAR(10) = 'Ascending',
	@SortExpression VARCHAR(20) = 'CustomerId',
	@ReturnJustInvoiceIds BIT = 0,
	@AvalaraId varchar(255) = NULL,
	@InvoiceId bigint = null,
	@DatePaidStart DATETIME = NULL,
	@DatePaidEnd DATETIME = NULL
AS
SET NOCOUNT ON;


SELECT 
DISTINCT InvoiceId 
INTO #InvoicesNotYetSettled
FROM dbo.PaymentNote AS pn 
	INNER JOIN dbo.invoice i on i.Id = pn.InvoiceId
	INNER JOIN dbo.Payment AS p ON p.Id = pn.PaymentId 
	INNER JOIN dbo.PaymentActivityJournal AS paj ON paj.Id = p.PaymentActivityJournalId
WHERE paj.SettlementStatusId = 2 
AND i.AccountId = @AccountId
AND @ReturnJustInvoiceIds = 0 -- we don't filter or sort on this temp table when returning just the invoice IDs, so we can skip filling it
OPTION (RECOMPILE)

Select i.Id AS InvoiceId, ps.Id as PaymentScheduleId into
#UnpaginatedRows
FROM Invoice i
INNER JOIN dbo.PaymentSchedule ps ON ps.InvoiceId = i.Id 
INNER JOIN Customer c on c.Id = i.CustomerId
WHERE i.AccountId = @AccountId
AND (@InvoiceNumber = i.InvoiceNumber
	OR @InvoiceNumber IS NULL)
AND (i.PoNumber LIKE @PoNumber
	OR @PoNumber IS NULL)
AND (i.CustomerId = @CustomerId
	OR @CustomerId IS NULL)
AND (c.ParentId = @CustomerParentId
	OR @CustomerParentId IS NULL)
AND (c.CurrencyId = @CurrencyId
	OR @CurrencyId IS NULL)
AND (c.Reference LIKE @Reference
	OR @Reference IS NULL)
AND (ps.StatusId = @InvoiceStatusId
	OR @InvoiceStatusId IS NULL)
AND (ps.DueDate >= @DueDateStart
	OR @DueDateStart IS NULL)
AND (ps.DueDate < @DueDateEnd
	OR @DueDateEnd IS NULL)
AND (i.PostedTimestamp >= @PostedDateStart
	OR @PostedDateStart IS NULL)
AND (i.PostedTimestamp < @PostedDateEnd
	OR @PostedDateEnd IS NULL)
AND (i.DatePaid >= @DatePaidStart 
	OR @DatePaidStart IS NULL)
AND (i.DatePaid < @DatePaidEnd 
	OR @DatePaidEnd IS NULL)
--Quickbooks:
AND (
	--case 1: Id 1 is 'synched'
	(@QuickBooksOnlineSynchId = 1 AND i.QuickBooksId IS NOT NULL)
	--case 2: Id 2 is 'not tried'
	OR (@QuickBooksOnlineSynchId = 2 AND i.QuickBooksId IS NULL AND i.QuickBooksAttemptNumber = 0)
	--case 3: Id 3 means 'error'
	OR (@QuickBooksOnlineSynchId = 3 AND i.QuickBooksId IS NULL AND i.QuickBooksAttemptNumber > 0)
	--case 4: no QuickBooksOnlineSynchId was provided so filter out nothing:
	OR (@QuickBooksOnlineSynchId IS NULL)
	)
AND (i.AvalaraId = @AvalaraId
	or @AvalaraId is null)
OPTION (RECOMPILE)

DECLARE @SortText NVARCHAR(26)
SET @SortText = CASE @SortExpression
						WHEN 'InvoiceNumber' THEN 'i.InvoiceNumber'  
						WHEN 'CustomerId' THEN 'i.CustomerId'
						WHEN 'CompanyName' THEN 'c.CompanyName'
						WHEN 'FirstName' THEN 'c.FirstName'
						WHEN 'Reference' THEN 'c.reference'
						WHEN 'PostedDate' THEN 'i.PostedTimestamp'
						WHEN 'DatePaid' THEN 'i.DatePaid'
						WHEN 'DueDate' THEN 'ps.DueDate'
						WHEN 'Amount' THEN 'ps.Amount'
						WHEN 'OutstandingBalance' THEN 'ps.OutstandingBalance'
						WHEN 'InvoiceStatus' THEN 'ins.[name]'
						ELSE 'i.InvoiceNumber'
						END
					+ CASE @SortOrder
						WHEN 'Ascending' THEN ' asc'
						WHEN 'Descending' THEN ' desc'
						ELSE ' asc'
						END

DECLARE @sqlText NVARCHAR(3000)
declare @sqlInvoiceId nvarchar(300)

set @sqlInvoiceId = case when @InvoiceId is not null then ' where i.Id = ' +STR(@InvoiceId) else '' end

SET @sqlText = 
	CASE @ReturnJustInvoiceIds 
	WHEN 0 THEN
    'SELECT 
	i.Id,
	c.Id AS CustomerId, 
	c.Reference, 
	lc.IsoName AS CurrencyIso, 
	c.CompanyName, 
	c.PrimaryEmail,
	c.FirstName, 
	c.LastName, 
	c.ParentId AS CustomerParentId,
	c.IsParent AS CustomerIsParent, 
	ps.DueDate AS DueTimestamp, 
	i.PostedTimestamp,
	ps.StatusId AS InvoiceStatus,
	i.InvoiceNumber,
	COALESCE (i.SumOfCharges - i.SumOfDiscounts + i.SumOfTaxes, 0) AS InvoiceAmount, 
	COALESCE (i.SumOfPayments - i.SumOfRefunds, 0) AS TotalPayments,
	i.SumOfCreditNotes AS TotalCreditNotes,
	COALESCE (i.SumOfWriteOffs, 0) AS Writeoffs,
	ps.OutstandingBalance,
	i.QuickBooksId,
	i.AvalaraId,
	i.QuickBooksAttemptNumber,
	CONVERT(BIT,CASE WHEN si.InvoiceId IS NOT NULL THEN 1 ELSE 0 END) AS Unsettled,
	c.AccountStatusId AS AccountingStatus,
	c.StatusId AS CustomerStatus
	FROM #UnpaginatedRows ur
	INNER JOIN Invoice i on ur.InvoiceId = i.Id
	INNER JOIN dbo.Customer AS c ON i.CustomerId = c.Id 
	INNER JOIN lookup.Currency lc on lc.id = c.currencyId
	INNER JOIN dbo.PaymentSchedule AS ps ON ur.PaymentScheduleId = ps.Id 
	INNER JOIN Lookup.InvoiceStatus ins on ins.Id = ps.StatusId
	LEFT OUTER JOIN #InvoicesNotYetSettled AS si ON si.InvoiceId = i.Id ' + @sqlInvoiceId +
	' ORDER BY '
	+ @SortText
	+	' OFFSET (' + STR(@PageNumber) + ' * ' + STR(@PageSize) + ') ROWS
	FETCH NEXT ' + STR(@PageSize) + ' ROWS ONLY 
	OPTION (RECOMPILE)'
	+ 'SELECT count(1) AS [count] from #UnpaginatedRows '
	ELSE
	'SELECT ur.InvoiceId AS Id 
	FROM #UnpaginatedRows ur
	INNER JOIN Invoice i on ur.InvoiceId = i.Id
	INNER JOIN dbo.Customer AS c ON i.CustomerId = c.Id 
	INNER JOIN dbo.PaymentSchedule AS ps ON ur.PaymentScheduleId = ps.Id 
	INNER JOIN Lookup.InvoiceStatus ins on ins.Id = ps.StatusId
	ORDER BY ' + @SortText + '
	OPTION (RECOMPILE)'
	END
	

--PRINT @SqlText

EXECUTE sp_executesql @sqltext 

DROP TABLE #InvoicesNotYetSettled
DROP TABLE #UnpaginatedRows

SET NOCOUNT OFF;

GO

