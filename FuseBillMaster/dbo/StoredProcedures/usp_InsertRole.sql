 
 
CREATE PROC [dbo].[usp_InsertRole]

	@AccountId bigint,
	@ModifiedTimestamp datetime,
	@CreatedTimestamp datetime,
	@Name nvarchar(100),
	@Description nvarchar(255),
	@Locked bit
AS
SET NOCOUNT ON
	INSERT INTO [Role] (
		[AccountId],
		[ModifiedTimestamp],
		[CreatedTimestamp],
		[Name],
		[Description],
		[Locked]
	)
	VALUES (
		@AccountId,
		@ModifiedTimestamp,
		@CreatedTimestamp,
		@Name,
		@Description,
		@Locked
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

