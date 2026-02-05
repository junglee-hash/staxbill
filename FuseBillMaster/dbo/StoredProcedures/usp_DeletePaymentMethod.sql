CREATE PROC [dbo].[usp_DeletePaymentMethod]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PaymentMethod]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

