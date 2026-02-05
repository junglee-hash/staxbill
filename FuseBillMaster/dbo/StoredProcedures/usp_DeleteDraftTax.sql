CREATE PROC [dbo].[usp_DeleteDraftTax]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftTax]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

