CREATE PROC [dbo].[usp_DeleteCreditAllocation]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CreditAllocation]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

