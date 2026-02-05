CREATE PROC [dbo].[usp_DeleteBillingStatement]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [BillingStatement]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

