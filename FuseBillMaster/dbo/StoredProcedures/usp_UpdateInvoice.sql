CREATE      PROCEDURE [dbo].[usp_UpdateInvoice]
	@Id as bigint, 
	@SageIntacctId bigint = null,
	@SageIntacctAttemptNumber int,
	@QuickBooksId bigint = null,
	@QuickBooksAttemptNumber int,
	@TermId int,
	@NetsuiteId nvarchar(255),
	@ErpNetsuiteId nvarchar(255),
	@SalesforceId nvarchar(255),
	@PoNumber varchar(255),
	@Notes nvarchar(4000),
	@HideOnSSP BIT,
	@NumberOfInstallments int,
	@SumOfCharges money,
	@SumOfPayments money,
	@SumOfRefunds money,
	@SumOfCreditNotes money,
	@SumOfWriteOffs money,
	@OutstandingBalance money,
	@LastJournalTimestamp datetime,
	@SumOfTaxes money,
	@SumOfDiscounts money,
	@DatePaid datetime,
	@ReferenceDate datetime,
	@TaxesCommitted BIT,
	@AnrokPartialTransactionId UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Invoice SET
		SageIntacctId = @SageIntacctId,
		SageIntacctAttemptNumber = @SageIntacctAttemptNumber,
		QuickBooksId = @QuickBooksId,
		QuickBooksAttemptNumber = @QuickBooksAttemptNumber,
		TermId = @TermId,
		NetsuiteId = @NetsuiteId,
		ErpNetsuiteId = @ErpNetsuiteId,
		SalesforceId = @SalesforceId,
		PoNumber = @PoNumber,
		Notes = @Notes,
		HideOnSSP = @HideOnSSP,
		NumberOfInstallments = @NumberOfInstallments,
		SumOfCharges = @SumOfCharges,
		SumOfPayments = @SumOfPayments,
		SumOfRefunds = @SumOfRefunds,
		SumOfCreditNotes = @SumOfCreditNotes,
		SumOfWriteOffs = @SumOfWriteOffs,
		OutstandingBalance = @OutstandingBalance,
		LastJournalTimestamp = @LastJournalTimestamp,
		SumOfTaxes = @SumOfTaxes,
		SumOfDiscounts = @SumOfDiscounts,
		DatePaid = @DatePaid,
		ReferenceDate = @ReferenceDate,
		TaxesCommitted = @TaxesCommitted,
		AnrokPartialTransactionId = @AnrokPartialTransactionId
	WHERE Id = @Id
END

GO

