CREATE PROC [dbo].[usp_UpdateCustomField]

	@Id bigint,
	@AccountId bigint,
	@FriendlyName varchar(255),
	@Key varchar(255),
	@DataTypeId int,
	@StatusId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomField] SET 
		[AccountId] = @AccountId,
		[FriendlyName] = @FriendlyName,
		[Key] = @Key,
		[DataTypeId] = @DataTypeId,
		[StatusId] = @StatusId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

