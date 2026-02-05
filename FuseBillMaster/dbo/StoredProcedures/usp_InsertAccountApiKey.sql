
CREATE PROC [dbo].[usp_InsertAccountApiKey]

	@AccountId bigint,
	@Key nvarchar(255),
	@ApiKeyTypeId int,
	@ApiKeyStatusId int
AS
SET NOCOUNT ON
	INSERT INTO [AccountApiKey] (
		[AccountId],
		[Key],
		[ApiKeyTypeId],
		[ApiKeyStatusId]
	)
	VALUES (
		@AccountId,
		@Key,
		@ApiKeyTypeId,
		@ApiKeyStatusId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

