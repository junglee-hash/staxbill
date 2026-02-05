CREATE PROC [dbo].[usp_DeleteAccountNetsuiteFieldMapping]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountNetsuiteFieldMapping]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

