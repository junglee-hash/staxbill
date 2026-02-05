CREATE   procedure [dbo].[usp_UpdateAccountInvoicePreferenceDisplayField]

	@Id bigint,
	@OpeningBalance bit,
	@ClosingBalance bit,
	@InvoiceNumber bit,
	@InvoiceAmount bit,
	@PostedDate bit,
	@DueDate bit,
	@Terms bit,
	@OutstandingBalance bit,
	@Status bit,
	@PoNumber bit,
	@ChildTitle bit,
	@ChildSubtotal bit,
	@ChildDiscounts bit,
	@ChildTaxes bit,
	@ChildTotal bit,
	@ChildDetails bit,
	@TaxPercentage bit,
	@ReferenceDate bit
AS
SET NOCOUNT ON
	UPDATE [AccountInvoicePreferenceDisplayField] SET 
		[OpeningBalance] = @OpeningBalance,
		[ClosingBalance] = @ClosingBalance,
		[InvoiceNumber] = @InvoiceNumber,
		[InvoiceAmount] = @InvoiceAmount,
		[PostedDate] = @PostedDate,
		[DueDate] = @DueDate,
		[Terms] = @Terms,
		[OutstandingBalance] = @OutstandingBalance,
		[Status] = @Status,
		[PoNumber] = @PoNumber,
		[ChildTitle] = @ChildTitle,
		[ChildSubtotal] = @ChildSubtotal,
		[ChildDiscounts] = @ChildDiscounts,
		[ChildTaxes] = @ChildTaxes,
		[ChildTotal] = @ChildTotal,
		[ChildDetails] = @ChildDetails,
		[TaxPercentage] = @TaxPercentage,
		[ReferenceDate] = @ReferenceDate
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

