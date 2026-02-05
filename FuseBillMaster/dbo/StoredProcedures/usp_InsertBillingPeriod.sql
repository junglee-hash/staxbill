
CREATE    PROC [dbo].[usp_InsertBillingPeriod]

	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@CustomerId bigint,
	@StartDate datetime,
	@EndDate datetime,
	@PeriodStatusId int,
	@BillingPeriodDefinitionId bigint,
	@RechargeDate datetime
AS
SET NOCOUNT ON
	--always want to push subscriptions to DW when the BPs update:
	UPDATE dbo.Subscription
		SET ModifiedTimestamp = GETUTCDATE()
	WHERE BillingPeriodDefinitionId = @BillingPeriodDefinitionId

	INSERT INTO [BillingPeriod] (
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[CustomerId],
		[StartDate],
		[EndDate],
		[PeriodStatusId],
		[BillingPeriodDefinitionId],
		[RechargeDate]
	)
	VALUES (
		@CreatedTimestamp,
		--ModifiedTimestamp is used for the DW push, so rely on database time rather than provided time. 
		 --Causes less delay between the modified timestamp and the DB write,   
		 --and makes it less likely that the sliding SSIS window will miss the entity:
		GETUTCDATE(),
		@CustomerId,
		@StartDate,
		@EndDate,
		@PeriodStatusId,
		@BillingPeriodDefinitionId,
		@RechargeDate
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

