 
 
CREATE PROC [dbo].[usp_InsertPriceRangeOverride]

	@PricingModelOverrideId bigint,
	@Min decimal,
	@Max decimal,
	@Price decimal
AS
SET NOCOUNT ON
	INSERT INTO [PriceRangeOverride] (
		[PricingModelOverrideId],
		[Min],
		[Max],
		[Price]
	)
	VALUES (
		@PricingModelOverrideId,
		@Min,
		@Max,
		@Price
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

