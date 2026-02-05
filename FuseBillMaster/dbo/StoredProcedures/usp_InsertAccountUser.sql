 
 
CREATE PROC [dbo].[usp_InsertAccountUser]

	@AccountId bigint,
	@UserId bigint,
	@IsEnabled bit
AS
SET NOCOUNT ON
	INSERT INTO [AccountUser] (
		[AccountId],
		[UserId],
		[IsEnabled]
	)
	VALUES (
		@AccountId,
		@UserId,
		@IsEnabled
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

