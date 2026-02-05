 
 
CREATE PROC [dbo].[usp_InsertIntegrationSynchBatch]

	@ExternalBatchId nvarchar(255),
	@IntegrationSynchJobId bigint,
	@StatusId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@RecordsToProcess int,
	@LastPolledTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [IntegrationSynchBatch] (
		[ExternalBatchId],
		[IntegrationSynchJobId],
		[StatusId],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[RecordsToProcess],
		[LastPolledTimestamp]
	)
	VALUES (
		@ExternalBatchId,
		@IntegrationSynchJobId,
		@StatusId,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@RecordsToProcess,
		@LastPolledTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

