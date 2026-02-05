CREATE PROC [dbo].[usp_DeletePaymentNote]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PaymentNote]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

