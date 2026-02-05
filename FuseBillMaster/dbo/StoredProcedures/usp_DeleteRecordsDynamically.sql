
CREATE PROCEDURE [dbo].[usp_DeleteRecordsDynamically]
	@accountResetId bigint,
	@temporaryAccountId bigint,
	@customers CustomerSplitTableType READONLY,
	@tableName varchar(50),
	@joinSql varchar(2000),
	@tablePrefix varchar(5) = 'c',
	@filterCustomer bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @summaryId bigint
	DECLARE @rowCount int

	DECLARE @sql nvarchar(max)

	SET @sql = N'
	INSERT INTO AccountResetSummary (AccountResetId, EntityName, DatabaseInstanceId, TotalCount, SuccessfulCount, ErrorCount, DeleteStartTimestamp)
		SELECT @accountResetId, ''' + @tableName + ''', 1, COUNT(*), 0, 0, GETUTCDATE()
		FROM ' + QUOTENAME(@tableName) + ' tn 
		' + @joinSql +
		CASE WHEN @filterCustomer = 1 THEN ' LEFT JOIN @customers cc ON cc.CustomerId = ' + @tablePrefix + '.Id'
			ELSE '' END + '
		WHERE ' + @tablePrefix + '.AccountId = @temporaryAccountId ' +
			CASE WHEN @filterCustomer = 1 THEN ' AND cc.CustomerId IS NULL' ELSE '' END

	EXEC sp_executesql @sql, N'@accountResetId bigint, @temporaryAccountId bigint, @tableName varchar(50), @joinSql varchar(2000), @customers CustomerSplitTableType READONLY, @tablePrefix varchar(5), @filterCustomer bit', @accountResetId, @temporaryAccountId, @tableName, @joinSql, @customers, @tablePrefix, @filterCustomer with recompile

	SET @summaryId = @@IDENTITY

	WHILE (1 = 1)
	BEGIN
		BEGIN TRY

			SET @sql = N'
				DELETE TOP(1000) tn
				FROM ' + QUOTENAME(@tableName) + ' tn 
				' + @joinSql + 
				CASE WHEN @filterCustomer = 1 THEN ' LEFT JOIN @customers cc ON cc.CustomerId = ' + @tablePrefix + '.Id'
					ELSE '' END + '
				WHERE ' + @tablePrefix + '.AccountId = @temporaryAccountId ' +
					CASE WHEN @filterCustomer = 1 THEN ' AND cc.CustomerId IS NULL' ELSE '' END
			
			EXEC sp_executesql @sql, N'@temporaryAccountId bigint, @tableName varchar(50), @joinSql varchar(2000), @customers CustomerSplitTableType READONLY, @tablePrefix varchar(5)', @temporaryAccountId, @tableName, @joinSql, @customers, @tablePrefix with recompile

			SET @rowCount = @@ROWCOUNT

			UPDATE AccountResetSummary SET 
				SuccessfulCount += @rowCount
				, DeleteEndTimestamp = CASE WHEN @rowCount = 0 THEN GETUTCDATE() ELSE NULL END
			WHERE Id = @summaryId

			WAITFOR DELAY '00:00:01';
		END TRY

		BEGIN CATCH
			UPDATE AccountResetSummary SET 
				ErrorCount = TotalCount - SuccessfulCount
				, DeleteEndTimestamp = GETUTCDATE()
			WHERE Id = @summaryId

			SET @rowCount = 0

			DECLARE @ErrorMessage NVARCHAR(4000);
			DECLARE @ErrorSeverity INT;
			DECLARE @ErrorState INT;

			SELECT 
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

			RAISERROR 
			(
				@ErrorMessage, -- Message text.
				@ErrorSeverity, -- Severity.
				@ErrorState -- State.
			);
		END CATCH

		IF @rowCount = 0
			BREAK;
	END

END

GO

