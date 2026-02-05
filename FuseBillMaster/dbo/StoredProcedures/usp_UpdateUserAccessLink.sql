CREATE PROC [dbo].[usp_UpdateUserAccessLink]

	@Id bigint,
	@Link nvarchar(Max),
	@UserId bigint,
	@ExpiryTimestamp datetime,
	@IsConsumed bit,
	@PasswordKey nvarchar(Max)
AS
SET NOCOUNT ON
	UPDATE [UserAccessLink] SET 
		[Link] = @Link,
		[UserId] = @UserId,
		[ExpiryTimestamp] = @ExpiryTimestamp,
		[IsConsumed] = @IsConsumed,
		[PasswordKey] = @PasswordKey
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

