CREATE   PROCEDURE [dbo].[usp_GetRenewableAccounts]
@RunDateTime Datetime = NULL,
--Specific Account Id is only ever used in the context of integration tests
--because those tests only care that the test account is returned
@SpecificAccountId BIGINT = NULL
AS
BEGIN
	SET NOCOUNT ON
	DECLARE	@UtcPeriodEndDateTime DATETIME;

	if @RunDateTime is null 
       set @RunDateTime = GETUTCDATE()
	
	-- Ideally we're just using getutcdate but for integration test purposes if the date is in the past
	-- Let's use that for the comparison instead of now
	DECLARE @MinimumLastRunBillingDate DATETIME = @RunDateTime

	IF @RunDateTime > GETUTCDATE()
		SET @MinimumLastRunBillingDate = GETUTCDATE()

	SELECT 
		   Id
		   ,StandardName
		   ,utcDate.[UTCDateTime] as UtcPeriodEndDateTime
	INTO #ModifiedEndTimestamp
	FROM Lookup.Timezone
	OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @RunDateTime) t
	OUTER APPLY Timezone.tvf_GetUTCTime(Id, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate

	-- Prefilter accounts
	SELECT
	a.Id as 'AccountId',
	a.CompanyName,
	a.Live,
	a.Signed,
	a.FusebillTest
	INTO #Account
	FROM Account a
	WHERE (a.Id = @SpecificAccountId OR @SpecificAccountId IS NULL)	
	AND a.IncludeInAutomatedProcesses = 1
	AND NOT EXISTS (
			SELECT * FROM AccountBilling ab
			WHERE ab.AccountId = a.Id
				AND (ab.CompletedTimestamp IS NULL
						OR DATEDIFF(MINUTE, ab.CompletedTimestamp, @MinimumLastRunBillingDate) < 15)
		)

	/*
	Are active and have their open billing period recharge date less than the start of tomorrow in their account's timezone
	*/

	SELECT	DISTINCT c.AccountID, c.Id as 'CustomerId'
	INTO	#BillingPeriodRechargeDate
	FROM	Customer c INNER JOIN
			BillingPeriod bp ON bp.CustomerId = c.Id  INNER JOIN
			AccountPreference ap on c.AccountId = ap.Id INNER JOIN
			#ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
	WHERE	bp.PeriodStatusId = 1 AND
			bp.RechargeDate < MED.UtcPeriodEndDateTime AND
			c.StatusId = 2
			AND c.HasUnknownPayment = 0
			AND (c.AccountID = @SpecificAccountId OR @SpecificAccountId IS NULL)	

	/*
	Have a Provisioning subscription whose scheduled activation timestamp is less than the start of tomorrow in their account's timezone 
	*/
	SELECT	DISTINCT c.AccountID, c.Id as 'CustomerId'
	INTO	#ProvisioningSubscriptionScheduledActivationTimestamp
	FROM	Customer c INNER JOIN
			BillingPeriodDefinition bpd ON c.Id = bpd.CustomerId INNER JOIN
			Subscription s ON bpd.Id = s.BillingPeriodDefinitionId INNER JOIN
			BillingPeriod bp ON bp.CustomerId = c.Id  INNER JOIN
			AccountPreference ap on c.AccountId = ap.Id INNER JOIN
			#ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
	WHERE	s.StatusId = 4 AND 
			s.ScheduledActivationTimestamp < MED.UtcPeriodEndDateTime AND
			c.StatusId = 2
			AND c.HasUnknownPayment = 0
			AND (c.AccountID = @SpecificAccountId OR @SpecificAccountId IS NULL)	


	/*
	Subscription that has scheduled activation timestamp less than the start of tomorrow in their account's timezone (non importing) and has never been charged (no charges) 
	*/
	SELECT	DISTINCT c.AccountID, c.Id as 'CustomerId'
	INTO	#ScheduledActivationTimestampLessThanTomorrow
	FROM	Customer c INNER JOIN 
			BillingPeriodDefinition bpd ON c.Id = bpd.CustomerId INNER JOIN 
			Subscription s ON bpd.Id = s.BillingPeriodDefinitionId INNER JOIN
			SubscriptionProduct sp ON sp.SubscriptionId = s.Id  INNER JOIN
			AccountPreference ap on c.AccountId = ap.Id INNER JOIN
			#ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
	WHERE	s.StatusId = 2 AND
			sp.Included = 1 AND 
			sp.StatusId = 1 AND
			sp.StartDate < MED.UtcPeriodEndDateTime AND
			c.StatusId = 2
			AND c.HasUnknownPayment = 0
			AND (c.AccountID = @SpecificAccountId OR @SpecificAccountId IS NULL)	

	/*
	Are active and have a migration scheduled for a specific date that is less than the start of tomorrow in their timezone 
	*/
	SELECT	DISTINCT c.AccountID, c.Id as 'CustomerId'
	INTO	#ScheduledActivationViaMigration
	FROM	Customer c INNER JOIN 
			BillingPeriodDefinition bpd ON c.Id = bpd.CustomerId INNER JOIN 
			Subscription s ON bpd.Id = s.BillingPeriodDefinitionId INNER JOIN
			ScheduledMigration sm ON sm.Id = s.Id INNER JOIN
			AccountPreference ap on c.AccountId = ap.Id INNER JOIN
			#ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id
	WHERE	s.StatusId = 2 AND
			sm.SpecifiedDate < MED.UtcPeriodEndDateTime AND
			c.StatusId = 2
			AND c.HasUnknownPayment = 0
			AND (c.AccountID = @SpecificAccountId OR @SpecificAccountId IS NULL)	

	CREATE TABLE #CustomersToBill(AccountID BIGINT, CustomerID BIGINT)

	INSERT INTO #CustomersToBill(AccountID, CustomerID)
	SELECT	AccountID, CustomerId
	FROM	#BillingPeriodRechargeDate 
	UNION
	SELECT	AccountID, CustomerId
	FROM	#ProvisioningSubscriptionScheduledActivationTimestamp 
	UNION
	SELECT	AccountID, CustomerId
	FROM	#ScheduledActivationTimestampLessThanTomorrow 
	UNION
	SELECT	AccountID, CustomerId
	FROM	#ScheduledActivationViaMigration

	DELETE	A
	FROM	#CustomersToBill A INNER JOIN
			Account B ON A.AccountID = B.Id
	WHERE	B.IncludeInAutomatedProcesses = 0

	SELECT	A.AccountID, B.CompanyName, COUNT(1) as 'CustomersToBill'
	FROM	#CustomersToBill A INNER JOIN
			CustomerBillingSetting cbs ON cbs.Id = A.CustomerID INNER JOIN
			#Account B on a.AccountID = B.AccountId INNER JOIN
			AccountAddressPreference aap ON aap.Id = A.AccountID INNER JOIN
			CustomerAddressPreference cap ON cap.Id = A.CustomerId LEFT OUTER JOIN
			[Address] adr ON adr.CustomerAddressPreferenceId = A.CustomerId and adr.AddressTypeId = 
				CASE
						WHEN ISNULL(cbs.UseCustomerBillingAddress,aap.UseCustomerBillingAddress) = 1 OR
							 (ISNULL(cbs.UseCustomerBillingAddress,aap.UseCustomerBillingAddress) != 1 AND
								cap.UseBillingAddressAsShippingAddress = 1) 
							THEN 1
						ELSE 2
					END
	WHERE (adr.Id is null or adr.Invalid = 0)
	GROUP BY
			A.AccountID, B.CompanyName, B.Live, B.Signed, B.FusebillTest
	ORDER BY B.Live DESC, B.Signed DESC, B.FusebillTest ASC, Count(1) ASC
END

GO

