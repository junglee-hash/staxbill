CREATE PROC [dbo].[usp_DeleteAccountInvoicePreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountInvoicePreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

