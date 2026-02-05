CREATE PROC [dbo].[usp_DeleteCreditCard]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CreditCard]
WHERE [Id] = @Id

EXEC usp_DeletePaymentMethod
	@Id

SET NOCOUNT OFF

GO

