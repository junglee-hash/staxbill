CREATE PROC [dbo].[usp_UpdateIntegrationSynchBatchRecord]

	@Id bigint,
	@IntegrationSynchBatchId bigint,
	@EntityTypeId int,
	@EntityId bigint,
	@ExternalId nvarchar(255),
	@StatusId int,
	@FailureReason nvarchar(Max)
AS
SET NOCOUNT ON
	UPDATE [IntegrationSynchBatchRecord] SET 
		[IntegrationSynchBatchId] = @IntegrationSynchBatchId,
		[EntityTypeId] = @EntityTypeId,
		[EntityId] = @EntityId,
		[ExternalId] = @ExternalId,
		[StatusId] = @StatusId,
		[FailureReason] = @FailureReason
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

