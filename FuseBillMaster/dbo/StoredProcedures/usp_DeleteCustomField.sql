CREATE PROC [dbo].[usp_DeleteCustomField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

