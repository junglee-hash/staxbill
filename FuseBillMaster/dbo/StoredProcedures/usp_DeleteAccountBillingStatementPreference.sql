CREATE PROC [dbo].[usp_DeleteAccountBillingStatementPreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountBillingStatementPreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

