CREATE PROCEDURE [dbo].[usp_UnlatchCustomerFromQuickBooks]
	@CustomerId bigint = null,
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Wipe out QBID on reverse charges
	UPDATE rc SET 
		rc.QuickBooksId = null,
		rc.QuickBooksAttemptNumber = 0
	FROM ReverseCharge rc
	INNER JOIN [Transaction] t ON t.Id = rc.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QBID on debits
	UPDATE d SET 
		d.QuickBooksId = null,
		d.QuickBooksAttemptNumber = 0
	FROM Debit d
	INNER JOIN [Transaction] t ON t.Id = d.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QB Sync Status on credit allocations
	UPDATE ca SET 
		ca.SyncedToQuickBooks = 0, 
		ca.QuickBooksId = null,
		ca.QuickBooksAttemptNumber = 0
	FROM CreditAllocation ca
	INNER JOIN [Transaction] t ON t.Id = ca.CreditId
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QBID on credits
	UPDATE c SET 
		c.QuickBooksId = null,
		c.QuickBooksAttemptNumber = 0
	FROM Credit c
	INNER JOIN [Transaction] t ON t.Id = c.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QBID on write offs
	UPDATE w SET 
		w.QuickBooksId = null,
		w.QuickBooksAttemptNumber = 0
	FROM WriteOff w
	INNER JOIN [Transaction] t ON t.Id = w.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QBID on refunds
	UPDATE r SET r.QuickBooksId = null, r.QuickBooksAttemptNumber = 0
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QB Sync Status on payment notes
	UPDATE pn SET 
		pn.SyncedToQuickBooks = 0,
		pn.QuickBooksAttemptNumber = 0
	FROM PaymentNote pn
	INNER JOIN [Transaction] t ON t.Id = pn.PaymentId
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QBID on payments
	UPDATE p SET 
		p.QuickBooksId = null,
		p.[QuickBooksAttemptNumber] = 0
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out QBID on invoices
	UPDATE Invoice SET
		QuickBooksId = null,
		[QuickBooksAttemptNumber] = 0
	WHERE CustomerId = ISNULL(@CustomerId, CustomerId)
		AND AccountId = @AccountId

	-- Wipe out QB information on customer
    UPDATE Customer SET
		QuickBooksId = null
		, QuickBooksLatchTypeId = null
		, QuickBooksSyncToken = null
		, QuickBooksSyncTimestamp = null
	WHERE Id = ISNULL(@CustomerId, Id)
		AND AccountId = @AccountId
END

GO

