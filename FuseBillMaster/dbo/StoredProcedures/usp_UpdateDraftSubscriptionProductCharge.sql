CREATE PROC [dbo].[usp_UpdateDraftSubscriptionProductCharge]

	@Id bigint,
	@SubscriptionProductId bigint,
	@StartServiceDate datetime,
	@EndServiceDate datetime,
	@BillingPeriodId bigint,
	@StartServiceDateLabel datetime,
	@EndServiceDateLabel datetime
AS
SET NOCOUNT ON
	UPDATE [DraftSubscriptionProductCharge] SET 
		[SubscriptionProductId] = @SubscriptionProductId,
		[StartServiceDate] = @StartServiceDate,
		[EndServiceDate] = @EndServiceDate,
		[BillingPeriodId] = @BillingPeriodId,
		[StartServiceDateLabel] = @StartServiceDateLabel,
		[EndServiceDateLabel] = @EndServiceDateLabel
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

