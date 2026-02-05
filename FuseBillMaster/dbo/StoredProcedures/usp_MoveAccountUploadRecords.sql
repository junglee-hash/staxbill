
CREATE PROCEDURE [dbo].[usp_MoveAccountUploadRecords]
	@ExistingAccountUploadId bigint,
	@NewAccountUploadId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE AccountUploadRecord
		SET AccountUploadId = @NewAccountUploadId
	WHERE AccountUploadId = @ExistingAccountUploadId
		AND AccountUploadRecordStatusId = 2 -- Passed validation
END

GO

