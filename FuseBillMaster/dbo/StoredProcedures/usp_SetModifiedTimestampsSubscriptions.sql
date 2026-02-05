
CREATE PROCEDURE [dbo].[usp_SetModifiedTimestampsSubscriptions]
	@AccountId BIGINT
AS


DECLARE @BatchSize INT
	,@Rows INT
	,@Iteration INT
	,@IterationLimit INT
	,@StartTime DATETIME
	,@ServiceJobId BIGINT

SET DEADLOCK_PRIORITY LOW;
SET @BatchSize = 10000
SET @Iteration = 0 -- LEAVE THIS
SET @IterationLimit = 1000 -- SET THIS
SET @StartTime = GETUTCDATE()

SET @Rows = @BatchSize; -- initialize just to enter the loop

INSERT INTO [dbo].[ServiceJob]
           ([AccountId]
           ,[TypeId]
           ,[StatusId]
           ,[StartTimestamp]
           ,[CompletedTimestamp]
           ,[CreatedTimestamp]
           ,[ModifiedTimestamp]
           ,[AdditionalData]
           ,[ParentEntityId]
           ,[TotalCount]
           ,[TotalSuccessful]
           ,[TotalFailed]
           ,[IsOffline])
     VALUES
           (@AccountId
           ,9
           ,2 -- In Progress
           ,GETUTCDATE()
           ,NULL
           ,GETUTCDATE()
           ,GETUTCDATE()
           ,'Subscriptions'
           ,NULL
           ,0
           ,0
           ,NULL
           ,0)

SET @ServiceJobId = SCOPE_IDENTITY()

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) s
		SET s.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	WHERE s.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

--Reset loop
SET @Iteration = 0
SET @Rows = @BatchSize;

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) up
		SET up.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	INNER JOIN SubscriptionCustomField up ON s.Id = up.SubscriptionId
	WHERE up.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

--Reset loop
SET @Iteration = 0
SET @Rows = @BatchSize;

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) up
		SET up.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	INNER JOIN SubscriptionProduct up ON s.Id = up.SubscriptionId
	WHERE up.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

--Reset loop
SET @Iteration = 0
SET @Rows = @BatchSize;

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) up
		SET up.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
	INNER JOIN SubscriptionProductCustomField up ON sp.Id = up.SubscriptionProductId
	WHERE up.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

--Reset loop
SET @Iteration = 0
SET @Rows = @BatchSize;

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) up
		SET up.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
	INNER JOIN SubscriptionProductDiscount up ON sp.Id = up.SubscriptionProductId
	WHERE up.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

--Reset loop
SET @Iteration = 0
SET @Rows = @BatchSize;

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) up
		SET up.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
	INNER JOIN SubscriptionProductPriceRange up ON sp.Id = up.SubscriptionProductId
	WHERE up.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

--Reset loop
SET @Iteration = 0
SET @Rows = @BatchSize;

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) up
		SET up.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Subscription s
	INNER JOIN Customer c ON c.Id = s.CustomerId
	INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
	INNER JOIN PricingModelOverride up ON sp.Id = up.Id
	WHERE up.ModifiedTimestamp < @StartTime
	AND c.AccountId = @AccountId

	SET @Rows = @@ROWCOUNT
	SET @Iteration = @Iteration + 1
		
	UPDATE ServiceJob
	SET ModifiedTimestamp = GETUTCDATE()
		,TotalCount = TotalCount + @Rows
		,TotalSuccessful = TotalSuccessful + @Rows
	WHERE Id = @ServiceJobId
END

UPDATE ServiceJob
SET ModifiedTimestamp = GETUTCDATE()
	,CompletedTimestamp = GETUTCDATE()
	,StatusId = 3
WHERE Id = @ServiceJobId

GO

