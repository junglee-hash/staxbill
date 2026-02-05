CREATE PROC [dbo].[usp_UpdateCollectionScheduleActivity]

	@Id bigint,
	@DayAttempted int,
	@CreatedTimestamp datetime,
	@CustomerId bigint
AS
SET NOCOUNT ON
	UPDATE [CollectionScheduleActivity] SET 
		[DayAttempted] = @DayAttempted,
		[CreatedTimestamp] = @CreatedTimestamp,
		[CustomerId] = @CustomerId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

