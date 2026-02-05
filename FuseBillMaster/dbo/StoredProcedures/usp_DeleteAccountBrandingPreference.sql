CREATE PROC [dbo].[usp_DeleteAccountBrandingPreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountBrandingPreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

