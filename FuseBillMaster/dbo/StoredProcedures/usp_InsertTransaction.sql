 
 
CREATE PROC [dbo].[usp_InsertTransaction]

	@CreatedTimestamp datetime,
	@CustomerId bigint,
	@Amount money,
	@EffectiveTimestamp datetime,
	@TransactionTypeId int,
	@Description nvarchar(2000),
	@CurrencyId bigint,
	@SortOrder int
AS
SET NOCOUNT ON
	INSERT INTO [Transaction] (
		[CreatedTimestamp],
		[CustomerId],
		[Amount],
		[EffectiveTimestamp],
		[TransactionTypeId],
		[Description],
		[CurrencyId],
		[SortOrder]
	)
	VALUES (
		@CreatedTimestamp,
		@CustomerId,
		@Amount,
		@EffectiveTimestamp,
		@TransactionTypeId,
		@Description,
		@CurrencyId,
		@SortOrder
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

