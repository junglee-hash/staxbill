CREATE PROC [dbo].[usp_DeleteCustomerInvoiceSetting]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerInvoiceSetting]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

