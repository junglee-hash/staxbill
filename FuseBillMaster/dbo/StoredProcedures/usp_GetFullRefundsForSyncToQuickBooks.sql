-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFullRefundsForSyncToQuickBooks]
	@refundIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @refunds table (
	RefundId bigint
	)

	INSERT INTO @refunds (RefundId)
	select Data from dbo.Split (@refundIds,'|')

	SELECT r.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
	INNER JOIN @refunds rr ON rr.RefundId = r.Id

	SELECT rn.*
	FROM RefundNote rn
	INNER JOIN @refunds rr ON rr.RefundId = rn.RefundId

	SELECT p.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	INNER JOIN Refund r ON p.Id = r.OriginalPaymentId
	INNER JOIN @refunds rr ON rr.RefundId = r.Id

	SELECT paj.*
		, paj.PaymentActivityStatusId as PaymentActivityStatus
		, paj.PaymentMethodTypeId as PaymentMethodType
		, paj.PaymentSourceId as PaymentSource
		, paj.PaymentTypeId as PaymentType
		, paj.SettlementStatusId as SettlementStatus
		, paj.DisputeStatusId as DisputeStatus
	FROM PaymentActivityJournal paj
	INNER JOIN Payment p ON paj.Id = p.PaymentActivityJournalId
	INNER JOIN Refund r ON p.Id = r.OriginalPaymentId
	INNER JOIN @refunds rr ON rr.RefundId = r.Id

	SELECT pn.*
	FROM PaymentNote pn
	INNER JOIN Refund r ON pn.PaymentId = r.OriginalPaymentId
	INNER JOIN @refunds rr ON rr.RefundId = r.Id

	SELECT i.*
	FROM Invoice i
	INNER JOIN PaymentNote pn ON i.Id = pn.InvoiceId
	INNER JOIN Refund r ON pn.PaymentId = r.OriginalPaymentId
	INNER JOIN @refunds rr ON rr.RefundId = r.Id

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	FROM Customer c
	INNER JOIN [Transaction] t ON c.Id = t.CustomerId
	INNER JOIN @refunds rr ON rr.RefundId = t.Id
END

GO

