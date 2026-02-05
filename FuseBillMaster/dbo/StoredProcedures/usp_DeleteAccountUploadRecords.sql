
CREATE PROCEDURE [dbo].[usp_DeleteAccountUploadRecords]
	@AccountUploadId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DELETE FROM AccountUploadRecord
	WHERE AccountUploadId = @AccountUploadId;
END

GO

