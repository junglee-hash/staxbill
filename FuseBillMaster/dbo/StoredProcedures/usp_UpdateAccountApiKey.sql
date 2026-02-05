
CREATE PROC [dbo].[usp_UpdateAccountApiKey]

	@Id bigint,
	@AccountId bigint,
	@Key nvarchar(255),
	@ApiKeyTypeId int,
	@ApiKeyStatusId int
AS
SET NOCOUNT ON
	UPDATE [AccountApiKey] SET 
		[AccountId] = @AccountId,
		[Key] = @Key,
		[ApiKeyTypeId] = @ApiKeyTypeId,
		[ApiKeyStatusId] = @ApiKeyStatusId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

