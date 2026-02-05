CREATE PROC [dbo].[usp_DeleteAchCard]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AchCard]
WHERE [Id] = @Id

EXEC usp_DeletePaymentMethod
	@Id

SET NOCOUNT OFF

GO

