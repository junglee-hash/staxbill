 
 
CREATE PROC [dbo].[usp_InsertAccountNetsuiteFieldMapping]

	@AccountId bigint,
	@NetsuiteEntityTypeId int,
	@NetsuiteFieldId int,
	@NetsuiteCustomField nvarchar(255),
	@FusebillFieldId int,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [AccountNetsuiteFieldMapping] (
		[AccountId],
		[NetsuiteEntityTypeId],
		[NetsuiteFieldId],
		[NetsuiteCustomField],
		[FusebillFieldId],
		[CreatedTimestamp]
	)
	VALUES (
		@AccountId,
		@NetsuiteEntityTypeId,
		@NetsuiteFieldId,
		@NetsuiteCustomField,
		@FusebillFieldId,
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

