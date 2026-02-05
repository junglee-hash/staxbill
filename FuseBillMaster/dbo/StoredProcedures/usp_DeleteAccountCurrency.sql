CREATE PROC [dbo].[usp_DeleteAccountCurrency]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountCurrency]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

