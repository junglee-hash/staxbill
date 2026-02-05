CREATE PROC [dbo].[usp_DeleteAccountEmailTemplate]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountEmailTemplate]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

