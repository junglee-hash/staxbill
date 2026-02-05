CREATE Procedure [dbo].[usp_TaxReportSummaryCount]
@AccountId bigint 
,@UTCStartDateTime datetime = NULL
,@UTCEndDateTime datetime = NULL
,@CurrencyId bigint

AS

SELECT
       Count(Distinct tr.id) as Count
FROM
       TaxRule tr
WHERE
		AccountId = @AccountId

GO

