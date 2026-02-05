CREATE PROC [dbo].[usp_InsertAccountUpload]

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
	INSERT INTO [AccountUpload] (
		[AccountId],
		[AccountUploadTypeId],
		[AccountUploadStatusId],
		[CreatedTimestamp],
		[CompletedTimestamp],
		[TotalRecords],
		[SuccessfulRecords],
		[FailedRecords],
		[FieldMap],
		[FileName],
		[TotalProcessed],
		[TotalFailedProcessing],
		[ImportingTimestamp],
		[ProcessedTimestamp],
		[Reference],
		[Settings],
		[TotalProcessedRecords],
		[AccountUploadRelatedId]
	)
	VALUES (
		@AccountId,
		@AccountUploadTypeId,
		@AccountUploadStatusId,
		@CreatedTimestamp,
		@CompletedTimestamp,
		@TotalRecords,
		@SuccessfulRecords,
		@FailedRecords,
		@FieldMap,
		@FileName,
		@TotalProcessed,
		@TotalFailedProcessing,
		@ImportingTimestamp,
		@ProcessedTimestamp,
		@Reference,
		@Settings,
		@TotalProcessedRecords,
		@AccountUploadRelatedId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

