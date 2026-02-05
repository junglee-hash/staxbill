 
 
CREATE PROC [dbo].[usp_InsertSystemEmailTemplate]

	@MarkDownBody nvarchar(Max),
	@MarkDownSubject nvarchar(255),
	@FromEmail varchar(255),
	@ReplyToEmail varchar(255),
	@FromDisplay varchar(255),
	@ReplyToDisplay varchar(255),
	@BccEmail varchar(255),
	@TypeId int
AS
SET NOCOUNT ON
	INSERT INTO [SystemEmailTemplate] (
		[MarkDownBody],
		[MarkDownSubject],
		[FromEmail],
		[ReplyToEmail],
		[FromDisplay],
		[ReplyToDisplay],
		[BccEmail],
		[TypeId]
	)
	VALUES (
		@MarkDownBody,
		@MarkDownSubject,
		@FromEmail,
		@ReplyToEmail,
		@FromDisplay,
		@ReplyToDisplay,
		@BccEmail,
		@TypeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

