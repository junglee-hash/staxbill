CREATE   procedure [dbo].[usp_InsertAccountInvoicePreferenceDisplayField]

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
	INSERT INTO [AccountInvoicePreferenceDisplayField] (
		[Id],
		[OpeningBalance],
		[ClosingBalance],
		[InvoiceNumber],
		[InvoiceAmount],
		[PostedDate],
		[DueDate],
		[Terms],
		[OutstandingBalance],
		[Status],
		[PoNumber],
		[ChildTitle],
		[ChildSubtotal],
		[ChildDiscounts],
		[ChildTaxes],
		[ChildTotal],
		[ChildDetails],
		[TaxPercentage],
		[ReferenceDate]
	)
	VALUES (
		@Id,
		@OpeningBalance,
		@ClosingBalance,
		@InvoiceNumber,
		@InvoiceAmount,
		@PostedDate,
		@DueDate,
		@Terms,
		@OutstandingBalance,
		@Status,
		@PoNumber,
		@ChildTitle,
		@ChildSubtotal,
		@ChildDiscounts,
		@ChildTaxes,
		@ChildTotal,
		@ChildDetails,
		@TaxPercentage,
		@ReferenceDate
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

