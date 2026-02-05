CREATE PROC [dbo].[usp_UpdateCustomerEmailLog]

	@Id bigint,
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
	UPDATE [CustomerEmailLog] SET 
		[CustomerId] = @CustomerId,
		[Subject] = @Subject,
		[Body] = @Body,
		[AttachmentIncluded] = @AttachmentIncluded,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ToEmail] = @ToEmail,
		[BccEmail] = @BccEmail,
		[ToDisplayName] = @ToDisplayName,
		[BccDisplayName] = @BccDisplayName,
		[FromEmail] = @FromEmail,
		[FromDisplayName] = @FromDisplayName,
		[StatusId] = @StatusId,
		[Result] = @Result
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

