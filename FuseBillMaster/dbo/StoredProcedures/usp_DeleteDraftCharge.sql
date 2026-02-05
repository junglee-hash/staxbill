CREATE PROC [dbo].[usp_DeleteDraftCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

