CREATE PROC [dbo].[usp_UpdateIntegrationSynchJob]

	@Id bigint,
	@AccountId bigint,
	@ApiVersion varchar(10),
	@ExternalJobId nvarchar(255),
	@EntityTypeId int,
	@StartTimestamp datetime,
	@RequestStatusId int,
	@ResponseStatusId int,
	@ParentJobId bigint,
	@LastPolledTimestamp datetime,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Operation varchar(10),
	@IntegrationTypeId int
AS
SET NOCOUNT ON
	UPDATE [IntegrationSynchJob] SET 
		[AccountId] = @AccountId,
		[ApiVersion] = @ApiVersion,
		[ExternalJobId] = @ExternalJobId,
		[EntityTypeId] = @EntityTypeId,
		[StartTimestamp] = @StartTimestamp,
		[RequestStatusId] = @RequestStatusId,
		[ResponseStatusId] = @ResponseStatusId,
		[ParentJobId] = @ParentJobId,
		[LastPolledTimestamp] = @LastPolledTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Operation] = @Operation,
		[IntegrationTypeId] = @IntegrationTypeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

