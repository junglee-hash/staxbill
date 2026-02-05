 
 
CREATE PROC [dbo].[usp_InsertCustomerEmailLog]

	@CustomerId bigint,
	@Subject varchar(255),
	@Body nvarchar(Max),
	@AttachmentIncluded bit,
	@EffectiveTimestamp datetime,
	@CreatedTimestamp datetime,
	@ToEmail varchar(255),
	@BccEmail varchar(255),
	@ToDisplayName varchar(255),
	@BccDisplayName varchar(255),
	@FromEmail varchar(255),
	@FromDisplayName varchar(255),
	@StatusId int,
	@Result nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [CustomerEmailLog] (
		[CustomerId],
		[Subject],
		[Body],
		[AttachmentIncluded],
		[EffectiveTimestamp],
		[CreatedTimestamp],
		[ToEmail],
		[BccEmail],
		[ToDisplayName],
		[BccDisplayName],
		[FromEmail],
		[FromDisplayName],
		[StatusId],
		[Result]
	)
	VALUES (
		@CustomerId,
		@Subject,
		@Body,
		@AttachmentIncluded,
		@EffectiveTimestamp,
		@CreatedTimestamp,
		@ToEmail,
		@BccEmail,
		@ToDisplayName,
		@BccDisplayName,
		@FromEmail,
		@FromDisplayName,
		@StatusId,
		@Result
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

