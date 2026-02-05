
CREATE PROCEDURE [dbo].[usp_SetModifiedTimestampsCustomers]
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
           ,'Customers'
           ,NULL
           ,0
           ,0
           ,NULL
           ,0)

SET @ServiceJobId = SCOPE_IDENTITY()

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) c
		SET c.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM Customer c
	WHERE c.ModifiedTimestamp < @StartTime
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
	FROM Customer c
	INNER JOIN CustomerBillingPeriodConfiguration up ON c.Id = up.CustomerBillingSettingId
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
	FROM Customer c
	INNER JOIN CustomerBillingSetting up ON c.Id = up.Id
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
	FROM Customer c
	INNER JOIN CustomerReference up ON c.Id = up.Id
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
	FROM Customer c
	INNER JOIN CustomerIntegration up ON c.Id = up.CustomerId
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
	FROM Customer c
	INNER JOIN CustomerEmailPreference up ON c.Id = up.CustomerId
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

