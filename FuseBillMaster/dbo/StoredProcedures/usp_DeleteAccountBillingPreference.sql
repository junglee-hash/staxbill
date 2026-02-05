CREATE PROC [dbo].[usp_DeleteAccountBillingPreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountBillingPreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

