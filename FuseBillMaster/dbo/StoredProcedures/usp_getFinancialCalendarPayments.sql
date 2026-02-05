CREATE PROCEDURE [dbo].[usp_getFinancialCalendarPayments]
	@AccountId BIGINT
	,@CurrencyId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
	,@FullCustomerDetails BIT
	,@Attempt VARCHAR(10) = NULL
	,@SalesTrackingCodeType INT = NULL      
	,@SalesTrackingCodeId BIGINT = NULL  
	,@StatusId int
AS

DECLARE @SQL NVARCHAR (max)  

SET @SQL = '
DECLARE @TimezoneId INT

SELECT 
	@StartDate = dbo.fn_GetUtcTime (@StartDate,TimezoneId)
	,@EndDate = dbo.fn_GetUtcTime (@EndDate,TimezoneId)
	,@TimezoneId = TimezoneId
FROM 
	AccountPreference 
WHERE 
	Id = @AccountId

SELECT * INTO #CustomerData ' 

IF @FullCustomerDetails = 0
BEGIN
	SET @SQL = @SQL + 'FROM dbo.BasicCustomerDataByAccount(@AccountId)'
END

IF @FullCustomerDetails = 1
BEGIN
	SET @SQL = @SQL + 'FROM dbo.FullCustomerDataByAccount(@AccountId, null, GETUTCDATE())'
END

IF @Attempt = ''
BEGIN
	SET @Attempt = NULL
END

SET @SQL = @SQL + '
;WITH ReportData AS
(
SELECT
	pt.Name as PaymentType
	,ps.Name as PaymentSource
	,ISNULL(pm.AccountType,pmt.Name) as PaymentMethod
	,pmt.Name as PaymentMethodType
	,paj.Amount as PaymentAmount
	,CASE WHEN ParentCustomerId IS NOT NULL THEN ''Yes'' ELSE '''' END as ParentPaymentMethod
	,CASE WHEN AttemptNumber = 0 THEN ''Initial'' ELSE ''Retry'' END as Attempt
	,paj.SecondaryTransactionNumber
	,paj.AuthorizationResponse as AuthResponse
	,paj.AuthorizationCode as AuthCode
	,EffectiveTimestamp.TimezoneDateTime as EffectiveDate
	,pas.Name as PaymentActivityStatus
	,p.Id as TransactionId
	,cd.*
FROM PaymentActivityJournal paj
INNER JOIN Customer c ON c.Id = paj.CustomerId
LEFT JOIN PaymentMethod pm ON pm.Id = paj.PaymentMethodId'

SET @SQL = @SQL +
CASE WHEN @SalesTrackingCodeType IS NOT NULL THEN      
  ' INNER JOIN CustomerReference cr ON cr.Id = cl.CustomerId' ELSE '' END +      
 CASE WHEN @SalesTrackingCodeType = 1 THEN      
  ' AND cr.SalesTrackingCode1Id = @SalesTrackingCodeId' ELSE '' END +      
 CASE WHEN @SalesTrackingCodeType = 2 THEN      
  ' AND cr.SalesTrackingCode2Id = @SalesTrackingCodeId' ELSE '' END +      
 CASE WHEN @SalesTrackingCodeType = 3 THEN      
  ' AND cr.SalesTrackingCode3Id = @SalesTrackingCodeId' ELSE '' END +      
 CASE WHEN @SalesTrackingCodeType = 4 THEN      
  ' AND cr.SalesTrackingCode4Id = @SalesTrackingCodeId' ELSE '' END +      
 CASE WHEN @SalesTrackingCodeType = 5 THEN      
  ' AND cr.SalesTrackingCode5Id = @SalesTrackingCodeId' ELSE '' END  


SET @SQL = @SQL + '
INNER JOIN #CustomerData cd ON c.Id = cd.[Fusebill ID] 
CROSS APPLY Timezone.tvf_GetTimezoneTime (@TimezoneId,paj.EffectiveTimestamp) EffectiveTimestamp
INNER JOIN Lookup.PaymentType pt ON pt.Id = paj.PaymentTypeId
INNER JOIN Lookup.PaymentSource ps ON ps.Id = paj.PaymentSourceId
INNER JOIN Lookup.PaymentMethodType pmt ON pmt.Id = paj.PaymentMethodTypeId
INNER JOIN Lookup.PaymentActivityStatus pas ON pas.Id = paj.PaymentActivityStatusId
left JOIN Payment p ON paj.Id = p.PaymentActivityJournalId
WHERE c.AccountId = @AccountId
	AND paj.CurrencyId = @CurrencyId
	AND paj.PaymentTypeId = 2
	AND paj.EffectiveTimestamp >= @StartDate
	AND paj.EffectiveTimestamp < @EndDate
	'
	if @StatusId = 2
		set @SQL = @SQL + 'AND paj.PaymentActivityStatusId = @StatusId'
	if @StatusId = 1
		set @SQL = @SQL + 'AND paj.PaymentActivityStatusId in (1, 4, 5, 6, 7, 8, 9)'

set @SQL = @SQL + '
)

SELECT
	*
FROM ReportData
WHERE ISNULL(@Attempt,Attempt) = Attempt
' 

EXEC sp_executesql @SQL, N'@AccountId bigint, @CurrencyId bigint, @SalesTrackingCodeId bigint, @StartDate datetime, @EndDate datetime,@Attempt VARCHAR(10), @StatusId int', @AccountId, @CurrencyId, @SalesTrackingCodeId, @StartDate, @EndDate, @Attempt, @StatusId

GO

