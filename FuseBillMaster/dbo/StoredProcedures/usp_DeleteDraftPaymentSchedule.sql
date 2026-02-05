CREATE PROC [dbo].[usp_DeleteDraftPaymentSchedule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DraftPaymentSchedule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

