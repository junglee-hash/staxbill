CREATE   PROCEDURE [dbo].[usp_GetProjectedInvoicesSentUpcomingNotificationEmail]
	@CustomerId bigint
AS
BEGIN
	set transaction isolation level snapshot

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	set fmtonly off

	SELECT di.*
		, di.DraftInvoiceStatusId as DraftInvoiceStatus
	FROM DraftInvoice di
	INNER JOIN CustomerEmailControl cec ON cec.CustomerId = di.CustomerId
		AND cec.EmailTypeId = 9 -- Upcoming billing notification
		AND cec.EmailKey = 'UpcomingBillingNotification_' + CONVERT(varchar(50), di.Id)
	WHERE di.CustomerId = @CustomerId
		AND di.DraftInvoiceStatusId = 5 -- Projected invoice
		AND di.EffectiveTimestamp IS NOT NULL
	
END

GO

