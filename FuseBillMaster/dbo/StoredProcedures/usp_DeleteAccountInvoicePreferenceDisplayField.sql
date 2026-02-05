CREATE PROC [dbo].[usp_DeleteAccountInvoicePreferenceDisplayField]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountInvoicePreferenceDisplayField]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

