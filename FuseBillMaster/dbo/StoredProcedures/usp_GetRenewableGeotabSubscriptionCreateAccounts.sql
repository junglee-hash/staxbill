CREATE   PROCEDURE [dbo].[usp_GetRenewableGeotabSubscriptionCreateAccounts]
	@CreatedTimestampBuffer int
	, @RunDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT agc.Id
	FROM AccountGeotabConfiguration agc
	INNER JOIN Account a ON a.Id = agc.Id
	WHERE agc.StatusId = 1
		AND a.IncludeInAutomatedProcesses = 1
		AND agc.SubscriptionCreate = 1
		AND agc.SubscriptionCreateNextRunTimestamp <= @RunDate
		AND NOT EXISTS (
			SELECT *
			FROM AccountAutomatedHistory ah
			WHERE agc.Id = ah.AccountId
				AND ah.AccountAutomatedHistoryTypeId = 24
				AND (
					ah.CompletedTimestamp IS NULL
					AND ah.CreatedTimestamp > DATEADD(MINUTE, @CreatedTimestampBuffer * -1, @RunDate)
				)
		)

END

GO

