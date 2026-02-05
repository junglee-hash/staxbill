-- =============================================
-- Author:		Ilia Sazonov
-- Create date: Jan 31, 2023
-- Description:	Get customers to unsuspend according to new account level grace period
-- Updating to include check for auto suspend disabled to ignore any grace period

-- Modified date: May 22, 2025
-- Changing to use temp table to filter customers down AB#63070

-- =============================================
CREATE     PROCEDURE [dbo].[usp_GetCustomersToUnsuspend] 
	@TimeOfTransaction DateTime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @TimeOfTransaction is null
		set @TimeOfTransaction = GETUTCDATE()

	CREATE TABLE #CustomersThatMightUnsuspend (
		Id BIGINT PRIMARY KEY CLUSTERED NOT NULL
		, AccountStatusId INT NOT NULL
	)

	-- Get customers in Suspended status
		-- And account is included in automated processes
	INSERT INTO #CustomersThatMightUnsuspend
	SELECT c.Id, c.AccountStatusId
	FROM Customer c
	INNER JOIN Account a ON a.Id = c.AccountId
		AND a.IncludeInAutomatedProcesses = 1
	WHERE c.StatusId = 5


	SELECT 
		cs.Id
	FROM #CustomersThatMightUnsuspend cs
	INNER JOIN Customer c ON c.Id = cs.Id
	INNER JOIN CustomerBillingSetting cbs ON cs.Id = cbs.Id 
	INNER JOIN AccountBillingPreference abp on abp.Id = c.AccountId
	WHERE (
				(
					cs.AccountStatusId = 2
					and (ISNULL(cbs.CustomerGracePeriod, ISNULL(abp.AccountGracePeriod, 0)) + ISNULL(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,c.LastAccountStatusJournalTimestamp, @TimeOfTransaction) / 24)) > 0
				)
				or cs.AccountStatusId = 1
				or abp.AutoSuspendEnabled = 0 -- any suspended customer when feature is off
			)

	DROP TABLE #CustomersThatMightUnsuspend
END

GO

