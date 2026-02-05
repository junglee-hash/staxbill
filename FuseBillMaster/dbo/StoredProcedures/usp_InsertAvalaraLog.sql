CREATE     PROC [dbo].[usp_InsertAvalaraLog]

	@AccountId bigint,
	@CustomerId bigint,
	@Input nvarchar(Max),
	@Output nvarchar(Max),
	@FailureReason nvarchar(500),
	@StatusId tinyint,
	@CompletedIn int,
	@CreatedTimestamp datetime,
	@Committed bit,
	@DevMode bit,
	@AccountNumber nvarchar(255),
	@DraftInvoiceId bigint,
	@InvoiceId bigint,
	@TypeId int,
	@DocCode nvarchar(255),
	@AvalaraOrganizationCode nvarchar(255),
	@Compressed bit
AS
SET NOCOUNT ON
	INSERT INTO [AvalaraLog] (
		[AccountId],
		[CustomerId],
		[Input],
		[Output],
		[FailureReason],
		[StatusId],
		[CompletedIn],
		[CreatedTimestamp],
		[Committed],
		[DevMode],
		[AccountNumber],
		[DraftInvoiceId],
		[InvoiceId],
		[TypeId],
		[DocCode],
		[AvalaraOrganizationCode],
		[Compressed]
	)
	VALUES (
		@AccountId,
		@CustomerId,
		@Input,
		@Output,
		@FailureReason,
		@StatusId,
		@CompletedIn,
		@CreatedTimestamp,
		@Committed,
		@DevMode,
		@AccountNumber,
		@DraftInvoiceId,
		@InvoiceId,
		@TypeId,
		@DocCode,
		@AvalaraOrganizationCode,
		@Compressed
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

