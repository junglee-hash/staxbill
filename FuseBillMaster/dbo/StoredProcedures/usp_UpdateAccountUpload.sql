CREATE PROC [dbo].[usp_UpdateAccountUpload]

	@Id bigint,
	@AccountId bigint,
	@AccountUploadTypeId tinyint,
	@AccountUploadStatusId tinyint,
	@CreatedTimestamp datetime,
	@CompletedTimestamp datetime,
	@TotalRecords int,
	@SuccessfulRecords int,
	@FailedRecords int,
	@FieldMap nvarchar(Max),
	@FileName nvarchar(255),
	@TotalProcessed int,
	@TotalFailedProcessing int,
	@ImportingTimestamp datetime,
	@ProcessedTimestamp datetime,
	@Reference nvarchar(255),
	@Settings varchar(2000),
	@TotalProcessedRecords int,
	@AccountUploadRelatedId bigint
AS
SET NOCOUNT ON
	UPDATE [AccountUpload] SET 
		[AccountId] = @AccountId,
		[AccountUploadTypeId] = @AccountUploadTypeId,
		[AccountUploadStatusId] = @AccountUploadStatusId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[CompletedTimestamp] = @CompletedTimestamp,
		[TotalRecords] = @TotalRecords,
		[SuccessfulRecords] = @SuccessfulRecords,
		[FailedRecords] = @FailedRecords,
		[FieldMap] = @FieldMap,
		[FileName] = @FileName,
		[TotalProcessed] = @TotalProcessed,
		[TotalFailedProcessing] = @TotalFailedProcessing,
		[ImportingTimestamp] = @ImportingTimestamp,
		[ProcessedTimestamp] = @ProcessedTimestamp,
		[Reference] = @Reference,
		[Settings] = @Settings,
		[TotalProcessedRecords] = @TotalProcessedRecords,
		[AccountUploadRelatedId] = @AccountUploadRelatedId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

