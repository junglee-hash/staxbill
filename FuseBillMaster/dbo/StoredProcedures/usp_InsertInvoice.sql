CREATE       procedure [dbo].[usp_InsertInvoice]
	@AccountId bigint
    ,@BillingPeriodId bigint
    ,@DraftInvoiceId bigint
    ,@CreatedTimestamp datetime
    ,@PostedTimestamp datetime
    ,@EffectiveTimestamp datetime
    ,@Signature nvarchar(max)
	,@PoNumber varchar(255)
	,@CustomerId bigint
	,@AvalaraId [uniqueidentifier]
	,@InvoiceCustomerReferenceOption int
	,@Notes nvarchar(4000)
	,@OpeningArBalance money
	,@ClosingArBalance money
	,@TotalInstallments int
	,@TermId int
	,@NetsuiteId nvarchar(255)
	,@DigitalRiverUpstreamId varchar(50)
	,@NumberOfInstallments int
	,@SumOfCharges money
	,@SumOfPayments money
	,@SumOfRefunds money
	,@SumOfCreditNotes money
	,@SumOfWriteOffs money
	,@OutstandingBalance money
	,@LastJournalTimestamp datetime
	,@SumOfTaxes money
	,@SumOfDiscounts money
	,@DatePaid datetime
	,@ReferenceDate datetime
	,@TaxesCommitted BIT
	,@AnrokPartialTransactionId UNIQUEIDENTIFIER
AS

DECLARE @InvoiceNumber int = -2147483647
DECLARE @InvoiceSignatureId bigint = NULL

SET @InvoiceSignatureId = (SELECT TOP 1 Id FROM InvoiceSignature 
	WHERE AccountId = @AccountId AND Signature = @Signature)

IF @InvoiceSignatureId IS NULL
BEGIN

	INSERT INTO InvoiceSignature ([AccountId], [Signature], [CreatedTimestamp], [EffectiveTimestamp], [ModifiedTimestamp])
	VALUES (@AccountId, @Signature, @PostedTimestamp, @PostedTimestamp, GETUTCDATE())

	SET @InvoiceSignatureId = @@IDENTITY

END

INSERT INTO [dbo].[Invoice]
           ([AccountId]
           ,[BillingPeriodId] 
		   ,[InvoiceNumber]
           ,[DraftInvoiceId]
           ,[CreatedTimestamp]
           ,[PostedTimestamp]
           ,[EffectiveTimestamp]
		   ,[PoNumber]
		   ,[CustomerId]
		   ,[AvalaraId]
		   ,[InvoiceCustomerReferenceOption]
		   ,[Notes]
		   ,[OpeningArBalance]
		   ,[ClosingArBalance]
		   ,[TotalInstallments]
		   ,[TermId]
		   ,[NetsuiteId]
		   ,[DigitalRiverUpstreamId]
		   ,[InvoiceSignatureId]
		   ,[NumberOfInstallments]
		   ,[SumOfCharges]
		   ,[SumOfPayments]
		   ,[SumOfRefunds]
		   ,[SumOfCreditNotes]
		   ,[SumOfWriteOffs]
		   ,[OutstandingBalance]
		   ,[LastJournalTimestamp]
		   ,[SumOfTaxes]
		   ,[SumOfDiscounts]
		   ,[DatePaid]
		   ,[ReferenceDate]
		   ,[TaxesCommitted]
		   ,[AnrokPartialTransactionId]
		   )
     VALUES
           (@AccountId
		   ,@BillingPeriodId
           ,@InvoiceNumber
           ,@DraftInvoiceId
           ,@CreatedTimestamp
           ,@PostedTimestamp
           ,@EffectiveTimestamp
		   ,@PoNumber
		   ,@CustomerId
		   ,@AvalaraId
		   ,@InvoiceCustomerReferenceOption
		   ,@Notes
		   ,@OpeningArBalance
		   ,@ClosingArBalance
		   ,@TotalInstallments
		   ,@TermId
		   ,@NetsuiteId
		   ,@DigitalRiverUpstreamId
		   ,@InvoiceSignatureId
		   ,@NumberOfInstallments
		   ,@SumOfCharges
		   ,@SumOfPayments
		   ,@SumOfRefunds
		   ,@SumOfCreditNotes
		   ,@SumOfWriteOffs
		   ,@OutstandingBalance
		   ,@LastJournalTimestamp
		   ,@SumOfTaxes
		   ,@SumOfDiscounts
		   ,@DatePaid
		   ,@ReferenceDate
		   ,@TaxesCommitted
		   ,@AnrokPartialTransactionId
		   )

SELECT 
	SCOPE_IDENTITY() AS Id
	,InvoiceNumber AS InvoiceNumber
FROM Invoice
WHERE Id = SCOPE_IDENTITY()

GO

