CREATE PROC [dbo].[usp_DeletePaymentActivityJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PaymentActivityJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

