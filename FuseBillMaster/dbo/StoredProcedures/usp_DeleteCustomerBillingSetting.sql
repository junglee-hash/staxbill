CREATE PROC [dbo].[usp_DeleteCustomerBillingSetting]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerBillingSetting]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

