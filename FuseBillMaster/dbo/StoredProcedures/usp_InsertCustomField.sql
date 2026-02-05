 
 
CREATE PROC [dbo].[usp_InsertCustomField]

	@AccountId bigint,
	@FriendlyName varchar(255),
	@Key varchar(255),
	@DataTypeId int,
	@StatusId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomField] (
		[AccountId],
		[FriendlyName],
		[Key],
		[DataTypeId],
		[StatusId],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@AccountId,
		@FriendlyName,
		@Key,
		@DataTypeId,
		@StatusId,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

