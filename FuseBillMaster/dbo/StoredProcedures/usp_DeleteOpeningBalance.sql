CREATE PROC [dbo].[usp_DeleteOpeningBalance]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [OpeningBalance]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

