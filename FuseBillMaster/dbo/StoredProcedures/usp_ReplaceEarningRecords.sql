
CREATE PROCEDURE [dbo].[usp_ReplaceEarningRecords]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS
BEGIN

----Debug
--SELECT *
--FROM [Transaction] t
--WHERE t.AccountId = @AccountId
--AND t.TransactionTypeId = 6

DECLARE @PreDeleteEarning MONEY
	,@PostDeleteEarning MONEY

--Pre insert/delete sums of earning for validation, check against all time regardless of filters
SELECT @PreDeleteEarning = SUM(Amount) FROM [Transaction] t
WHERE t.AccountId = @AccountId
AND t.TransactionTypeId = 6 

CREATE TABLE #TransactionResult
(
	TransactionId bigint
	,CustomerId bigint
	,AccountId bigint
	,Amount money
	,ChargeId Bigint
	,EffectiveTimestamp datetime
	,CurrencyId bigint
)

BEGIN TRAN

--Insert the summarized records into Transaction
MERGE  [Transaction] as Target
USING (
	SELECT
	t.CreatedTimestamp as CreatedTimestamp
	,t.CustomerId
	,t.Amount as Amount
	,t.EffectiveTimestamp as EffectiveTimestamp
	,t.TransactionTypeId
	,t.Description
	,t.CurrencyId
	,99 as SOrtOrder
	,t.AccountId
	,GETUTCDATE() as ModifiedTimestamp
	,t.ChargeId
	FROM [Transaction_Earning] t
) as Source
	--Not sure the clause for this
	ON Target.Id = 0
WHEN NOT MATCHED BY TARGET THEN 
INSERT (AccountId, CreatedTimestamp, CustomerId, Amount, EffectiveTimestamp, TransactionTypeId, Description, CurrencyId, SortOrder, ModifiedTimestamp)  
VALUES (Source.AccountId, GETUTCDATE(),Source.CustomerId,Source.Amount,Source.EffectiveTimestamp,Source.TransactionTypeId,Source.Description,Source.CurrencyId, 99, Source.ModifiedTimestamp)
OUTPUT  
	INSERTED.Id
	, INSERTED.CustomerId
	, INSERTED.AccountId
	, INSERTED.Amount
	, INSERTED.EffectiveTimestamp
	, Source.ChargeId
	, INSERTED.CurrencyId
INTO #TransactionResult  
(
		TransactionId
		,CustomerId
		,AccountId
		,Amount
		,EffectiveTimestamp
		, ChargeId
		, CurrencyId
)  
;

--Insert the related Earning record
INSERT INTO Earning
SELECT
	TransactionId
	,ChargeId
	,NULL as Reference
FROM #TransactionResult

--Update ChargeLastEarning to use summarized earning record
;WITH NewestEarning AS (
	--Need most recent earning per charge from new insert
	SELECT
		ChargeId
		,MAX(EffectiveTimestamp) as EffectiveTimestamp
	FROM #TransactionResult
	GROUP BY ChargeId
)
UPDATE cle
SET EarningId = tr.TransactionId
	,ModifiedTimestamp = GETUTCDATE()
FROM ChargeLastEarning cle
INNER JOIN NewestEarning ne ON ne.ChargeId = cle.Id
INNER JOIN #TransactionResult tr ON tr.ChargeId = cle.Id AND tr.EffectiveTimestamp = ne.EffectiveTimestamp
--Summarized earning may not be the actual last earning, so check against existing earning
LEFT JOIN [Transaction] te ON te.Id = cle.EarningId 
	AND te.EffectiveTimestamp >= @EndDate
WHERE te.Id IS NULL

----Debug
--SELECT DISTINCT
--	cle.*
--FROM ChargeLastEarning cle
--INNER JOIN #TransactionResult tr ON tr.ChargeId = cle.Id

--Delete previous Earning records, within date filter
DELETE e
FROM Earning e
INNER JOIN [Transaction] t ON t.Id = e.Id
LEFT JOIN #TransactionResult tr ON tr.TransactionId = t.Id
WHERE t.AccountId = @AccountId
AND tr.TransactionId IS NULL
AND t.EffectiveTimestamp >= @StartDate
AND t.EffectiveTimestamp < @EndDate

--Delete previous Transaction records, within date filter
DELETE t
FROM [Transaction] t
LEFT JOIN #TransactionResult tr ON tr.TransactionId = t.Id
WHERE t.AccountId = @AccountId
AND t.TransactionTypeId = 6
AND tr.TransactionId IS NULL
AND t.EffectiveTimestamp >= @StartDate
AND t.EffectiveTimestamp < @EndDate

DROP TABLE #TransactionResult

--Post delete sums of earning, check against all time regardless of filters
SELECT @PostDeleteEarning = SUM(Amount) FROM [Transaction] t
WHERE t.AccountId = @AccountId
AND t.TransactionTypeId = 6 

--Validate pre-delete and post delete are equal
--SELECT @PreDeleteEarning, @PostDeleteEarning
IF(@PreDeleteEarning != @PostDeleteEarning)
BEGIN 
	ROLLBACK TRAN;
	THROW 51000, 'Pre-delete earning total does not match post delete earning total.', 1;  
END 

----Debug
--SELECT *
--FROM [Transaction] t
--WHERE t.AccountId = @AccountId
--AND t.TransactionTypeId = 6

COMMIT TRAN

END

GO

