CREATE PROC [dbo].[usp_UpdateDraftInvoice]

	@Id bigint,
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
	UPDATE [DraftInvoice] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[BillingPeriodId] = @BillingPeriodId,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[PoNumber] = @PoNumber,
		[Subtotal] = @Subtotal,
		[Total] = @Total,
		[CustomerId] = @CustomerId,
		[DraftInvoiceStatusId] = @DraftInvoiceStatusId,
		[AvalaraId] = @AvalaraId,
		[Notes] = @Notes
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

