 
 
CREATE PROC [dbo].[usp_InsertServiceJob]

	@AccountId bigint,
	@TypeId int,
	@StatusId int,
	@StartTimestamp datetime,
	@CompletedTimestamp datetime,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [ServiceJob] (
		[AccountId],
		[TypeId],
		[StatusId],
		[StartTimestamp],
		[CompletedTimestamp],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@AccountId,
		@TypeId,
		@StatusId,
		@StartTimestamp,
		@CompletedTimestamp,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

