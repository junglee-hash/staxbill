CREATE PROC [dbo].[usp_UpdateIntegrationSynchBatch]

	@Id bigint,
	@ExternalBatchId nvarchar(255),
	@IntegrationSynchJobId bigint,
	@StatusId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@RecordsToProcess int,
	@LastPolledTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [IntegrationSynchBatch] SET 
		[ExternalBatchId] = @ExternalBatchId,
		[IntegrationSynchJobId] = @IntegrationSynchJobId,
		[StatusId] = @StatusId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[RecordsToProcess] = @RecordsToProcess,
		[LastPolledTimestamp] = @LastPolledTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

