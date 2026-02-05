CREATE PROCEDURE [dbo].[usp_SetModifiedTimestampsTransactions]
	@AccountId BIGINT,
	@StartDate DATETIME,
	@EndDate DATETIME
AS


DECLARE @BatchSize INT
	,@Rows INT
	,@Iteration INT
	,@IterationLimit INT
	,@ServiceJobId BIGINT
	,@ExecutionTime DATETIME

SET DEADLOCK_PRIORITY LOW;
SET @BatchSize = 10000
SET @Iteration = 0 -- LEAVE THIS
SET @IterationLimit = 1000 -- SET THIS
SET @ExecutionTime = GETUTCDATE()

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
           ,'Transactions'
           ,NULL
           ,0
           ,0
           ,NULL
           ,0)

SET @ServiceJobId = SCOPE_IDENTITY()

WHILE @Iteration < @IterationLimit AND (@Rows = @BatchSize)
BEGIN
	SELECT @Iteration as Iteration, @BatchSize as BatchSize, @Rows as Rows

	UPDATE TOP (@BatchSize) t
		SET t.ModifiedTimestamp = GETUTCDATE()
	--SELECT TOP (@BatchSize) *
	FROM [Transaction] t
	WHERE t.EffectiveTimestamp BETWEEN @StartDate AND @EndDate
		AND t.ModifiedTimestamp < @ExecutionTime
	AND t.AccountId = @AccountId

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

