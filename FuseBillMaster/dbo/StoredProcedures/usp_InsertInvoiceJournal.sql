 
 
CREATE PROC [dbo].[usp_InsertInvoiceJournal]

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
	INSERT INTO [InvoiceJournal] (
		[InvoiceId],
		[SumOfCharges],
		[SumOfPayments],
		[SumOfRefunds],
		[SumOfCreditNotes],
		[SumOfWriteOffs],
		[OutstandingBalance],
		[CreatedTimestamp],
		[SumOfTaxes],
		[SumOfDiscounts],
		[IsActive]
	)
	VALUES (
		@InvoiceId,
		@SumOfCharges,
		@SumOfPayments,
		@SumOfRefunds,
		@SumOfCreditNotes,
		@SumOfWriteOffs,
		@OutstandingBalance,
		@CreatedTimestamp,
		@SumOfTaxes,
		@SumOfDiscounts,
		@IsActive
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

