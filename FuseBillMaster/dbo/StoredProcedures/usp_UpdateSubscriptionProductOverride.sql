CREATE PROC [dbo].[usp_UpdateSubscriptionProductOverride]

	@Id bigint,
	@Name nvarchar(100),
	@Description nvarchar(500),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductOverride] SET 
		[Name] = @Name,
		[Description] = @Description,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

