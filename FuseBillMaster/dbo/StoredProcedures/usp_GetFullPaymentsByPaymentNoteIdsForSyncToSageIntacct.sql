-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[usp_GetFullPaymentsByPaymentNoteIdsForSyncToSageIntacct]
	@paymentNoteIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @paymentNotes table (
	PaymentNoteId bigint
	)

	declare @payments table (
	PaymentId bigint
	)

	INSERT INTO @paymentNotes (PaymentNoteId)
	select Data from dbo.Split (@paymentNoteIds,'|')

	INSERT INTO @payments (PaymentId)
	SELECT DISTINCT p.Id
	FROM Payment p
	INNER JOIN PaymentNote pn ON p.Id = pn.PaymentId
	INNER JOIN @paymentNotes pp ON pp.PaymentNoteId = pn.Id

	SELECT p.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	INNER JOIN @payments pp ON pp.PaymentId = p.Id

	SELECT pn.*
	FROM PaymentNote pn
	INNER JOIN @payments pp ON pp.PaymentId = pn.PaymentId

	SELECT paj.*
		, paj.PaymentActivityStatusId as PaymentActivityStatus
		, paj.PaymentMethodTypeId as PaymentMethodType
		, paj.PaymentSourceId as PaymentSource
		, paj.PaymentTypeId as PaymentType
		, paj.SettlementStatusId as SettlementStatus
		, paj.DisputeStatusId as DisputeStatus
	FROM PaymentActivityJournal paj
	INNER JOIN Payment p ON paj.Id = p.PaymentActivityJournalId
	INNER JOIN @payments pp ON pp.PaymentId = p.Id

	SELECT i.*
	FROM Invoice i
	INNER JOIN PaymentNote pn ON i.Id = pn.InvoiceId
	INNER JOIN @payments pp ON pp.PaymentId = pn.PaymentId

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SageIntacctLatchTypeId as SageIntacctLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	FROM Customer c
	INNER JOIN [Transaction] t ON c.Id = t.CustomerId
	INNER JOIN @payments pp ON pp.PaymentId = t.Id
END

GO

