 
 
CREATE PROC [dbo].[usp_InsertUserAccessLink]

	@Link nvarchar(Max),
	@UserId bigint,
	@ExpiryTimestamp datetime,
	@IsConsumed bit,
	@PasswordKey nvarchar(Max)
AS
SET NOCOUNT ON
	INSERT INTO [UserAccessLink] (
		[Link],
		[UserId],
		[ExpiryTimestamp],
		[IsConsumed],
		[PasswordKey]
	)
	VALUES (
		@Link,
		@UserId,
		@ExpiryTimestamp,
		@IsConsumed,
		@PasswordKey
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

