CREATE   PROCEDURE [dbo].[usp_GetAccountsForQuickBooksAuthorizationExpiryEmail]
	@EffectiveTime DATETIME = NULL
AS

	IF @EffectiveTime IS NULL
		SET @EffectiveTime = GETUTCDATE()

	SET NOCOUNT ON;
	 
	SELECT q.Id
		FROM AccountQuickBooksOnlineConfig q
		INNER JOIN Account a ON a.Id = q.Id
		WHERE q.ExpirationTimestamp BETWEEN @EffectiveTime AND DATEADD(DAY,7,@EffectiveTime) 
			AND q.NotificationExpiryEmail  = 1 
			AND q.NotificationEmailSent = 0
			AND a.IncludeInAutomatedProcesses = 1

	SET NOCOUNT OFF;

GO

