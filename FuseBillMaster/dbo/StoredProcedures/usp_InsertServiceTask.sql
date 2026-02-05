 
 
CREATE PROC [dbo].[usp_InsertServiceTask]

	@JobId bigint,
	@EntityId bigint,
	@EntityTypeId int,
	@StatusId int,
	@Notes varchar(255),
	@CompletedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [ServiceTask] (
		[JobId],
		[EntityId],
		[EntityTypeId],
		[StatusId],
		[Notes],
		[CompletedTimestamp]
	)
	VALUES (
		@JobId,
		@EntityId,
		@EntityTypeId,
		@StatusId,
		@Notes,
		@CompletedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

