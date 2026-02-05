CREATE PROC [dbo].[usp_UpdateAccountNetsuiteFieldMapping]

	@Id bigint,
	@AccountId bigint,
	@NetsuiteEntityTypeId int,
	@NetsuiteFieldId int,
	@NetsuiteCustomField nvarchar(255),
	@FusebillFieldId int,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [AccountNetsuiteFieldMapping] SET 
		[AccountId] = @AccountId,
		[NetsuiteEntityTypeId] = @NetsuiteEntityTypeId,
		[NetsuiteFieldId] = @NetsuiteFieldId,
		[NetsuiteCustomField] = @NetsuiteCustomField,
		[FusebillFieldId] = @FusebillFieldId,
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

