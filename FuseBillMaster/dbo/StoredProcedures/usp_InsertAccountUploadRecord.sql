 
 
CREATE PROC [dbo].[usp_InsertAccountUploadRecord]

	@AccountUploadId bigint,
	@AccountUploadRecordStatusId tinyint,
	@CreatedTimestamp datetime,
	@Data nvarchar(Max),
	@Details nvarchar(1000),
	@CreatedEntityId bigint
AS
SET NOCOUNT ON
	INSERT INTO [AccountUploadRecord] (
		[AccountUploadId],
		[AccountUploadRecordStatusId],
		[CreatedTimestamp],
		[Data],
		[Details],
		[CreatedEntityId]
	)
	VALUES (
		@AccountUploadId,
		@AccountUploadRecordStatusId,
		@CreatedTimestamp,
		@Data,
		@Details,
		@CreatedEntityId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

