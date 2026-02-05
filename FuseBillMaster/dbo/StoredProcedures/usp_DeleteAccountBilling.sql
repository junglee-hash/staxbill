CREATE PROC [dbo].[usp_DeleteAccountBilling]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountBilling]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

