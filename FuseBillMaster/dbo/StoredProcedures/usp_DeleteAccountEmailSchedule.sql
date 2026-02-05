CREATE PROC [dbo].[usp_DeleteAccountEmailSchedule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountEmailSchedule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

