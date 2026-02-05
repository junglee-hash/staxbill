CREATE     PROCEDURE [dbo].[usp_UpdateAnrokLogs]

	@AnrokLogs AS AnrokLogList readonly

AS

	SET XACT_ABORT, NOCOUNT ON

	UPDATE a SET
		a.DraftInvoiceId = al.DraftInvoiceId
		, a.InvoiceId = al.InvoiceId
		, a.CustomerId = CASE WHEN al.CustomerId > 0 THEN al.CustomerId ELSE a.CustomerId END
	FROM AnrokLog a
	INNER JOIN @AnrokLogs al ON a.Id = al.AnrokLogId

GO

