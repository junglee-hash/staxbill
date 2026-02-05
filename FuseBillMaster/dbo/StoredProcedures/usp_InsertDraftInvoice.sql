 
 
CREATE PROC [dbo].[usp_InsertDraftInvoice]

	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@BillingPeriodId bigint,
	@EffectiveTimestamp datetime,
	@PoNumber varchar(255),
	@Subtotal decimal,
	@Total decimal,
	@CustomerId bigint,
	@DraftInvoiceStatusId tinyint,
	@AvalaraId uniqueidentifier,
	@Notes nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [DraftInvoice] (
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[BillingPeriodId],
		[EffectiveTimestamp],
		[PoNumber],
		[Subtotal],
		[Total],
		[CustomerId],
		[DraftInvoiceStatusId],
		[AvalaraId],
		[Notes]
	)
	VALUES (
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@BillingPeriodId,
		@EffectiveTimestamp,
		@PoNumber,
		@Subtotal,
		@Total,
		@CustomerId,
		@DraftInvoiceStatusId,
		@AvalaraId,
		@Notes
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

