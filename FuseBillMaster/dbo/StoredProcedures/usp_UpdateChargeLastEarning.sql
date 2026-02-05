CREATE PROC [dbo].[usp_UpdateChargeLastEarning]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EarningId bigint,
	@EarningCompletedTimestamp datetime,
	@NextEarningTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [ChargeLastEarning] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[EarningId] = @EarningId,
		[EarningCompletedTimestamp] = @EarningCompletedTimestamp,
		[NextEarningTimestamp] = @NextEarningTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

