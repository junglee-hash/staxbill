CREATE PROC [dbo].[usp_DeleteChargeProductItem]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ChargeProductItem]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

