CREATE PROC [dbo].[usp_UpdateAccountUploadRecord]

	@Id bigint,
	@AccountUploadId bigint,
	@AccountUploadRecordStatusId tinyint,
	@CreatedTimestamp datetime,
	@Data nvarchar(Max),
	@Details nvarchar(1000),
	@CreatedEntityId bigint
AS
SET NOCOUNT ON
	UPDATE [AccountUploadRecord] SET 
		[AccountUploadId] = @AccountUploadId,
		[AccountUploadRecordStatusId] = @AccountUploadRecordStatusId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[Data] = @Data,
		[Details] = @Details,
		[CreatedEntityId] = @CreatedEntityId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

