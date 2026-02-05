 
 
CREATE PROC [dbo].[usp_InsertCollectionScheduleActivity]

	@DayAttempted int,
	@CreatedTimestamp datetime,
	@CustomerId bigint
AS
SET NOCOUNT ON
	INSERT INTO [CollectionScheduleActivity] (
		[DayAttempted],
		[CreatedTimestamp],
		[CustomerId]
	)
	VALUES (
		@DayAttempted,
		@CreatedTimestamp,
		@CustomerId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

