CREATE PROC [dbo].[usp_UpdateRole]

	@Id bigint,
	@AccountId bigint,
	@ModifiedTimestamp datetime,
	@CreatedTimestamp datetime,
	@Name nvarchar(100),
	@Description nvarchar(255),
	@Locked bit
AS
SET NOCOUNT ON
	UPDATE [Role] SET 
		[AccountId] = @AccountId,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[Name] = @Name,
		[Description] = @Description,
		[Locked] = @Locked
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

