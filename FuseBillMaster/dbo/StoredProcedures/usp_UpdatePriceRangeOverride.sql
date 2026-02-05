CREATE PROC [dbo].[usp_UpdatePriceRangeOverride]

	@Id bigint,
	@PricingModelOverrideId bigint,
	@Min decimal,
	@Max decimal,
	@Price decimal
AS
SET NOCOUNT ON
	UPDATE [PriceRangeOverride] SET 
		[PricingModelOverrideId] = @PricingModelOverrideId,
		[Min] = @Min,
		[Max] = @Max,
		[Price] = @Price
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

