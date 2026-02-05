CREATE PROC [dbo].[usp_UpdateSubscriptionOverride]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Name nvarchar(100),
	@Description nvarchar(500)
AS
SET NOCOUNT ON
	UPDATE [SubscriptionOverride] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Name] = @Name,
		[Description] = @Description
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

