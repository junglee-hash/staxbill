CREATE PROC [dbo].[usp_DeleteAvalaraLog]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AvalaraLog]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

