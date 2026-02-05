CREATE PROC [dbo].[usp_UpdatePrice]

	@Id bigint,
	@QuantityRangeId bigint,
	@Amount decimal,
	@CurrencyId bigint
AS
SET NOCOUNT ON
	UPDATE [Price] SET 
		[QuantityRangeId] = @QuantityRangeId,
		[Amount] = @Amount,
		[CurrencyId] = @CurrencyId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

