CREATE PROC [dbo].[usp_UpdateSubscriptionProductActivityJournal]

	@Id bigint,
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
	UPDATE [SubscriptionProductActivityJournal] SET 
		[SubscriptionProductId] = @SubscriptionProductId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[DeltaQuantity] = @DeltaQuantity,
		[TotalQuantity] = @TotalQuantity,
		[Prorated] = @Prorated,
		[Description] = @Description,
		[HasCompleted] = @HasCompleted,
		[EndOfPeriodCharge] = @EndOfPeriodCharge,
		[EndOfPeriodDate] = @EndOfPeriodDate,
		[TargetDay] = @TargetDay,
		[UseCreatedTimestamp] = @UseCreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

