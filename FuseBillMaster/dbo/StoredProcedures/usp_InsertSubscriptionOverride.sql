 
 
CREATE PROC [dbo].[usp_InsertSubscriptionOverride]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Name nvarchar(100),
	@Description nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionOverride] (
		[Id],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[Name],
		[Description]
	)
	VALUES (
		@Id,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@Name,
		@Description
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

