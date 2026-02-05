CREATE PROC [dbo].[usp_InsertBillingPeriodDefinition]

	@CustomerId bigint,
	@IntervalId int,
	@NumberOfIntervals int,
	@InvoiceDay int,
	@BillingPeriodTypeId int,
	@InvoiceMonth int,
	@ModifiedTimestamp datetime,
	@InvoiceInAdvance tinyint,
	@ManuallyCreated bit
AS
SET NOCOUNT ON
	INSERT INTO [BillingPeriodDefinition] (
		[CustomerId],
		[IntervalId],
		[NumberOfIntervals],
		[InvoiceDay],
		[BillingPeriodTypeId],
		[InvoiceMonth],
		[ModifiedTimestamp],
		[InvoiceInAdvance],
		[ManuallyCreated]
	)
	VALUES (
		@CustomerId,
		@IntervalId,
		@NumberOfIntervals,
		@InvoiceDay,
		@BillingPeriodTypeId,
		@InvoiceMonth,
		@ModifiedTimestamp,
		@InvoiceInAdvance,
		@ManuallyCreated
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

