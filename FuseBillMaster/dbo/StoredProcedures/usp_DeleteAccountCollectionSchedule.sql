CREATE PROC [dbo].[usp_DeleteAccountCollectionSchedule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountCollectionSchedule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

