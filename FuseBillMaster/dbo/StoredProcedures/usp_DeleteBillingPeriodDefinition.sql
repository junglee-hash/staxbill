CREATE PROC [dbo].[usp_DeleteBillingPeriodDefinition]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [BillingPeriodDefinition]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

