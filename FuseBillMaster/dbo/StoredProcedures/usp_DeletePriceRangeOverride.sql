CREATE PROC [dbo].[usp_DeletePriceRangeOverride]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PriceRangeOverride]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

