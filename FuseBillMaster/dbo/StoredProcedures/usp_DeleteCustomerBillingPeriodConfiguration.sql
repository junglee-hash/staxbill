CREATE PROC [dbo].[usp_DeleteCustomerBillingPeriodConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerBillingPeriodConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

