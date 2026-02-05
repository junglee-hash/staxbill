 
 
CREATE PROC [dbo].[usp_InsertGLCode]

	@AccountId bigint,
	@Code nvarchar(255),
	@Name nvarchar(100),
	@StatusId int,
	@Used bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [GLCode] (
		[AccountId],
		[Code],
		[Name],
		[StatusId],
		[Used],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@AccountId,
		@Code,
		@Name,
		@StatusId,
		@Used,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

