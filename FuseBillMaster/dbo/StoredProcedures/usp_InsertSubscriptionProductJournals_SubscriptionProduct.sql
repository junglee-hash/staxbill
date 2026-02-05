CREATE   procedure [dbo].[usp_InsertSubscriptionProductJournals_SubscriptionProduct]
	@subscriptionProductIds AS dbo.IDList READONLY,
	@effectiveTimestamp datetime
AS

CREATE TABLE #ProductsToBeJournaled (
	[SubscriptionProductId] BIGINT NOT NULL
	, [SubscriptionProductGrossMRR] DECIMAL(18,2) NOT NULL
	, [SubscriptionProductNetMRR] DECIMAL(18,2) NOT NULL
	, [SubscriptionProductIncludedStatus] VARCHAR(50) NOT NULL
	, [SubscriptionProductQuantity] DECIMAL(18,6) NOT NULL
	, [SubscriptionProductAmount] DECIMAL(18,2) NOT NULL
	, [SubscriptionStatusId] INT NOT NULL
	, [SubscriptionActivationDate] DATETIME NULL
	, [SubscriptionCancellationDate] DATETIME NULL
	, [SubscriptionContractStartTimestamp] DATETIME NULL
	, [SubscriptionContractEndTimestamp] DATETIME NULL
	, [SalesTrackingCode1Id] BIGINT NULL
	, [SalesTrackingCode2Id] BIGINT NULL
	, [SalesTrackingCode3Id] BIGINT NULL
	, [SalesTrackingCode4Id] BIGINT NULL
	, [SalesTrackingCode5Id] BIGINT NULL
	, [RemainingInterval] INT NULL
	, [ExpiredTimestamp] DATETIME NULL
	, [SubscriptionProductStatusId] INT NOT NULL
	, [SubscriptionProductCurrentMrr] MONEY NOT NULL
	, [SubscriptionProductCurrentNetMrr] MONEY NOT NULL
	, [SubscriptionExpiryTimestamp] DATETIME NULL
)

CREATE TABLE #LastRecordedJournalForDuplicateComparison (
	[SubscriptionProductId] BIGINT NOT NULL
	, [SubscriptionProductGrossMRR] DECIMAL(18,2) NOT NULL
	, [SubscriptionProductNetMRR] DECIMAL(18,2) NOT NULL
	, [SubscriptionProductIncludedStatus] VARCHAR(50) NOT NULL
	, [SubscriptionProductQuantity] DECIMAL(18,6) NOT NULL
	, [SubscriptionProductAmount] DECIMAL(18,2) NOT NULL
	, [SubscriptionStatusId] INT NOT NULL
	, [SubscriptionActivationDate] DATETIME NULL
	, [SubscriptionCancellationDate] DATETIME NULL
	, [SubscriptionContractStartTimestamp] DATETIME NULL
	, [SubscriptionContractEndTimestamp] DATETIME NULL
	, [SalesTrackingCode1Id] BIGINT NULL
	, [SalesTrackingCode2Id] BIGINT NULL
	, [SalesTrackingCode3Id] BIGINT NULL
	, [SalesTrackingCode4Id] BIGINT NULL
	, [SalesTrackingCode5Id] BIGINT NULL
	, [RemainingInterval] INT NULL
	, [ExpiredTimestamp] DATETIME NULL
	, [SubscriptionProductStatusId] INT NOT NULL
	, [SubscriptionProductCurrentMrr] MONEY NOT NULL
	, [SubscriptionProductCurrentNetMrr] MONEY NOT NULL
	, [SubscriptionExpiryTimestamp] DATETIME NULL
)

INSERT INTO #ProductsToBeJournaled
(
SubscriptionProductId,
SubscriptionProductGrossMRR,
SubscriptionProductNetMRR,
SubscriptionProductIncludedStatus,
SubscriptionProductQuantity,
SubscriptionProductAmount,
SubscriptionStatusId,
SubscriptionActivationDate,
SubscriptionCancellationDate,
SubscriptionContractStartTimestamp,
SubscriptionContractEndTimestamp,
SalesTrackingCode1Id,
SalesTrackingCode2Id,
SalesTrackingCode3Id,
SalesTrackingCode4Id,
SalesTrackingCode5Id,
RemainingInterval,
ExpiredTimestamp,
SubscriptionProductStatusId,
SubscriptionProductCurrentMrr,
SubscriptionProductCurrentNetMrr,
SubscriptionExpiryTimestamp)
SELECT
	sp.Id,
	sp.MonthlyRecurringRevenue,
	sp.NetMRR,
	CASE WHEN sp.Included = 1 THEN 'Included' ELSE 'Not Included' END,
	sp.Quantity,
	sp.Amount,
	s.StatusId,
	s.ActivationTimestamp,
	s.CancellationTimestamp,
	s.ContractStartTimestamp,
	s.ContractEndTimestamp,
	cr.SalesTrackingCode1Id,
	cr.SalesTrackingCode2Id,
	cr.SalesTrackingCode3Id,
	cr.SalesTrackingCode4Id,
	cr.SalesTrackingCode5Id,
	sp.RemainingInterval,
	sp.ExpiredTimestamp,
	sp.StatusId,
	sp.CurrentMrr,
	sp.CurrentNetMrr,
	s.ExpiredTimestamp
FROM SubscriptionProduct sp
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN CustomerReference cr ON cr.Id = s.CustomerId
join @subscriptionProductIds sf on sp.Id = sf.Id
LEFT JOIN #ProductsToBeJournaled tbd ON tbd.SubscriptionProductId = sp.Id
WHERE tbd.SubscriptionProductId IS NULL


--SELECT * FROM #ProductsToBeJournaled


INSERT INTO #LastRecordedJournalForDuplicateComparison
(
SubscriptionProductId,
SubscriptionProductGrossMRR,
SubscriptionProductNetMRR,
SubscriptionProductIncludedStatus,
SubscriptionProductQuantity,
SubscriptionProductAmount,
SubscriptionStatusId,
SubscriptionActivationDate,
SubscriptionCancellationDate,
SubscriptionContractStartTimestamp,
SubscriptionContractEndTimestamp,
SalesTrackingCode1Id,
SalesTrackingCode2Id,
SalesTrackingCode3Id,
SalesTrackingCode4Id,
SalesTrackingCode5Id,
RemainingInterval,
ExpiredTimestamp,
SubscriptionProductStatusId,
SubscriptionProductCurrentMrr,
SubscriptionProductCurrentNetMrr,
SubscriptionExpiryTimestamp)

SELECT 
	SubscriptionProductId,
	SubscriptionProductGrossMRR,
	SubscriptionProductNetMRR,
	SubscriptionProductIncludedStatus,
	SubscriptionProductQuantity,
	SubscriptionProductAmount,
	SubscriptionStatusId,
	SubscriptionActivationDate,
	SubscriptionCancellationDate,
	SubscriptionContractStartTimestamp,
	SubscriptionContractEndTimestamp,
	SalesTrackingCode1Id,
	SalesTrackingCode2Id,
	SalesTrackingCode3Id,
	SalesTrackingCode4Id,
	SalesTrackingCode5Id,
	RemainingInterval,
	ExpiredTimestamp,
	SubscriptionProductStatusId,
	SubscriptionProductCurrentMrr,
	SubscriptionProductCurrentNetMrr,
	SubscriptionExpiryTimestamp
FROM (
	SELECT 
	ROW_NUMBER() OVER( PARTITION BY spj.[SubscriptionProductId] ORDER BY [Id] DESC) AS [RowNumberDesc],
	spj.SubscriptionProductId,
	spj.SubscriptionProductGrossMRR,
	spj.SubscriptionProductNetMRR,
	spj.SubscriptionProductIncludedStatus,
	spj.SubscriptionProductQuantity,
	spj.SubscriptionProductAmount,
	spj.SubscriptionStatusId,
	spj.SubscriptionActivationDate,
	spj.SubscriptionCancellationDate,
	spj.SubscriptionContractStartTimestamp,
	spj.SubscriptionContractEndTimestamp,
	spj.SalesTrackingCode1Id,
	spj.SalesTrackingCode2Id,
	spj.SalesTrackingCode3Id,
	spj.SalesTrackingCode4Id,
	spj.SalesTrackingCode5Id,
	spj.RemainingInterval,
	spj.ExpiredTimestamp, 
	spj.SubscriptionProductStatusId,
	spj.SubscriptionProductCurrentMrr,
	spj.SubscriptionProductCurrentNetMrr,
	spj.SubscriptionExpiryTimestamp
	FROM SubscriptionProductJournal spj
	INNER JOIN #ProductsToBeJournaled tbd ON tbd.SubscriptionProductId = spj.SubscriptionProductId
) Data
WHERE Data.RowNumberDesc = 1


--SELECT * FROM #LastRecordedJournalForDuplicateComparison


DELETE FROM #ProductsToBeJournaled WHERE SubscriptionProductId IN (
	SELECT spj.SubscriptionProductId
	FROM #LastRecordedJournalForDuplicateComparison spj
	INNER JOIN #ProductsToBeJournaled tbd 
		ON spj.SubscriptionProductId = tbd.SubscriptionProductId
	AND spj.SubscriptionProductGrossMRR = tbd.SubscriptionProductGrossMRR 
	AND spj.SubscriptionProductNetMRR = tbd.SubscriptionProductNetMRR 
	AND spj.SubscriptionProductIncludedStatus = tbd.SubscriptionProductIncludedStatus 
	AND spj.SubscriptionProductQuantity = tbd.SubscriptionProductQuantity 
	AND spj.SubscriptionProductAmount = tbd.SubscriptionProductAmount 
	AND spj.SubscriptionStatusId = tbd.SubscriptionStatusId 
	AND ISNULL(spj.SubscriptionActivationDate, '1900-01-01') = ISNULL(tbd.SubscriptionActivationDate, '1900-01-01') 
	AND ISNULL(spj.SubscriptionCancellationDate, '1900-01-01') = ISNULL(tbd.SubscriptionCancellationDate, '1900-01-01') 
	AND ISNULL(spj.SubscriptionContractStartTimestamp, '1900-01-01') = ISNULL(tbd.SubscriptionContractStartTimestamp, '1900-01-01') 
	AND ISNULL(spj.SubscriptionContractEndTimestamp, '1900-01-01') = ISNULL(tbd.SubscriptionContractEndTimestamp, '1900-01-01') 
	AND ISNULL(spj.SalesTrackingCode1Id, -1) = ISNULL(tbd.SalesTrackingCode1Id, -1) 
	AND ISNULL(spj.SalesTrackingCode2Id, -1) = ISNULL(tbd.SalesTrackingCode2Id, -1) 
	AND ISNULL(spj.SalesTrackingCode3Id, -1) = ISNULL(tbd.SalesTrackingCode3Id, -1) 
	AND ISNULL(spj.SalesTrackingCode4Id, -1) = ISNULL(tbd.SalesTrackingCode4Id, -1) 
	AND ISNULL(spj.SalesTrackingCode5Id, -1) = ISNULL(tbd.SalesTrackingCode5Id, -1) 
	AND ISNULL(spj.RemainingInterval, -1) = ISNULL(tbd.RemainingInterval, -1) 
	AND ISNULL(spj.ExpiredTimestamp, '1900-01-01') = ISNULL(tbd.ExpiredTimestamp, '1900-01-01') 
	AND spj.SubscriptionProductStatusId = tbd.SubscriptionProductStatusId 
	AND spj.SubscriptionProductCurrentMrr = tbd.SubscriptionProductCurrentMrr 
	AND spj.SubscriptionProductCurrentNetMrr = tbd.SubscriptionProductCurrentNetMrr 
	AND ISNULL(spj.SubscriptionExpiryTimestamp, '1900-01-01') = ISNULL(tbd.SubscriptionExpiryTimestamp, '1900-01-01')
)


--SELECT * FROM #ProductsToBeJournaled


INSERT INTO SubscriptionProductJournal (
SubscriptionProductId,
SubscriptionProductGrossMRR,
SubscriptionProductNetMRR,
SubscriptionProductIncludedStatus,
SubscriptionProductQuantity,
SubscriptionProductAmount,
SubscriptionStatusId,
SubscriptionActivationDate,
SubscriptionCancellationDate,
SubscriptionContractStartTimestamp,
SubscriptionContractEndTimestamp,
SalesTrackingCode1Id,
SalesTrackingCode2Id,
SalesTrackingCode3Id,
SalesTrackingCode4Id,
SalesTrackingCode5Id,
RemainingInterval,
ExpiredTimestamp,
SubscriptionProductStatusId,
SubscriptionProductCurrentMrr,
SubscriptionProductCurrentNetMrr,
SubscriptionExpiryTimestamp,
CreatedTimestamp,
EffectiveTimestamp
)
SELECT 
SubscriptionProductId,
SubscriptionProductGrossMRR,
SubscriptionProductNetMRR,
SubscriptionProductIncludedStatus,
SubscriptionProductQuantity,
SubscriptionProductAmount,
SubscriptionStatusId,
SubscriptionActivationDate,
SubscriptionCancellationDate,
SubscriptionContractStartTimestamp,
SubscriptionContractEndTimestamp,
SalesTrackingCode1Id,
SalesTrackingCode2Id,
SalesTrackingCode3Id,
SalesTrackingCode4Id,
SalesTrackingCode5Id,
RemainingInterval,
ExpiredTimestamp,
SubscriptionProductStatusId,
SubscriptionProductCurrentMrr,
SubscriptionProductCurrentNetMrr,
SubscriptionExpiryTimestamp,
GETUTCDATE() as CreatedTimestamp,
ISNULL(@effectiveTimestamp, GETUTCDATE())
FROM #ProductsToBeJournaled

DROP TABLE #ProductsToBeJournaled
DROP TABLE #LastRecordedJournalForDuplicateComparison

GO

