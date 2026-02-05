CREATE PROCEDURE [dbo].[usp_GetFullPaymentActivities]
	@Ids nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @paymentActivities table
	(
		PaymentActivityId bigint
	)
    DECLARE @invoices table
	(
		InvoiceId bigint
	)

	INSERT INTO @paymentActivities (PaymentActivityId)
	SELECT Data FROM dbo.Split (@Ids,'|')

	INSERT INTO @invoices
	SELECT i.Id FROM Invoice i
	INNER JOIN PaymentNote pn ON i.Id = pn.InvoiceId
	INNER JOIN Payment p ON p.Id = pn.PaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId
	UNION
	SELECT i.Id
	FROM Invoice i
	INNER JOIN RefundNote rn ON i.Id = rn.InvoiceId
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = r.PaymentActivityJournalId
	UNION
	SELECT i.Id
	FROM Invoice i
	INNER JOIN RefundNote rn ON i.Id = rn.InvoiceId
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	SELECT paj.*
		, paj.PaymentActivityStatusId as PaymentActivityStatus
		, paj.PaymentMethodTypeId as PaymentMethodType
		, paj.PaymentSourceId as PaymentSource
		, paj.PaymentTypeId as PaymentType
		, paj.SettlementStatusId as SettlementStatus
		, paj.DisputeStatusId as DisputeStatus
	FROM PaymentActivityJournal paj
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id

	SELECT p.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	SELECT pn.*
	FROM PaymentNote pn
	INNER JOIN Payment p ON p.Id = pn.PaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	-- Get all refunds for payment activities
	SELECT r.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = r.PaymentActivityJournalId
	UNION
	-- Get all refunds for payments
	SELECT r.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
	INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	-- Get all refund notes for payment activities
	SELECT rn.*
	FROM RefundNote rn
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = r.PaymentActivityJournalId
	UNION
	-- Get all refund notes for payments
	SELECT rn.*
	FROM RefundNote rn
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	SELECT i.*
	FROM Invoice i
	INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

	SELECT ij.*
	FROM InvoiceJournal ij 
	INNER JOIN Invoice i ON i.Id = ij.InvoiceId AND ij.IsActive = 1
	INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

	SELECT cc.*
		, pm.*
		, pm.PaymentMethodStatusId as PaymentMethodStatus
		, pm.PaymentMethodTypeId as PaymentMethodType
	FROM CreditCard cc
	INNER JOIN PaymentMethod pm ON pm.Id = cc.Id
	INNER JOIN PaymentActivityJournal paj ON cc.Id = paj.PaymentMethodId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id

	SELECT ach.*
		, pm.*
		, pm.PaymentMethodStatusId as PaymentMethodStatus
		, pm.PaymentMethodTypeId as PaymentMethodType
	FROM AchCard ach
	INNER JOIN PaymentMethod pm ON pm.Id = ach.Id
	INNER JOIN PaymentActivityJournal paj ON ach.Id = paj.PaymentMethodId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id
	END

GO

