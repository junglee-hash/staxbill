CREATE PROC [dbo].[usp_UpdateSystemEmailTemplate]

	@Id bigint,
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
	UPDATE [SystemEmailTemplate] SET 
		[MarkDownBody] = @MarkDownBody,
		[MarkDownSubject] = @MarkDownSubject,
		[FromEmail] = @FromEmail,
		[ReplyToEmail] = @ReplyToEmail,
		[FromDisplay] = @FromDisplay,
		[ReplyToDisplay] = @ReplyToDisplay,
		[BccEmail] = @BccEmail,
		[TypeId] = @TypeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

