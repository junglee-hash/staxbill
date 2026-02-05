CREATE PROC [dbo].[usp_DeleteDraftDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftDiscount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

