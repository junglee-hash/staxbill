CREATE PROC [dbo].[usp_DeletePricingModelOverride]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PricingModelOverride]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

