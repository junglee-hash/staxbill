CREATE   PROCEDURE [dbo].[usp_getInvoicesAgedByDateAndCollectionLikelihoodSummary]
    @AccountId bigint
    ,@CurrencyId bigint
    ,@SalesTrackingCodeType int = null
    ,@SalesTrackingCodeId bigint = null
AS

-- Not sure if this is needed anymore..
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET ARITHABORT ON
--SET FMTONLY OFF

DECLARE
    @AccountBalance DECIMAL(18,2),
    @AccountBalance2 DECIMAL(18,2);

SELECT
    @AccountBalance = SUM(SumDebit - SumCredit)
FROM [dbo].[tvf_CustomerLedgersByLedgerType] (@AccountId, @CurrencyId, NULL, GETUTCDATE(), 1) cl
INNER JOIN CustomerReference cr ON cr.Id = cl.CustomerId
WHERE @SalesTrackingCodeType IS NULL OR
(
    cr.SalesTrackingCode1Id = (CASE WHEN @SalesTrackingCodeType = 1 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode1Id END)
    AND cr.SalesTrackingCode2Id = (CASE WHEN @SalesTrackingCodeType = 2 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode2Id END)
    AND cr.SalesTrackingCode3Id = (CASE WHEN @SalesTrackingCodeType = 3 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode3Id END)
    AND cr.SalesTrackingCode4Id = (CASE WHEN @SalesTrackingCodeType = 4 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode4Id END)
    AND cr.SalesTrackingCode5Id = (CASE WHEN @SalesTrackingCodeType = 5 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode5Id END)
)

SELECT 
    ps.Id as PaymentScheduleId
	,ps.InvoiceId
	,ps.OutstandingBalance
	,CAST(DATEDIFF(HOUR, ps.DueDate, GETUTCDATE()) AS DECIMAL(20,2)) / 24 AS DaysOld
	,c.Id as CustomerId
INTO #PaymentSchedules
FROM PaymentSchedule ps
INNER JOIN Invoice i ON ps.InvoiceId = i.Id
INNER JOIN Customer c ON c.id = i.CustomerId
WHERE
    i.AccountId = @AccountId
    AND c.CurrencyId = @CurrencyId
    AND c.AccountId = @AccountId
	AND ps.OutstandingBalance > 0
    AND ps.StatusId NOT IN (4,5,7);

SELECT
    CollectionLikelihood
    ,ISNULL(SUM(ISNULL(DueWithinTerms,0))
        + SUM(ISNULL(ZeroToThirtyDaysPastDue,0))
        + SUM(ISNULL(ThirtyOneToSixtyDaysPastDue,0))
        + SUM(ISNULL(SixtyOneToNinetyDaysPastDue,0))
        + SUM(ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0))
        + SUM(ISNULL(MoreThanOneHundredTwentyDaysPastDue,0))
        , 0) AS CollectionLikelihoodTotalAmount
    ,ISNULL(SUM(ISNULL(DueWithinTerms,0)),0) AS DueWithinTerms
	,COUNT(DueWithinTerms) as DueWithinTermsCount
    ,ISNULL(SUM(ISNULL(ZeroToThirtyDaysPastDue,0)),0) AS ZeroToThirtyDaysPastDue
	,COUNT(ZeroToThirtyDaysPastDue) as ZeroToThirtyDaysPastDueCount
    ,ISNULL(SUM(ISNULL(ThirtyOneToSixtyDaysPastDue,0)),0) AS ThirtyOneToSixtyDaysPastDue
	,COUNT(ThirtyOneToSixtyDaysPastDue) as ThirtyOneToSixtyDaysPastDueCount
    ,ISNULL(SUM(ISNULL(SixtyOneToNinetyDaysPastDue,0)),0) AS SixtyOneToNinetyDaysPastDue
	,COUNT(SixtyOneToNinetyDaysPastDue) as SixtyOneToNinetyDaysPastDueCount
    ,ISNULL(SUM(ISNULL(NinetyOneToOneHundredTwentyDaysPastDue,0)),0) AS NinetyOneToOneHundredTwentyDaysPastDue
	,COUNT(NinetyOneToOneHundredTwentyDaysPastDue) as NinetyOneToOneHundredTwentyDaysPastDueCount
    ,ISNULL(SUM(ISNULL(MoreThanOneHundredTwentyDaysPastDue,0)),0) AS MoreThanOneHundredTwentyDaysPastDue
	,COUNT(MoreThanOneHundredTwentyDaysPastDue) as MoreThanOneHundredTwentyDaysPastDueCount
    FROM
    (
        SELECT
            c.CollectionLikelihood
            ,ISNULL(ps.OutstandingBalance, 0) AS AmountDue
            ,aps.Terms
			,c.Id as CustomerId
        FROM
			#PaymentSchedules ps
			INNER JOIN Customer c ON c.Id = ps.CustomerId
            INNER JOIN LOOKUP.InvoiceAgingPeriod aps ON ps.DaysOld >= aps.StartDay AND ps.DaysOld < aps.EndDay
            INNER JOIN CustomerReference cr ON cr.Id = ps.CustomerId
        WHERE 
            @SalesTrackingCodeType IS NULL OR
            (
                cr.SalesTrackingCode1Id = (CASE WHEN @SalesTrackingCodeType = 1 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode1Id END)
                AND cr.SalesTrackingCode2Id = (CASE WHEN @SalesTrackingCodeType = 2 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode2Id END)
                AND cr.SalesTrackingCode3Id = (CASE WHEN @SalesTrackingCodeType = 3 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode3Id END)
                AND cr.SalesTrackingCode4Id = (CASE WHEN @SalesTrackingCodeType = 4 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode4Id END)
                AND cr.SalesTrackingCode5Id = (CASE WHEN @SalesTrackingCodeType = 5 THEN @SalesTrackingCodeId ELSE cr.SalesTrackingCode5Id END)
            )
    ) Data
    PIVOT
    (
        SUM(AmountDue)
        FOR Terms IN
        (
            [DueWithinTerms]
            ,[ZeroToThirtyDaysPastDue]
            ,[ThirtyOneToSixtyDaysPastDue]
            ,[SixtyOneToNinetyDaysPastDue]
            ,[NinetyOneToOneHundredTwentyDaysPastDue]
            ,[MoreThanOneHundredTwentyDaysPastDue]
        )
    ) PivotTable
    GROUP BY
        CollectionLikelihood
	OPTION (RECOMPILE)

DROP TABLE #PaymentSchedules

GO

