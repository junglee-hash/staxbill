CREATE PROC [dbo].[usp_UpdateInvoiceJournal]

	@Id bigint,
	@InvoiceId bigint,
	@SumOfCharges money,
	@SumOfPayments money,
	@SumOfRefunds money,
	@SumOfCreditNotes money,
	@SumOfWriteOffs money,
	@OutstandingBalance money,
	@CreatedTimestamp datetime,
	@SumOfTaxes money,
	@SumOfDiscounts money,
	@IsActive bit
AS
SET NOCOUNT ON
	UPDATE [InvoiceJournal] SET 
		[InvoiceId] = @InvoiceId,
		[SumOfCharges] = @SumOfCharges,
		[SumOfPayments] = @SumOfPayments,
		[SumOfRefunds] = @SumOfRefunds,
		[SumOfCreditNotes] = @SumOfCreditNotes,
		[SumOfWriteOffs] = @SumOfWriteOffs,
		[OutstandingBalance] = @OutstandingBalance,
		[CreatedTimestamp] = @CreatedTimestamp,
		[SumOfTaxes] = @SumOfTaxes,
		[SumOfDiscounts] = @SumOfDiscounts,
		[IsActive] = @IsActive
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

