
CREATE PROCEDURE [dbo].[usp_TaxReportSummary]
@AccountId bigint 
,@UTCStartDateTime datetime = NULL
,@UTCEndDateTime datetime = NULL
,@TaxRuleId bigint = null
,@SortField varchar (60) = null
,@SortOrder varchar (4) = null
,@PageNumber int = 0 
,@PageSize int = 10
,@CurrencyId bigint
AS
DECLARE 
       @SQL nvarchar (max)
       ,@RowStart int = 0
       ,@RowEnd int = 10
	   ,@TaxOptionId TINYINT

set @RowStart = @PageSize * @PageNumber +1
set @RowEnd = @RowStart + @PageSize

IF @SortField not in
(
       'TaxRule'
       ,'OpeningTaxes'
       ,'TaxesChargedInPeriod'
       ,'TaxReversalsInPeriod'
       ,'NetChargesInPeriod'
       ,'ClosingTaxesPayable'
) or @SortField = null
       SET @SortField = 'TaxRule'

IF @SortOrder in
(
       'd'
       ,'Desc'
       ,'Descending'
) set @SortOrder = 'Desc'
ELSE IF @SortOrder is null
       set @SortOrder = 'Desc'
ELSE
       set @SortOrder = 'Asc'



if @UTCStartDateTime is null or @UTCEndDateTime is null
       BEGIN
       select @UTCStartDateTime = 
              convert(date,convert(char(4),DATEPART(year,dateadd(month,-1, dbo.fn_GetTimezoneTime ( GETUTCDATE(),TimezoneId)))) + '-'
              + convert(char(2),DATEPART(month,dateadd(month,-1, dbo.fn_GetTimezoneTime ( GETUTCDATE(),TimezoneId)))) + '-01')
       from AccountPreference 
       Where Id = @AccountId
       set @UTCEndDateTime = DATEADD(day,-1, DATEADD(month,1,@UTCStartDateTime))
       END

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
SET NOCOUNT ON;

SELECT @TaxOptionId = TaxOptionId
FROM AccountFeatureConfiguration
WHERE Id = @AccountId

SELECT
	t.Id
	,t.Amount
	,t.TransactionTypeId
	,t.EffectiveTimestamp
INTO #TaxTransactions
FROM [Transaction] t 
WHERE t.AccountId = @AccountId
       and t.EffectiveTimestamp < @UTCEndDateTime 
       and t.CurrencyId = @CurrencyId	   
	   AND t.TransactionTypeId IN (11,12,30)
	   AND t.Amount > 0

;WITH Taxes AS
(
	SELECT
		   tx.TaxRuleId
		   ,SUM(CASE WHEN t.EffectiveTimestamp < @UTCStartDateTime THEN t.amount ELSE 0 END) as OpeningAmount
		   ,SUM(CASE WHEN t.EffectiveTimestamp >= @UTCStartDateTime THEN t.amount ELSE 0 END) as AmountInPeriod
	FROM
		TaxRule tr
		INNER JOIN Tax tx ON tx.TaxRuleId = tr.Id
		   inner join #TaxTransactions t
		   on tx.Id = t.id
	WHERE
		t.TransactionTypeId = 11
		AND tr.AccountId = @AccountId
		AND ISNULL(@TaxRuleId,tx.TaxRuleId) = tx.TaxRuleId
	GROUP BY 
		   tx.TaxRuleId		   
),
ReverseTaxes AS
(
	SELECT
		   tx.TaxRuleId
		   ,SUM(CASE WHEN t.EffectiveTimestamp < @UTCStartDateTime THEN t.amount ELSE 0 END) as OpeningAmount
		   ,SUM(CASE WHEN t.EffectiveTimestamp >= @UTCStartDateTime THEN t.amount ELSE 0 END) as AmountInPeriod
	FROM
		TaxRule tr
		INNER JOIN Tax tx ON tx.TaxRuleId = tr.Id
		INNER JOIN ReverseTax rtx ON rtx.OriginalTaxId = tx.Id
		   inner join #TaxTransactions t
		   on rtx.Id = t.id
	WHERE
		t.TransactionTypeId = 12
		AND tr.AccountId = @AccountId
		AND ISNULL(@TaxRuleId,tx.TaxRuleId) = tx.TaxRuleId
	GROUP BY 
		   tx.TaxRuleId
),
VoidReverseTaxes AS
(
	SELECT
       tx.TaxRuleId
       ,SUM(CASE WHEN t.EffectiveTimestamp < @UTCStartDateTime THEN t.amount ELSE 0 END) as OpeningAmount
		,SUM(CASE WHEN t.EffectiveTimestamp >= @UTCStartDateTime THEN t.amount ELSE 0 END) as AmountInPeriod
	FROM
		   TaxRule tr
			INNER JOIN Tax tx ON tx.TaxRuleId = tr.Id
		   inner join ReverseTax 
		   on tx.Id = ReverseTax.OriginalTaxId
		   inner join VoidReverseTax
		   on ReverseTax.Id = VoidReverseTax.OriginalReverseTaxId
		   inner join #TaxTransactions t
		   on VoidReverseTax.id = t.Id		   
	WHERE
		t.TransactionTypeId = 30
		AND tr.AccountId = @AccountId
		AND ISNULL(@TaxRuleId,tx.TaxRuleId) = tx.TaxRuleId
	GROUP BY 
		   tx.TaxRuleId

)
SELECT
	tr.Id as TaxRuleId
	,CASE WHEN @TaxOptionId = 2 THEN tr.TaxCode
			  ELSE tr.Name + CASE WHEN tr.Description IS NOT NULL THEN + ' - ' + tr.Description END 
			+' ' + coalesce(tr.RegistrationCode, '') +' '  +' (' +convert(varchar (10),cast(cast(tr.Percentage as Decimal (10,8))*100 as decimal (10,4))) +'%)'
			END as TaxRule
	,SUM(ISNULL(tx.OpeningAmount,0))
		- SUM(ISNULL(rtx.OpeningAmount,0))
		+ SUM(ISNULL(vrtx.OpeningAmount,0))
		as OpeningTaxes
	,SUM(ISNULL(tx.AmountInPeriod,0)) as TaxesChargedInPeriod
	,SUM(ISNULL(rtx.AmountInPeriod,0))
		- SUM(ISNULL(vrtx.AmountInPeriod,0)) as TaxReversalsInPeriod
	,SUM(ISNULL(tx.AmountInPeriod,0)) 
	- SUM(ISNULL(rtx.AmountInPeriod,0))
		+ SUM(ISNULL(vrtx.AmountInPeriod,0)) as NetChargesInPeriod
	,SUM(ISNULL(tx.OpeningAmount,0))
		- SUM(ISNULL(rtx.OpeningAmount,0))
		+ SUM(ISNULL(vrtx.OpeningAmount,0))
	+ SUM(ISNULL(tx.AmountInPeriod,0)) 
	- SUM(ISNULL(rtx.AmountInPeriod,0))
		+ SUM(ISNULL(vrtx.AmountInPeriod,0)) as ClosingTaxesPayable
INTO #Report
FROM TaxRule tr
LEFT JOIN Taxes tx ON tx.TaxRuleId = tr.Id
LEFT JOIN ReverseTaxes rtx ON tr.Id = rtx.TaxRuleId
LEFT JOIN VoidReverseTaxes vrtx ON tr.Id = vrtx.TaxRuleId
WHERE tr.AccountId = @AccountId
	AND ISNULL(@TaxRuleId, tr.Id) = tr.Id
GROUP BY tr.Id
	,tr.Name
	,tr.TaxCode
	,tr.RegistrationCode
	,tr.Percentage
	,tr.Description

SET @SQL = '
SELECT  
              TaxRuleId
       ,TaxRule
       ,OpeningTaxes
       ,TaxesChargedInPeriod
       ,TaxReversalsInPeriod
       ,NetChargesInPeriod
       ,ClosingTaxesPayable
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY ' +isnull(@SortField,'TaxRule') + ' ' +isnull(@SortOrder,'asc') + ' ) AS RowNum, *
FROM
(


SELECT
        TaxRuleId
       ,TaxRule
       ,OpeningTaxes
       ,TaxesChargedInPeriod
       ,TaxReversalsInPeriod
       ,NetChargesInPeriod
       ,ClosingTaxesPayable
FROM
       #Report
)Result
)RowConstrainedResult


'
set @SQL = @SQL +  '
WHERE   RowNum >= ' + convert(varchar (20), isnull(@RowStart,1)) + '
    AND RowNum < ' +  convert(varchar (20),isnull(@RowEnd,25)) + ' 
ORDER BY RowNum 
'

exec sp_executesql @SQL

DROP TABLE #TaxTransactions
DROP TABLE #Report

GO

