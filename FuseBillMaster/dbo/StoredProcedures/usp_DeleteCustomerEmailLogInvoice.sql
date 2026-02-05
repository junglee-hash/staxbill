CREATE PROC [dbo].[usp_DeleteCustomerEmailLogInvoice]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerEmailLogInvoice]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

