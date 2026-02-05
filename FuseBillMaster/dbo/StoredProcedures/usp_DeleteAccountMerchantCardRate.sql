Create PROC [dbo].[usp_DeleteAccountMerchantCardRate]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountMerchantCardRate]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

