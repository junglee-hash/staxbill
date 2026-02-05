CREATE PROC [dbo].[usp_UpdateAccountCollectionSchedule]

	@Id bigint,
	@AccountId bigint,
	@Day int
AS
SET NOCOUNT ON
	UPDATE [AccountCollectionSchedule] SET 
		[AccountId] = @AccountId,
		[Day] = @Day
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

