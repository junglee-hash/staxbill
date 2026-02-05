CREATE PROC [dbo].[usp_InsertCustomerEmailPreference]

	@CustomerId bigint,
	@EmailType int,
	@Enabled bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EmailCategoryId int
AS
SET NOCOUNT ON
	INSERT INTO [CustomerEmailPreference] (
		[CustomerId],
		[EmailType],
		[Enabled],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[EmailCategoryId]
	)
	VALUES (
		@CustomerId,
		@EmailType,
		@Enabled,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@EmailCategoryId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

