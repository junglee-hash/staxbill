CREATE PROC [dbo].[usp_DeleteCustomerEmailLogBillingStatement]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerEmailLogBillingStatement]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

