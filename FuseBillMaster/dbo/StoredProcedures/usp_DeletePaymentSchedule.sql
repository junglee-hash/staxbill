CREATE PROC [dbo].[usp_DeletePaymentSchedule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [PaymentSchedule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

