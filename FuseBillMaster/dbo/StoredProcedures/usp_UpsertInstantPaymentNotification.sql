CREATE PROCEDURE [dbo].[usp_UpsertInstantPaymentNotification]
	@Raw varchar(500),
	@CallbackTypeId int,
	@CustomerId bigint = null,
	@ReconciliationId uniqueidentifier = null,
	@AccountId bigint = null,
	@WePayUserId bigint = null
	
	
AS
BEGIN
	SET NOCOUNT ON;

		MERGE [dbo].[InstantPaymentNotification] WITH (HOLDLOCK) as [target]
		USING (SELECT @CustomerId as CustomerId,
					  @ReconciliationId as ReconciliationId,
					  @CallbackTypeId as CallbackTypeId,
					  @AccountId as AccountId,
					  @WePayUserId as WePayUserId) AS [source]
		ON 
			[source].CallbackTypeId = [target].CallbackTypeId
			AND ISNULL([source].CustomerId, 0) = ISNULL([target].CustomerId, 0)
			AND ISNULL([source].ReconciliationId, '00000000-0000-0000-0000-000000000000') = ISNULL([target].ReconciliationId, '00000000-0000-0000-0000-000000000000')
			AND ISNULL([source].AccountId, 0) = ISNULL([target].AccountId, 0)
			AND ISNULL([source].WePayUserId, 0) = ISNULL([target].WePayUserId, 0)
			And [target].Consumed = 0
		WHEN MATCHED THEN
			UPDATE SET 
				[target].MostRecentIPNTimestamp = GETUTCDATE()
		WHEN NOT MATCHED THEN
			INSERT (
				CustomerId
				, ReconciliationId
				, AccountId
				, WePayUserId
				, CallbackTypeId
				, FirstIPNTimestamp
				, MostRecentIPNTimestamp
				, [Raw]
			) VALUES (
				@CustomerId
				, @ReconciliationId
				, @AccountId
				, @WePayUserId
				, @CallbackTypeId
				, GETUTCDATE()
				, GETUTCDATE()
				, @Raw
			);
END

GO

