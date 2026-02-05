CREATE PROC [dbo].[usp_UpdateBillingPeriodDefinition]

	@Id bigint,
	@CustomerId bigint,
	@IntervalId int,
	@NumberOfIntervals int,
	@InvoiceDay int,
	@BillingPeriodTypeId int,
	@InvoiceMonth int,
	@ModifiedTimestamp datetime,
	@InvoiceInAdvance tinyint
AS
SET NOCOUNT ON
	UPDATE [BillingPeriodDefinition] SET 
		[CustomerId] = @CustomerId,
		[IntervalId] = @IntervalId,
		[NumberOfIntervals] = @NumberOfIntervals,
		[InvoiceDay] = @InvoiceDay,
		[BillingPeriodTypeId] = @BillingPeriodTypeId,
		[InvoiceMonth] = @InvoiceMonth,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[InvoiceInAdvance] = @InvoiceInAdvance
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

