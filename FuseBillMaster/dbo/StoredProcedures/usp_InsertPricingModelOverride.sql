 
 
CREATE PROC [dbo].[usp_InsertPricingModelOverride]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@PricingModelTypeId int
AS
SET NOCOUNT ON
	INSERT INTO [PricingModelOverride] (
		[Id],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[PricingModelTypeId]
	)
	VALUES (
		@Id,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@PricingModelTypeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

