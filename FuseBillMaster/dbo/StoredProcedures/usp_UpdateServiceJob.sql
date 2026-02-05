CREATE PROC [dbo].[usp_UpdateServiceJob]

	@Id bigint,
	@AccountId bigint,
	@TypeId int,
	@StatusId int,
	@StartTimestamp datetime,
	@CompletedTimestamp datetime,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [ServiceJob] SET 
		[AccountId] = @AccountId,
		[TypeId] = @TypeId,
		[StatusId] = @StatusId,
		[StartTimestamp] = @StartTimestamp,
		[CompletedTimestamp] = @CompletedTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

