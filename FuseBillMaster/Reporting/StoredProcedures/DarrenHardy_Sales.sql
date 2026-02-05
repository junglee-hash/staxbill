
CREATE PROCEDURE [Reporting].[DarrenHardy_Sales]
 @AccountId BIGINT --= 22408
,@StartDate DATETIME --= '2020-02-01'
,@EndDate DATETIME --= '2020-03-01'
AS

DECLARE @TimeZoneId INT
--Hard coded to USD, Darren Hardy has only 1 currency and we cannot pass in customer currency to get ledgers for lifetime value
DECLARE @CurrencyId BIGINT = 1

SELECT
	@TimeZoneId = TimezoneId
	,@StartDate = utcStartDate.UTCDateTime 
	,@EndDate = utcEndDate.UTCDateTime 
FROM AccountPreference
OUTER APPLY Timezone.tvf_GetUTCTime(TimezoneId, @StartDate, DEFAULT, DEFAULT) utcStartDate
OUTER APPLY Timezone.tvf_GetUTCTime(TimezoneId, @EndDate, DEFAULT, DEFAULT) utcEndDate
WHERE Id = @AccountId

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--; WITH LastScheduledCharge
-- as
--(
--SELECT 
--    BillingPeriodDefinitionId
--    , MAX(StartDate) as LastScheduledCharge
--FROM
--    BillingPeriod 
--WHERE
--	PeriodStatusId = 2 -- closed
--GROUP BY
--	BillingPeriodDefinitionId
--)

SELECT
	inv.InvoiceNumber
	,localPostedTimestamp.TimezoneDateTime as PostedDate
	,t.Amount
	,ii.Name as InvoiceStatus
	,s.Id as SubscriptionId
	,s.PlanName as SubscriptionName
	,ss.Name as SubscriptionStatus
	,localSubscriptionActivationTimestamp.TimezoneDateTime as SubscriptionActivation
	,localRechargeDate.TimezoneDateTime as SubscriptionNextRechargeDate
	,localLastScheduledCharge.TimezoneDateTime as LastScheduledCharge
	,CASE WHEN inv.PostedTimestamp <= DATEADD(DAY, 14, ISNULL(s.ActivationTimestamp, '2099-01-01')) THEN 'New' ELSE 'Recur' END as SaleType
	,sp.PlanProductName as SubscriptionProductName
	,pur.Name as PurchaseProduct
	,ch.Quantity
	,ch.UnitPrice
	,sp.NetMRR as MRR
	,sp.RemainingInterval as RemainingExpiryPeriods
	,c.Id as FusebillId
	,c.FirstName
	,c.LastName
	,c.PrimaryEmail
	,localCustomerActivationTimestamp.TimezoneDateTime as CustomerActivation
	,cs.Name as CustomerStatus
	,cas.Name as CustomerAccountStatus
	,c.ArBalance as CustomerTotalBalance
	,ISNULL(clj.EarnedCredit, 0) - ISNULL(clj.EarnedDebit, 0) + ISNULL(csd.PreviousLifetimeValue, 0) - cbs.AcquisitionCost - (ISNULL(clj.DiscountDebit, 0) - ISNULL(clj.DiscountCredit, 0)) AS LifeTimeValue
FROM Invoice inv 
INNER JOIN Charge ch ON inv.Id = ch.InvoiceId
INNER JOIN PaymentSchedule ps ON ps.InvoiceId = inv.Id
INNER JOIN PaymentScheduleJournal psj ON psj.PaymentScheduleId = ps.Id AND psj.IsActive = 1
INNER JOIN [Transaction] t ON t.Id = ch.Id

LEFT JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
LEFT JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId
LEFT JOIN Subscription s ON s.Id = sp.SubscriptionId
LEFT JOIN BillingPeriod bp on bp.BillingPeriodDefinitionId = s.BillingPeriodDefinitionId AND bp.PeriodStatusId = 1

OUTER APPLY (
    SELECT TOP 1 BillingPeriodDefinitionId
        ,EndDate AS LastScheduledCharge
    FROM BillingPeriod bp
    WHERE PeriodStatusId = 2 -- closed
        AND BillingPeriodDefinitionId = s.BillingPeriodDefinitionId
    ORDER BY EndDate DESC
    ) lsc

LEFT JOIN PurchaseCharge pc on pc.Id = t.Id
LEFT JOIN Purchase pur on pur.Id = pc.PurchaseID

INNER JOIN Customer c ON c.Id = t.CustomerId
LEFT JOIN tvf_CustomerLedgers_old(@AccountId, @CurrencyId, null, GETUTCDATE()) clj ON c.Id = clj.CustomerId -- no requirement to have the ledgers as of enddate so using now
LEFT JOIN CustomerStartingData csd on csd.Id = c.Id
LEFT JOIN CustomerBillingSetting cbs on cbs.Id = c.Id

OUTER APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, inv.PostedTimestamp) localPostedTimestamp
OUTER APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, s.ActivationTimestamp) localSubscriptionActivationTimestamp
OUTER APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, bp.RechargeDate) localRechargeDate
OUTER APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, lsc.LastScheduledCharge) localLastScheduledCharge
OUTER APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, c.ActivationTimestamp) localCustomerActivationTimestamp

INNER JOIN Lookup.InvoiceStatus ii ON ii.Id = psj.StatusId
LEFT JOIN Lookup.SubscriptionStatus ss ON ss.Id = s.StatusId
INNER JOIN Lookup.CustomerStatus cs ON cs.Id = c.StatusId
INNER JOIN Lookup.CustomerAccountStatus cas ON cas.Id = c.AccountStatusId
WHERE inv.AccountId = @AccountId
	AND inv.PostedTimestamp >= @StartDate
	AND inv.PostedTimestamp < @EndDate

GO

