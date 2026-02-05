CREATE PROC [dbo].[usp_UpdateServiceTask]

	@Id bigint,
	@JobId bigint,
	@EntityId bigint,
	@EntityTypeId int,
	@StatusId int,
	@Notes varchar(255),
	@CompletedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [ServiceTask] SET 
		[JobId] = @JobId,
		[EntityId] = @EntityId,
		[EntityTypeId] = @EntityTypeId,
		[StatusId] = @StatusId,
		[Notes] = @Notes,
		[CompletedTimestamp] = @CompletedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

