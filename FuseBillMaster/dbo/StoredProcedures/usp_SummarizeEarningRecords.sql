
CREATE PROCEDURE [dbo].[usp_SummarizeEarningRecords]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS
BEGIN
IF OBJECT_ID('dbo.Transaction_Earning', 'U') IS NOT NULL 
	DROP TABLE [dbo].[Transaction_Earning]

--Table to persist to second sproc
CREATE TABLE [dbo].[Transaction_Earning](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CreatedTimestamp] [datetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[Amount] [money] NOT NULL,
	[EffectiveTimestamp] [datetime] NOT NULL,
	[TransactionTypeId] [int] NOT NULL,
	[Description] [nvarchar](2000) NULL,
	[CurrencyId] [bigint] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[AccountId] [bigint] NOT NULL,
	[ModifiedTimestamp] [datetime] NULL,
	[ChargeId] BIGINT NOT NULL
)

--Summarize earning by charge by calendar month/year
INSERT INTO [Transaction_Earning]
SELECT
	MIN(t.CreatedTimestamp) as CreatedTimestamp
	,t.CustomerId
	,SUM(t.Amount) as Amount
	,MAX(t.EffectiveTimestamp) as EffectiveTimestamp
	,t.TransactionTypeId
	,t.Description
	,t.CurrencyId
	,99 as SOrtOrder
	,t.AccountId
	,MAX(t.EffectiveTimestamp) as ModifiedTimestamp
	,e.ChargeId
FROM [Transaction] t
INNER JOIN Earning e ON e.Id = t.Id
INNER JOIN ChargeLastEarning cle ON cle.Id = e.ChargeId
INNER JOIN AccountPreference ap ON ap.Id = t.AccountId
--Dates need to be in account timezone to do the right month group
CROSS APPLY Timezone.tvf_GetTimezoneTime(ap.TimezoneId, t.EffectiveTimestamp) tz
WHERE t.TransactionTypeId IN (6)
AND t.EffectiveTimestamp >= @StartDate
AND t.EffectiveTimestamp < @EndDate
AND t.AccountId = @AccountId
GROUP BY 
	t.AccountId
	,t.CustomerId
	,e.ChargeId
	--Dates need to be in account timezone to do the right month group
	,DATEPART(MONTH,tz.TimezoneDate)
	,DATEPART(YEAR,tz.TimezoneDate)
	,t.TransactionTypeId
	,t.Description
	,t.CurrencyId

--Validation
DECLARE @SummaryEarning MONEY
	,@TransactionEarning MONEY

SELECT @SummaryEarning = SUM(Amount) FROM  
[Transaction_Earning]

SELECT @TransactionEarning = SUM(Amount) FROM [Transaction] t
WHERE t.AccountId = @AccountId
AND t.TransactionTypeId = 6 
AND t.EffectiveTimestamp >= @StartDate
AND t.EffectiveTimestamp < @EndDate

IF(@SummaryEarning != @TransactionEarning)
BEGIN 
	DROP TABLE [dbo].[Transaction_Earning];
	THROW 51000, 'Summarized earning amount does not match transaction earning amount.', 1;  
END 


SELECT 
	DATEPART(YEAR,tz.TimezoneDate) as Year
	,DATEPART(MONTH,tz.TimezoneDate) as Month
	,SUM(te.Amount) as Amount
INTO #SummaryEarning
FROM [Transaction_Earning] te
INNER JOIN AccountPreference ap ON ap.Id = te.AccountId
CROSS APPLY Timezone.tvf_GetTimezoneTime(ap.TimezoneId, te.EffectiveTimestamp) tz
GROUP BY
DATEPART(MONTH,tz.TimezoneDate)
,DATEPART(YEAR,tz.TimezoneDate)

SELECT
	DATEPART(YEAR,tz.TimezoneDate) as Year
	,DATEPART(MONTH,tz.TimezoneDate) as Month
	,SUM(t.Amount) as Amount
INTO #TransactionEarning
FROM [Transaction] t
INNER JOIN AccountPreference ap ON ap.Id = t.AccountId
CROSS APPLY Timezone.tvf_GetTimezoneTime(ap.TimezoneId, t.EffectiveTimestamp) tz
WHERE t.AccountId = @AccountId
AND t.TransactionTypeId = 6
AND t.EffectiveTimestamp >= @StartDate
AND t.EffectiveTimestamp < @EndDate
GROUP BY
DATEPART(MONTH,tz.TimezoneDate)
,DATEPART(YEAR,tz.TimezoneDate)

IF(EXISTS(
	SELECT
		*
	FROM #SummaryEarning se
	LEFT JOIN #TransactionEarning te ON te.Year = se.Year AND te.Month = se.Month
	WHERE 
		--Summed wrong
		se.Amount != te.Amount
		--Date match off
		OR te.Amount IS NULL
))
BEGIN
	DROP TABLE [dbo].[Transaction_Earning];
	THROW 51001, 'Summarized earning amount does not match transaction earning amount.', 1;  
END

DROP TABLE #SummaryEarning
DROP TABLE #TransactionEarning


END

GO

