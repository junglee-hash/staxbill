 
 
CREATE PROC [dbo].[usp_InsertDraftSubscriptionProductCharge]

	@Id bigint,
	@SubscriptionProductId bigint,
	@StartServiceDate datetime,
	@EndServiceDate datetime,
	@BillingPeriodId bigint,
	@StartServiceDateLabel datetime,
	@EndServiceDateLabel datetime
AS
SET NOCOUNT ON
	INSERT INTO [DraftSubscriptionProductCharge] (
		[Id],
		[SubscriptionProductId],
		[StartServiceDate],
		[EndServiceDate],
		[BillingPeriodId],
		[StartServiceDateLabel],
		[EndServiceDateLabel]
	)
	VALUES (
		@Id,
		@SubscriptionProductId,
		@StartServiceDate,
		@EndServiceDate,
		@BillingPeriodId,
		@StartServiceDateLabel,
		@EndServiceDateLabel
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

