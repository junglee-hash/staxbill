CREATE PROC [dbo].[usp_DeleteBillingPeriod]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [BillingPeriod]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

