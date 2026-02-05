
CREATE PROCEDURE [dbo].[usp_UpdateRecordsToTemporaryAccount]
	@accountResetId BIGINT,
	@originalAccountId BIGINT,
	@temporaryAccountId BIGINT,
	@customerIdsToExclude VARCHAR(2000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @customers table
	(
	CustomerId bigint
	)
	INSERT INTO @customers (CustomerId)
	select Data from dbo.Split (@customerIdsToExclude,',')

	WHILE (1 = 1)
	BEGIN
		UPDATE TOP(1000) at 
			SET AccountId = @temporaryAccountId
		FROM AuditTrail at
		LEFT JOIN @customers cc ON cc.CustomerId = at.CustomerId
		WHERE AccountId = @originalAccountId
			AND cc.CustomerId IS NULL
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN
		UPDATE TOP(1000) al 
			SET AccountId = @temporaryAccountId
		FROM AvalaraLog al
		LEFT JOIN @customers cc ON cc.CustomerId = al.CustomerId
		WHERE AccountId = @originalAccountId
			AND cc.CustomerId IS NULL
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN
		UPDATE TOP(1000) c
			SET AccountId = @temporaryAccountId
		FROM CustomerCredential c
		LEFT JOIN @customers cc ON cc.CustomerId = c.Id
		WHERE AccountId = @originalAccountId
			AND cc.CustomerId IS NULL
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN	
		UPDATE TOP(1000) Reporting.FactSubscriptionProduct
		SET AccountId = @temporaryAccountId
		WHERE AccountId = @originalAccountId
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN	
		UPDATE TOP(1000) IntegrationSynchJob
		SET AccountId = @temporaryAccountId
		WHERE AccountId = @originalAccountId
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN	
		UPDATE TOP(1000) i
			SET AccountId = @temporaryAccountId
		FROM Invoice i
		LEFT JOIN @customers cc ON cc.CustomerId = i.CustomerId
		WHERE AccountId = @originalAccountId
			AND cc.CustomerId IS NULL
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN	
		UPDATE TOP(1000) QuickBooksLog
		SET AccountId = @temporaryAccountId
		WHERE AccountId = @originalAccountId
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN	
		UPDATE TOP(1000) t
			SET AccountId = @temporaryAccountId
		FROM [Transaction] t
		LEFT JOIN @customers cc ON cc.CustomerId = t.CustomerId
		WHERE AccountId = @originalAccountId
			AND cc.CustomerId IS NULL
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	WHILE (1 = 1)
	BEGIN
		UPDATE TOP(1000) UnknownPaymentJournal
		SET AccountId = @temporaryAccountId
		WHERE AccountId = @originalAccountId
	
		IF @@ROWCOUNT = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	DECLARE @CustomerCount INT = 0
	DECLARE @RowCount INT = 0

	WHILE (1 = 1)
	BEGIN	
		UPDATE TOP(1000) c
			SET AccountId = @temporaryAccountId
		FROM Customer c
		LEFT JOIN @customers cc ON cc.CustomerId = c.Id
		WHERE AccountId = @originalAccountId
			AND cc.CustomerId IS NULL
	
		SET @RowCount = @@ROWCOUNT
		SET @CustomerCount = @CustomerCount + @RowCount

		IF @RowCount = 0
			BREAK;

		WAITFOR DELAY '00:00:01';
	END

	UPDATE AccountReset
	SET CountOfCustomers = @CustomerCount,
		CollectingEndTimestamp = GETUTCDATE(),
		StatusId = 4
	WHERE Id = @accountResetId
END

GO

