CREATE PROC [dbo].[usp_UpdateCustomerEmailPreference]

	@Id bigint,
	@CustomerId bigint,
	@EmailType int,
	@Enabled bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EmailCategoryId int
AS
SET NOCOUNT ON
	UPDATE [CustomerEmailPreference] SET 
		[CustomerId] = @CustomerId,
		[EmailType] = @EmailType,
		[Enabled] = @Enabled,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[EmailCategoryId] = @EmailCategoryId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

