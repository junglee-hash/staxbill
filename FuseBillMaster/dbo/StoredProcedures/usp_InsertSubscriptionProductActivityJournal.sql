 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductActivityJournal]

	@SubscriptionProductId bigint,
	@CreatedTimestamp datetime,
	@DeltaQuantity decimal,
	@TotalQuantity decimal,
	@Prorated bit,
	@Description nvarchar(1000),
	@HasCompleted bit,
	@EndOfPeriodCharge bit,
	@EndOfPeriodDate datetime,
	@TargetDay int,
	@UseCreatedTimestamp bit
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductActivityJournal] (
		[SubscriptionProductId],
		[CreatedTimestamp],
		[DeltaQuantity],
		[TotalQuantity],
		[Prorated],
		[Description],
		[HasCompleted],
		[EndOfPeriodCharge],
		[EndOfPeriodDate],
		[TargetDay],
		[UseCreatedTimestamp]
	)
	VALUES (
		@SubscriptionProductId,
		@CreatedTimestamp,
		@DeltaQuantity,
		@TotalQuantity,
		@Prorated,
		@Description,
		@HasCompleted,
		@EndOfPeriodCharge,
		@EndOfPeriodDate,
		@TargetDay,
		@UseCreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

