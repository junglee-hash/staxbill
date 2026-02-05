CREATE     PROCEDURE [dbo].[usp_GetRenewableCustomers_General]
@RunDateTime DATETIME = NULL,
@AccountId BIGINT,
@LargeAccountThreshold INT = 100000,
@Debug_PrintQuery TINYINT = 0 
AS
BEGIN
	
	SET NOCOUNT ON
	DECLARE	@UtcPeriodEndDateTime DATETIME;
	
	SELECT	@UtcPeriodEndDateTime = utcDate.[UTCDateTime]
	FROM	AccountPreference OUTER APPLY 
			Timezone.tvf_GetTimezoneTime(TimezoneId, COALESCE(@RunDateTime,GETUTCDATE())) t OUTER APPLY 
			Timezone.tvf_GetUTCTime(TimezoneId, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate
	WHERE Id = @AccountId;

	DECLARE @IncludedInBilling BIT
	SELECT @IncludedInBilling = IncludeInAutomatedProcesses
	FROM Account 
	WHERE Id = @AccountId

	SELECT	c.Id as 'CustomerID', CONVERT(MONEY,0.00) as NetMrr
	INTO	#CustomersOfInterest
	FROM	Customer c
	WHERE	c.AccountId = @AccountId AND 
			c.StatusId = 2 AND			
			@IncludedInBilling = 1

	DELETE ci
	FROM #CustomersOfInterest ci
	INNER JOIN Customer c on c.Id = ci.CustomerID
	WHERE c.HasUnknownPayment = 1

	UPDATE ci
	SET ci.NetMrr = c.NetMrr
	FROM #CustomersOfInterest ci
	INNER JOIN Customer c on c.Id = ci.CustomerID

	/*
	Are active and have their open billing period recharge date less than the start of tomorrow in their account's timezone
	*/

	SELECT	DISTINCT c.CustomerID
	INTO	#BillingPeriodRechargeDate
	FROM	#CustomersOfInterest c INNER JOIN
			BillingPeriod bp ON bp.CustomerId = c.CustomerID
	WHERE	bp.PeriodStatusId = 1 AND
			bp.RechargeDate < @UtcPeriodEndDateTime
		
	/*
	Have a Provisioning subscription whose scheduled activation timestamp is less than the start of tomorrow in their account's timezone 
	*/
	--Generally very few provisioning subscription system-wide, so grab them all then filter by customer
	SELECT
		Id
		,CustomerId
	INTO #ProvisioningSubscriptionsOfInterest
	FROM Subscription
	WHERE	StatusId = 4 AND 
			ScheduledActivationTimestamp < @UtcPeriodEndDateTime

	SELECT	DISTINCT bpd.CustomerID
	INTO	#ProvisioningSubscriptionScheduledActivationTimestamp
	FROM	#ProvisioningSubscriptionsOfInterest ps
	INNER JOIN Subscription s ON s.Id = ps.Id
	INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
	INNER JOIN #CustomersOfInterest c ON c.CustomerID = ps.CustomerId

	/*
	Subscription that has scheduled activation timestamp less than the start of tomorrow in their account's timezone (non importing) and has never been charged (no charges) 
	*/
	--Generally very few subscription products with StartDates system-wide, so grab them all then filter by customer
	SELECT
		Id
		,SubscriptionId
	INTO #StartingSubscriptionProductsOfInterest
	FROM SubscriptionProduct
	WHERE	Included = 1 AND 
			StatusId = 1 AND
			StartDate < @UtcPeriodEndDateTime

	SELECT	DISTINCT bpd.CustomerID as CustomerId
	INTO	#ScheduledActivationTimestampLessThanTomorrow
	FROM	#StartingSubscriptionProductsOfInterest ps
	INNER JOIN Subscription s ON s.Id = ps.SubscriptionId
	INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
	INNER JOIN #CustomersOfInterest c ON c.CustomerId = s.CustomerId
	WHERE	s.StatusId = 2
			

	/*
	Are active and have a migration scheduled for a specific date that is less than the start of tomorrow in their timezone 
	*/
	SELECT	DISTINCT c.CustomerID as CustomerId
	INTO	#ScheduledActivationViaMigration
	FROM	#CustomersOfInterest c INNER JOIN 
			BillingPeriodDefinition bpd ON c.CustomerID = bpd.CustomerId INNER JOIN 
			Subscription s ON bpd.Id = s.BillingPeriodDefinitionId INNER JOIN
			ScheduledMigration sm ON sm.Id = s.Id
	WHERE	s.StatusId = 2 AND
			sm.SpecifiedDate < @UtcPeriodEndDateTime

	CREATE TABLE #CustomersToBill(CustomerID BIGINT)

	INSERT INTO #CustomersToBill(CustomerID)
	SELECT	CustomerId
	FROM	#BillingPeriodRechargeDate 
	UNION
	SELECT	CustomerId
	FROM	#ProvisioningSubscriptionScheduledActivationTimestamp 
	UNION
	SELECT	CustomerId
	FROM	#ScheduledActivationTimestampLessThanTomorrow 
	UNION
	SELECT	CustomerId
	FROM	#ScheduledActivationViaMigration

	SELECT DISTINCT
			ctb.CustomerID, @UtcPeriodEndDateTime as UtcPeriodEndDateTime, c.NetMRR
	FROM	#CustomersToBill ctb INNER JOIN 
			#CustomersOfInterest c ON c.CustomerID = ctb.CustomerId	INNER JOIN
			CustomerAddressPreference cap ON cap.Id = ctb.CustomerID INNER JOIN
			CustomerBillingSetting cbs ON cbs.Id = ctb.CustomerID INNER JOIN 
			AccountAddressPreference aap ON aap.Id = @AccountId LEFT OUTER JOIN
			[Address] adr ON adr.CustomerAddressPreferenceId = ctb.CustomerID AND
				adr.AddressTypeId = 
					CASE
						WHEN ISNULL(cbs.UseCustomerBillingAddress,aap.UseCustomerBillingAddress) = 1 OR
							 (ISNULL(cbs.UseCustomerBillingAddress,aap.UseCustomerBillingAddress) != 1 AND
								cap.UseBillingAddressAsShippingAddress = 1) 
							THEN 1
						ELSE 2
					END
	WHERE (adr.Id IS NULL OR adr.Invalid = 0)

	DROP TABLE #CustomersToBill
	DROP TABLE #CustomersOfInterest
	DROP TABLE #BillingPeriodRechargeDate
	DROP TABLE #ProvisioningSubscriptionScheduledActivationTimestamp
	DROP TABLE #ScheduledActivationViaMigration
	DROP TABLE #ScheduledActivationTimestampLessThanTomorrow
	DROP TABLE #ProvisioningSubscriptionsOfInterest
	DROP TABLE #StartingSubscriptionProductsOfInterest
END

GO

