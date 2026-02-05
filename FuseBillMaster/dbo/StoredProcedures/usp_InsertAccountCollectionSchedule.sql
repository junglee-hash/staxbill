 
 
CREATE PROC [dbo].[usp_InsertAccountCollectionSchedule]

	@AccountId bigint,
	@Day int
AS
SET NOCOUNT ON
	INSERT INTO [AccountCollectionSchedule] (
		[AccountId],
		[Day]
	)
	VALUES (
		@AccountId,
		@Day
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

