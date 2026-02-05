CREATE PROC [dbo].[usp_DeletePaymentScheduleJournal]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PaymentScheduleJournal]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

