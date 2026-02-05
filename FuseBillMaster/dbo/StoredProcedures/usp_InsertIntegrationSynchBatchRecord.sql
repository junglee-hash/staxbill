 
 
CREATE PROC [dbo].[usp_InsertIntegrationSynchBatchRecord]

	@IntegrationSynchBatchId bigint,
	@EntityTypeId int,
	@EntityId bigint,
	@ExternalId nvarchar(255),
	@StatusId int,
	@FailureReason nvarchar(Max)
AS
SET NOCOUNT ON
	INSERT INTO [IntegrationSynchBatchRecord] (
		[IntegrationSynchBatchId],
		[EntityTypeId],
		[EntityId],
		[ExternalId],
		[StatusId],
		[FailureReason]
	)
	VALUES (
		@IntegrationSynchBatchId,
		@EntityTypeId,
		@EntityId,
		@ExternalId,
		@StatusId,
		@FailureReason
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

