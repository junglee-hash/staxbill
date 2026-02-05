CREATE PROC [dbo].[usp_DeleteCreditCardExpiryActivity]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CreditCardExpiryActivity]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

