 
 
CREATE PROC [dbo].[usp_InsertIntegrationSynchJob]

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
	INSERT INTO [IntegrationSynchJob] (
		[AccountId],
		[ApiVersion],
		[ExternalJobId],
		[EntityTypeId],
		[StartTimestamp],
		[RequestStatusId],
		[ResponseStatusId],
		[ParentJobId],
		[LastPolledTimestamp],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[Operation],
		[IntegrationTypeId]
	)
	VALUES (
		@AccountId,
		@ApiVersion,
		@ExternalJobId,
		@EntityTypeId,
		@StartTimestamp,
		@RequestStatusId,
		@ResponseStatusId,
		@ParentJobId,
		@LastPolledTimestamp,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@Operation,
		@IntegrationTypeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

