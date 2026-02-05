CREATE   PROC [dbo].[usp_InsertChargeLastEarning]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EarningId bigint,
	@EarningCompletedTimestamp datetime,
	@NextEarningTimestamp datetime,
	@AccountId bigint
AS
SET NOCOUNT ON
	INSERT INTO [ChargeLastEarning] (
		[Id],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[EarningId],
		[EarningCompletedTimestamp],
		[NextEarningTimestamp],
		[AccountId]
	)
	VALUES (
		@Id,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@EarningId,
		@EarningCompletedTimestamp,
		@NextEarningTimestamp,
		@AccountId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

