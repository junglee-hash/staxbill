 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductOverride]

	@Id bigint,
	@Name nvarchar(100),
	@Description nvarchar(500),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductOverride] (
		[Id],
		[Name],
		[Description],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@Id,
		@Name,
		@Description,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

