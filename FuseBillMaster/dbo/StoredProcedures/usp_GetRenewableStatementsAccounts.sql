CREATE   PROCEDURE [dbo].[usp_GetRenewableStatementsAccounts]
--declare
@RunDateTime Datetime,
@OptionId int
AS
set transaction isolation level snapshot
set nocount on

if @RunDateTime is null 
       set @RunDateTime = GETUTCDATE()

CREATE TABLE #TimezoneDate (
	TimezoneId BIGINT,
    CurrentDate DATE,
    DaysInMonth INT
)
INSERT INTO #TimezoneDate
SELECT t.Id, tz.TimezoneDate, DAY(EOMONTH(tz.TimezoneDate))
FROM Lookup.Timezone t
    OUTER APPLY [Timezone].[tvf_GetTimezoneTime] (t.Id, @RunDateTime) tz


CREATE TABLE #RenewableResult (
	AccountId BIGINT
	,CompanyName NVARCHAR(255)
	,CustomersToBill INT
)

INSERT INTO #RenewableResult
EXEC usp_GetRenewableAccounts @RunDateTime

--Get accounts that are yet to bill or started billing and haven't finished yet or should not bill at all
CREATE TABLE #AccountsToInclude (
	AccountId BIGINT
)

INSERT INTO #AccountsToInclude
SELECT Id FROM Account a
WHERE IncludeInAutomatedProcesses = 1

DELETE FROM #AccountsToInclude
WHERE AccountId IN
	(SELECT AccountId FROM #RenewableResult)

DELETE FROM #AccountsToInclude
WHERE AccountId IN
	(SELECT AccountId FROM AccountBilling ab 
	WHERE ab.CompletedTimestamp IS NULL)

CREATE TABLE #CustomerDate (
    AccountId BIGINT NOT NULL,
	CustomerId BIGINT NOT NULL,
	ActivationTimestamp DATETIME NOT NULL,
    ActivationDate DATE NOT NULL,
	StatementSendInterval INT NOT NULL,
	StatementSendType INT NOT NULL,
	TargetMonthlySendDateAnniversary DATE NOT NULL,
	TargetYearlySendDateAnniversary DATE NULL,
	LastStatementId BIGINT NULL,
	LastStatementSendDate DATE NULL,
	MonthlyIntervalsFromLastStatementDateOrActivationDate INT NOT NULL,
	YearlyIntervalsFromLastStatementDateOrActivationDate INT NOT NULL,
	TimezoneId INT NOT NULL,
	CurrentDate DATE NOT NULL,
    DaysInActivationMonthForCurrentYear INT NOT NULL
)
INSERT INTO #CustomerDate
SELECT 
	ap.Id as AccountId, 
	c.id as CustomerId, 
	c.ActivationTimestamp,
	tz.TimezoneDate as ActivationDate,
	COALESCE(cbss.IntervalId, absp.IntervalId) as StatementSendInterval,
	COALESCE(cbss.TypeId, absp.TypeId) as StatementSendType,
	CASE WHEN COALESCE(cbss.TypeId, absp.TypeId) = 1 THEN
		-- Calculate based of customer activation day
		DATEFROMPARTS(
				YEAR(td.CurrentDate)
				, MONTH(td.CurrentDate)
				, CASE WHEN td.DaysInMonth > c.ActivationDay THEN c.ActivationDay ELSE td.DaysInMonth END
			)
		ELSE
			-- Calculate based on specific day chosen
			 DATEFROMPARTS(
				YEAR(td.CurrentDate)
				, MONTH(td.CurrentDate)
				, CASE WHEN td.DaysInMonth > COALESCE(cbss.Day, absp.Day) THEN COALESCE(cbss.Day, absp.Day) ELSE td.DaysInMonth END
			)
		END as TargetMonthlySendDateAnniversary,
	CASE WHEN COALESCE(cbss.TypeId, absp.TypeId) = 1 THEN
		-- Calculate based of customer activation day and month
		DATEFROMPARTS(
			YEAR(td.CurrentDate)
			, MONTH(tz.TimezoneDate)
			, CASE WHEN DAY(EOMONTH(DATEFROMPARTS(Year(td.CurrentDate), Month(tz.TimezoneDate),1))) > c.ActivationDay 
				THEN c.ActivationDay 
				ELSE DAY(EOMONTH(DATEFROMPARTS(Year(td.CurrentDate), Month(tz.TimezoneDate),1))) 
				END
		)
		WHEN COALESCE(cbss.Month, absp.Month) IS NOT NULL THEN
			-- Calculate based on specific day and month chosen
			DATEFROMPARTS(
				YEAR(td.CurrentDate)
				, COALESCE(cbss.Month, absp.Month)
				, CASE WHEN DAY(EOMONTH(DATEFROMPARTS(Year(td.CurrentDate), COALESCE(cbss.Month, absp.Month),1))) > COALESCE(cbss.Day, absp.Day) THEN COALESCE(cbss.Day, absp.Day) ELSE DAY(EOMONTH(DATEFROMPARTS(Year(td.CurrentDate), COALESCE(cbss.Month, absp.Month),1))) END
			)
		ELSE NULL
		END as TargetYearlySendDateAnniversary,
	TopBillingStatement.Id as LastStatementId,
	TopBillingStatement.TimezoneDate as LastStatementSendDate,
	DATEDIFF(month, COALESCE(TopBillingStatement.TimezoneDate, tz.TimezoneDate), td.CurrentDate) as MonthlyIntervalsFromLastStatementDateOrActivationDate,
	DATEDIFF(year, COALESCE(TopBillingStatement.TimezoneDate, tz.TimezoneDate), td.CurrentDate) as YearlyIntervalsFromLastStatementDateOrActivationDate,
	ap.TimezoneId,
	td.CurrentDate,
	DAY(EOMONTH(DATEFROMPARTS(Year(td.CurrentDate), Month(tz.TimezoneDate),1))) as DaysInActivationMonthForCurrentYear
FROM AccountPreference ap
	inner join Customer c on c.AccountId = ap.Id
	INNER JOIN #AccountsToInclude ati on c.AccountId = ati.AccountId
	inner join #TimezoneDate td on td.TimezoneId = ap.TimezoneId
	INNER JOIN CustomerBillingStatementSetting cbss ON cbss.Id = c.id
	INNER JOIN AccountBillingStatementPreference absp ON absp.Id = c.AccountId
    OUTER APPLY [Timezone].[tvf_GetTimezoneTime] (ap.TimezoneId, c.ActivationTimestamp) tz
	OUTER APPLY (
		SELECT TOP 1 * FROM BillingStatement bs
		OUTER APPLY [Timezone].[tvf_GetTimezoneTime] (ap.TimezoneId, DATEADD(second, 1, bs.EndDate)) tz
		WHERE bs.CustomerId = c.Id
		ORDER BY bs.EndDate DESC
	) as TopBillingStatement
WHERE tz.TimezoneDate <= td.CurrentDate
	AND c.StatusId = 2
    AND COALESCE(cbss.OptionId, absp.OptionId) = @OptionId

SELECT distinct
	AccountId
FROM #CustomerDate
WHERE (
			--determine the number of intervals since we last sent
		
		-- this brings people back where we somehow broke and didn't send them in the correct month/year roll over
			-- e.g. should have sent dec 13 and it's now jan 1, they should still be eligible because they have never sent
		
		CASE WHEN StatementSendInterval = 3 -- Monthly
			THEN MonthlyIntervalsFromLastStatementDateOrActivationDate
			ELSE YearlyIntervalsFromLastStatementDateOrActivationDate
		END > 1

		OR

	-- Only send when next statement target date <= today
		-- e.g. activate nov 1, last sent dec 1, current date is dec 13, calculated date for next send is still dec 1 so exclude them
		-- when jan 1 rolls around the prev dec 1 calculated date will correctly change to jan 1 and be eligible
		CurrentDate >= CASE WHEN StatementSendInterval = 3 -- Monthly
							THEN TargetMonthlySendDateAnniversary
							ELSE TargetYearlySendDateAnniversary
						END

	AND (

		-- Last send date or activate date (when there is no last send date) is less than their target send date
			-- Prevent sending multiple for the same interval
		COALESCE(LastStatementSendDate, ActivationDate) < CASE WHEN StatementSendInterval = 3 -- Monthly
							THEN TargetMonthlySendDateAnniversary
							ELSE TargetYearlySendDateAnniversary
						END
		)
	)


DROP TABLE #TimezoneDate
DROP TABLE #CustomerDate
DROP TABLE #AccountsToInclude
DROP TABLE #RenewableResult

GO

