
CREATE PROCEDURE [dbo].[usp_GetFilteredSubscriptionCount]
@AccountId bigint,
@Plans IDList readonly,
@Statuses IDList readonly,
@Frequencies PlanFrequencySplitTableType readonly
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = 
		'
	SELECT COUNT(*)
	FROM Subscription s
	INNER JOIN @Plans p ON p.Id = s.PlanId'

	IF ((SELECT COUNT(*) FROM @Statuses) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Statuses st ON st.Id = s.StatusId'
	END

	IF ((SELECT COUNT(*) FROM @Frequencies) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Frequencies f ON f.Interval = s.IntervalId
		AND f.NumberOfIntervals = s.NumberOfIntervals'
	END

	SET @SQL = @SQL  +  '
	INNER JOIN Customer c ON c.Id = s.CustomerId
		AND c.AccountId = @AccountId
		AND c.IsDeleted = 0
	WHERE s.IsDeleted = 0'
	 
	--PRINT(@SQL)
		
	EXEC sp_executesql @SQL ,N'@AccountId BIGINT,@Plans IDList readonly,@Statuses IDList readonly,@Frequencies PlanFrequencySplitTableType readonly'
	,@AccountId,@Plans,@Statuses,@Frequencies
END

GO

