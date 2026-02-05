
CREATE   PROCEDURE [dbo].[usp_UnlatchCustomerFromSageIntacct]
	@CustomerId bigint = null,
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Wipe out SageIntacctID on reverse charges
	UPDATE rc SET 
		rc.SageIntacctId = null,
		rc.SageIntacctAttemptNumber = 0
	FROM ReverseCharge rc
	INNER JOIN [Transaction] t ON t.Id = rc.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacctID on debits
	UPDATE d SET 
		d.SageIntacctId = null,
		d.SageIntacctAttemptNumber = 0
	FROM Debit d
	INNER JOIN [Transaction] t ON t.Id = d.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacct Sync Status on credit allocations
	UPDATE ca SET
		ca.SageIntacctId = null,
		ca.SageIntacctAttemptNumber = 0
	FROM CreditAllocation ca
	INNER JOIN [Transaction] t ON t.Id = ca.CreditId
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacctID on credits
	UPDATE c SET 
		c.SageIntacctId = null,
		c.SageIntacctAttemptNumber = 0
	FROM Credit c
	INNER JOIN [Transaction] t ON t.Id = c.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacctID on write offs
	UPDATE w SET 
		w.SageIntacctId = null,
		w.SageIntacctAttemptNumber = 0
	FROM WriteOff w
	INNER JOIN [Transaction] t ON t.Id = w.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacctID on refunds
	UPDATE r SET 
		r.SageIntacctId = null,
		r.SageIntacctAttemptNumber = 0
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacct Sync Status on payment notes
	UPDATE pn SET 
		pn.SageIntacctId = null,
		pn.SageIntacctAttemptNumber = 0
	FROM PaymentNote pn
	INNER JOIN [Transaction] t ON t.Id = pn.PaymentId
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacctID on payments
	UPDATE p SET 
		p.SageIntacctId = null,
		p.SageIntacctAttemptNumber = 0
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
		AND t.CustomerId = ISNULL(@CustomerId, t.CustomerId)
		AND t.AccountId = @AccountId

	-- Wipe out SageIntacctID on invoices
	UPDATE Invoice SET
		SageIntacctId = null,
		SageIntacctAttemptNumber = 0
	WHERE CustomerId = ISNULL(@CustomerId, CustomerId)
		AND AccountId = @AccountId

	-- Wipe out SageIntacct information on customer
    UPDATE Customer SET
		SageIntacctId = null
		, SageIntacctCustomerId = null
		, SageIntacctLatchTypeId = null
		, SageIntacctSyncTimestamp = null
	WHERE Id = ISNULL(@CustomerId, Id)
		AND AccountId = @AccountId
END

GO

