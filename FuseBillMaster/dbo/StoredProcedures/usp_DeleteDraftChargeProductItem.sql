CREATE PROC [dbo].[usp_DeleteDraftChargeProductItem]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftChargeProductItem]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

