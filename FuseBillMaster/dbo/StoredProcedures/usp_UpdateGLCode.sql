CREATE PROC [dbo].[usp_UpdateGLCode]

	@Id bigint,
	@AccountId bigint,
	@Code nvarchar(255),
	@Name nvarchar(100),
	@StatusId int,
	@Used bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [GLCode] SET 
		[AccountId] = @AccountId,
		[Code] = @Code,
		[Name] = @Name,
		[StatusId] = @StatusId,
		[Used] = @Used,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

