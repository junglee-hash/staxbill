
CREATE     procedure [dbo].[usp_CalculateCurrentMrr]
--DECLARE
	@customerIds AS dbo.IDList READONLY,
	@subscriptionProductIds AS dbo.IDList READONLY,
	@effectiveTimestamp datetime = NULL
AS

SET NOCOUNT ON

if @effectiveTimestamp IS NULL
	SET @effectiveTimestamp = GETUTCDATE()

CREATE TABLE #Customers (Id BIGINT, AccountId BIGINT)

INSERT INTO #Customers
SELECT
	c.Id
	,c.AccountId
FROM Customer c
join @customerIds cid on cid.Id = c.Id
--Do not want duplicates from subscription products
UNION
SELECT	
	s.CustomerId as Id
	,c.AccountId
FROM SubscriptionProduct sp
join @subscriptionProductIds spp on spp.Id = sp.Id
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN Customer c ON c.Id = s.CustomerId

CREATE TABLE #SubscriptionProducts
(
	BillingPeriodId BIGINT
	,BillingPeriodDefinitionId BIGINT
	,StartDate DATETIME
	,EndDate DATETIME
	,CustomerId BIGINT
	,SubscriptionId BIGINT
	,SubscriptionProductId BIGINT
	,RecurChargeTimingTypeId INT
	,OriginalMrr MONEY DEFAULT 0
	,OriginalNetMrr MONEY DEFAULT 0
	,NewMrr MONEY DEFAULT 0
	,NewNetMrr MONEY DEFAULT 0
	,DeltaMrr MONEY DEFAULT 0
	,DeltaNetMrr MONEY DEFAULT 0
	,PreviousStartDate DATETIME
)
INSERT INTO #SubscriptionProducts (BillingPeriodId, BillingPeriodDefinitionId, StartDate, EndDate, CustomerId, SubscriptionId, SubscriptionProductId, RecurChargeTimingTypeId, OriginalMrr, OriginalNetMrr, PreviousStartDate)
SELECT
	bp.Id
	,bp.BillingPeriodDefinitionId
	,bp.StartDate
	,bp.EndDate
	,bp.CustomerId
	,s.Id
	,sp.Id
	,sp.RecurChargeTimingTypeId
	,sp.CurrentMrr
	,sp.CurrentNetMrr
	--Has to be a previous billing period for EoP but SoP might not have one
	,CASE WHEN sp.RecurChargeTimingTypeId = 3 THEN pbp.StartDate 
		ELSE 
			CASE 
				WHEN s.IntervalId = 3 THEN COALESCE(pbp.StartDate,DATEADD(MONTH,-s.NumberOfIntervals,bp.StartDate)) 
				WHEN s.IntervalId = 5 THEN COALESCE(pbp.StartDate,DATEADD(YEAR,-s.NumberOfIntervals,bp.StartDate)) 
				ELSE COALESCE(pbp.StartDate,DATEADD(MONTH,-1,bp.StartDate)) 
			END
		END
FROM BillingPeriod bp
INNER JOIN #Customers cc ON cc.Id = bp.CustomerId
LEFT JOIN BillingPeriod pbp ON pbp.EndDate = bp.StartDate AND bp.BillingPeriodDefinitionId = pbp.BillingPeriodDefinitionId
INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
INNER JOIN Subscription s ON bpd.Id = s.BillingPeriodDefinitionId
INNER JOIN Customer c ON c.Id = s.CustomerId
INNER JOIN SubscriptionProduct sp ON s.Id = sp.SubscriptionId
WHERE 
	bp.PeriodStatusId = 1 --Open
	AND (
		EXISTS (
			SELECT	
				*
			FROM Subscription ss
			join @customerIds c on c.Id = ss.CustomerId
			WHERE ss.BillingPeriodDefinitionId = bp.BillingPeriodDefinitionId
		)
		OR EXISTS (
			SELECT	
				*
			FROM SubscriptionProduct sp
			join @subscriptionProductIds spp on spp.Id = sp.Id
			INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
			WHERE s.BillingPeriodDefinitionId = bp.BillingPeriodDefinitionId
		)
	)
	AND sp.IsRecurring = 1 
	AND sp.StatusId = 1 AND sp.ResetTypeId = 1 
	AND (s.StatusId = 2 or s.StatusId = 6 ) 
	AND (c.StatusId = 2 or c.StatusId = 4 or c.StatusId = 5)

CREATE TABLE #BillingPeriods
(
	BillingPeriodId BIGINT
	,SubscriptionProductId BIGINT
)

--Open Billing Period
INSERT INTO #BillingPeriods (BillingPeriodId, SubscriptionProductId)
SELECT DISTINCT
	BillingPeriodId
	,SubscriptionProductId
FROM #SubscriptionProducts

--Billing Periods from other definitions (SoP)
INSERT INTO #BillingPeriods (BillingPeriodId, SubscriptionProductId)
SELECT DISTINCT
	bp.Id
	,sp.SubscriptionProductId
FROM #SubscriptionProducts sp
INNER JOIN BillingPeriod bp ON bp.CustomerId = sp.CustomerId
WHERE bp.Id <> sp.BillingPeriodId
	AND sp.RecurChargeTimingTypeId = 2
	--Start is in BillingPeriod
	AND sp.StartDate >= bp.StartDate
	AND sp.StartDate < bp.EndDate
	--End is as well
	AND sp.EndDate <= bp.EndDate

--Previous Billing Period (EoP)
INSERT INTO #BillingPeriods (BillingPeriodId, SubscriptionProductId)
SELECT DISTINCT
	pbp.Id
	,sp.SubscriptionProductId
FROM #SubscriptionProducts sp
INNER JOIN BillingPeriod obp ON obp.Id = sp.BillingPeriodId
INNER JOIN BillingPeriod pbp ON pbp.EndDate = obp.StartDate AND obp.BillingPeriodDefinitionId = pbp.BillingPeriodDefinitionId
WHERE pbp.Id <> sp.BillingPeriodId
	AND sp.RecurChargeTimingTypeId = 3

--Billing Periods from other definitions (EoP)
INSERT INTO #BillingPeriods (BillingPeriodId, SubscriptionProductId)
SELECT
	bp.Id
	,sp.SubscriptionProductId
FROM #SubscriptionProducts sp
INNER JOIN BillingPeriod obp ON obp.Id = sp.BillingPeriodId
INNER JOIN BillingPeriod pbp ON pbp.EndDate = obp.StartDate AND obp.BillingPeriodDefinitionId = pbp.BillingPeriodDefinitionId
INNER JOIN BillingPeriod bp ON bp.CustomerId = sp.CustomerId
WHERE bp.Id <> sp.BillingPeriodId
	AND sp.RecurChargeTimingTypeId = 3
	--Start is in BillingPeriod
	AND pbp.StartDate >= bp.StartDate
	AND pbp.StartDate < bp.EndDate
	--End is as well
	AND pbp.EndDate < bp.EndDate



-- TEMP TABLE to store data about charges related to subscription products
CREATE TABLE #Charges
(
SubscriptionProductId bigint
,ChargeAmount money
,DiscountAmount money
,ImportedMrr money
,ImportedNetMrr money
,StartServiceDate DATETIME
,EndServiceDate DATETIME
,IntervalFactor decimal(18,6)
,EffectiveTimestamp DATETIME
)

;WITH ReverseCharges AS (
SELECT ISNULL(SUM(rctran.Amount),0) as ReverseChargeAmount, OriginalChargeId
FROM ReverseCharge rc
INNER JOIN [Transaction] rctran ON rc.Id = rctran.Id
LEFT JOIN VoidReverseCharge vrc ON rc.Id = vrc.OriginalReverseChargeId
WHERE vrc.Id IS NULL
GROUP BY OriginalChargeId
), Discounts AS (
SELECT ISNULL(SUM(dtran.Amount),0) as DiscountAmount, ChargeId
FROM Discount d
INNER JOIN [Transaction] dtran ON d.Id = dtran.Id
GROUP BY ChargeId
), ReverseDiscounts AS (
SELECT ISNULL(SUM(dtran.Amount),0) as ReverseDiscountAmount, ChargeId
FROM ReverseDiscount rd
INNER JOIN [Transaction] dtran ON rd.Id = dtran.Id
INNER JOIN Discount d ON d.Id = rd.OriginalDiscountId
LEFT JOIN VoidReverseDiscount vrd ON rd.Id = vrd.OriginalReverseDiscountId
WHERE vrd.Id IS NULL
GROUP BY d.ChargeId
), InitialData AS (
SELECT InitialMrr, InitialNetMrr, Id
FROM SubscriptionProductStartingData
WHERE HasRenewed = 0
)
insert into #Charges
select 
	sp.SubscriptionProductId
	,ISNULL(SUM(t.Amount) - ISNULL(rc.ReverseChargeAmount, 0), 0) as ChargeAmount
	, ISNULL(d.DiscountAmount, 0) - ISNULL(rd.ReverseDiscountAmount, 0) as DiscountAmount
	, ISNULL(spsd.InitialMrr, 0)
	, ISNULL(spsd.InitialNetMrr, 0)
	, spc.StartServiceDate
	, spc.EndServiceDate
	,0 as IntervalFactor --to be calculated in next step
	,t.EffectiveTimestamp
FROM #SubscriptionProducts sp
LEFT JOIN #BillingPeriods bp ON bp.SubscriptionProductId = sp.SubscriptionProductId
LEFT JOIN SubscriptionProductCharge spc  ON spc.SubscriptionProductId = sp.SubscriptionProductId 
	AND DATEDIFF(DAY,StartServiceDate,EndServiceDate) > 0
	AND spc.BillingPeriodId = bp.BillingPeriodId
	AND spc.StartServiceDate >= sp.PreviousStartDate
LEFT JOIN [Transaction] t ON t.Id = spc.Id
LEFT JOIN Discounts d ON t.Id = d.ChargeId
LEFT JOIN ReverseCharges rc ON t.Id = rc.OriginalChargeId
LEFT JOIN ReverseDiscounts rd ON t.Id = rd.ChargeId
LEFT JOIN InitialData spsd ON spsd.Id = sp.SubscriptionProductId
LEFT JOIN Charge c on c.id = spc.Id
GROUP BY sp.SubscriptionProductId,StartServiceDate,EndServiceDate,DiscountAmount,ProratedUnitPrice,unitprice,quantity,
ReverseChargeAmount,ReverseDiscountAmount,InitialMrr, InitialNetMrr, sp.StartDate, sp.EndDate, t.EffectiveTimestamp

--CALCULATE HOW MANY MONTHS THE CHARGE WAS FOR
--In case the charge service dates are in a period where it's one month in timezone and another in utc (ex: Jan 31st 11PM EST is Feb 1st 4AM UTC)
--we need to check the timestamps after converting to timezone
--but that function can perform poorly so let's do that as it's own statement on our temp table:
declare @TimezoneId int
declare @AccountId BIGINT
 --we call this from a context where we might not have account ID, so we cannot easily have accountId be a parameter for this sproc, but all customers should be for the same account
SET @AccountId = (SELECT TOP 1 AccountId from #Customers)
select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId

UPDATE #Charges
	SET IntervalFactor = 
		CASE 
			WHEN CONVERT(decimal(18,6), DATEDIFF(MONTH,dbo.fn_GetTimezoneTime(StartServiceDate,@TimezoneId),dbo.fn_GetTimezoneTime(EndServiceDate,@TimezoneId))) <> 0 
			THEN ISNULL(1 / CONVERT(decimal(18,6), DATEDIFF(MONTH,dbo.fn_GetTimezoneTime(StartServiceDate,@TimezoneId),dbo.fn_GetTimezoneTime(EndServiceDate,@TimezoneId))),1)
			ELSE 1 
		END


-- RECALCULATE NEW MRR
-- Adding to additional new MRR because there could be multiple charges per subscription product
;WITH SumMrr AS (
SELECT SUM(ROUND(ChargeAmount * IntervalFactor, 2)) as NewMrr, 
SUM(ROUND((ChargeAmount - DiscountAmount) * IntervalFactor, 2)) as NewNetMrr,
ImportedMrr, ImportedNetMrr, SubscriptionProductId
FROM #Charges
GROUP BY SubscriptionProductId, ImportedMrr, ImportedNetMrr
)
UPDATE sp SET
	sp.NewMrr = ch.NewMrr + ch.ImportedMrr
	,sp.NewNetMrr = ch.NewNetMrr + ch.ImportedNetMrr
	,sp.DeltaMrr = ch.NewMrr - sp.OriginalMrr + ch.ImportedMrr
	,sp.DeltaNetMrr = ch.NewNetMrr - sp.OriginalNetMrr + ch.ImportedNetMrr
FROM #SubscriptionProducts sp
INNER JOIN SumMrr ch ON ch.SubscriptionProductId = sp.SubscriptionProductId

-- DEBUG
--select * from @SubscriptionProducts sp
--select * from @Charges ch
--SELECT * FROM @BillingPeriods

-- RESET MRR on SubscriptionProduct
UPDATE sp SET
	sp.CurrentMrr = s.NewMrr
	,sp.CurrentNetMrr = s.NewNetMrr
	,sp.ModifiedTimestamp = GETUTCDATE()
FROM SubscriptionProduct sp
INNER JOIN #SubscriptionProducts s ON sp.Id = s.SubscriptionProductId

-- Apply delta to Subscription
;WITH SubProductTotal AS (
SELECT SUM(sp.CurrentMrr) as MrrTotal, SUM(sp.CurrentNetMrr) as NetMrrTotal, sp.SubscriptionId
FROM SubscriptionProduct sp
GROUP BY sp.SubscriptionId)
UPDATE s SET
	s.CurrentMrr = total.MrrTotal
	,s.CurrentNetMrr = total.NetMrrTotal
	,s.ModifiedTimestamp = GETUTCDATE()
FROM Subscription s
INNER JOIN #SubscriptionProducts sp ON s.Id = sp.SubscriptionId
INNER JOIN SubProductTotal total ON s.Id = total.SubscriptionId

-- Apply delta to Customer
;WITH Customers AS (
	SELECT DISTINCT
		CustomerId
	FROM #SubscriptionProducts
)
SELECT SUM(s.CurrentMrr) as MrrTotal, SUM(s.CurrentNetMrr) as NetMrrTotal, s.CustomerId
INTO #SubTotal
FROM Subscription s
INNER JOIN Customers c ON c.CustomerId = s.CustomerId
GROUP BY s.CustomerId

CREATE INDEX IDX1 ON #SubTotal(CustomerId)

UPDATE c SET
    c.CurrentMrr = s.MrrTotal
    ,c.CurrentNetMrr = s.NetMrrTotal
    ,c.ModifiedTimestamp = GETUTCDATE()
FROM Customer c
--This join may not be relevant 
INNER JOIN #SubscriptionProducts sp ON c.Id = sp.CustomerId
INNER JOIN #SubTotal s ON c.Id = s.CustomerId

DECLARE @cIds AS IDList
DECLARE @sIds AS IDList 
DECLARE @spIds AS IDList 
INSERT INTO @spIds SELECT SubscriptionProductId FROM #SubscriptionProducts 

EXEC usp_InsertSubscriptionProductJournals 
	@customerIds = @cIds
	, @subscriptionIds = @sIds
	, @subscriptionProductIds = @spIds
	, @effectiveTimestamp = @effectiveTimestamp

DROP TABLE #SubscriptionProducts
DROP TABLE #BillingPeriods
DROP TABLE #Charges
DROP TABLE #Customers

SET NOCOUNT OFF

GO

