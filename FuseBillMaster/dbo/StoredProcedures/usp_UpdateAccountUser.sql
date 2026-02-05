CREATE PROC [dbo].[usp_UpdateAccountUser]

	@Id bigint,
	@AccountId bigint,
	@UserId bigint,
	@IsEnabled bit
AS
SET NOCOUNT ON
	UPDATE [AccountUser] SET 
		[AccountId] = @AccountId,
		[UserId] = @UserId,
		[IsEnabled] = @IsEnabled
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

