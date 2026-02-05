CREATE PROC [dbo].[usp_DeleteAccountPreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountPreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

