CREATE PROC [dbo].[usp_UpdatePricingModelOverride]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@PricingModelTypeId int
AS
SET NOCOUNT ON
	UPDATE [PricingModelOverride] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[PricingModelTypeId] = @PricingModelTypeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

