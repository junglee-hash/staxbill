CREATE         PROCEDURE [dbo].[usp_getIntegrationEntityDetailsPayments]  
  --required
@AccountId BIGINT,
@EffectiveTimestampStart DATETIME = NULL,
@EffectiveTimestampStartSet BIT,
@EffectiveTimestampEnd DATETIME = NULL,
@EffectiveTimestampEndSet BIT,
@NetsuiteErrorReason TINYINT, --0 means not filtering
@UseRefundTransactionsForNetsuite BIT,
@IntegrationType TINYINT, --only supports QBO (3) and NS (2)
@PageNumber BIGINT,
@PageSize BIGINT,
@ShowIgnoredWarnings BIT
AS  
 
SET TRANSACTION ISOLATION LEVEL SNAPSHOT  
SET NOCOUNT ON;  
 
DECLARE @EntityTypeId TINYINT
SET @EntityTypeId = 40 --paymentEntityType

IF (@IntegrationType NOT IN (2,3))
   BEGIN
       RAISERROR(N'Unexpected Integration Type',1,10);
       RETURN;
   END


SELECT DISTINCT
	p.Id
INTO #unpaginatedPayments 
FROM dbo.Payment p 
INNER JOIN [transaction] t ON t.Id = p.Id
INNER JOIN customer c ON c.Id = t.CustomerId
LEFT JOIN NetsuiteErrorLog nel ON nel.EntityId = p.Id AND nel.EntityTypeId = @EntityTypeId -- payment
LEFT JOIN IntegrationIgnoredWarning iiw ON iiw.EntityId = p.Id AND iiw.EntityTypeId = @EntityTypeId
WHERE t.AccountId = @AccountId
AND (@EffectiveTimestampEndSet = 0 OR t.EffectiveTimestamp < @EffectiveTimestampEnd)
AND (@EffectiveTimestampStartSet = 0 OR t.EffectiveTimestamp > @EffectiveTimestampStart)
AND (@IntegrationType <> 2 --If the integration type is NS (2) then the other half of this OR disjunction must be true:
		OR(@NetsuiteErrorReason = 0 OR nel.NetsuiteErrorReasonId = @NetsuiteErrorReason)
		AND (p.NetsuiteId IS NULL OR p.NetsuiteId = '')
		and p.SendToNetsuite = 1
		AND (c.NetsuiteId IS NOT NULL AND c.NetsuiteId <> '')
		AND (t.EffectiveTimestamp >= c.NetsuiteSyncTimestamp)
		AND (@UseRefundTransactionsForNetsuite = 1 OR p.RefundableAmount > 0)
	)
AND (@IntegrationType <> 3 --If the integration type is QBO (3) then the other half of this OR disjunction must be true:
		OR (p.QuickBooksId IS NULL OR p.QuickBooksId = '')
		AND (c.QuickBooksId IS NOT NULL AND c.QuickBooksId <> '')
		and (p.SendToQuickbooksOnline = 1)
		AND (t.EffectiveTimestamp > c.QuickBooksSyncTimestamp)
)
AND (@ShowIgnoredWarnings = 1 OR iiw.Id IS NULL)

 SELECT p.*
 INTO #payments FROM #unpaginatedPayments up
 INNER JOIN dbo.Payment p ON p.Id = up.Id
ORDER BY p.Id DESC
OFFSET ((@PageNumber) * @PageSize) ROWS
FETCH NEXT @PageSize ROWS ONLY

SELECT p.*
	,t.*
	,t.TransactionTypeId AS TransactionType
FROM #payments p
INNER JOIN [Transaction] t ON t.Id = p.Id

SELECT iiw.*
INTO #IntegrationWarnings FROM IntegrationIgnoredWarning iiw
INNER JOIN #payments p ON p.Id = iiw.EntityId
WHERE iiw.EntityTypeId = @EntityTypeId
AND iiw.IntegrationTypeId = @IntegrationType

SELECT *
FROM #IntegrationWarnings

SELECT DISTINCT c.* 
FROM [Credential] c
INNER JOIN [User] u on u.Id = c.UserId
INNER JOIN #IntegrationWarnings iw ON iw.UserId = u.Id

SELECT DISTINCT c.*, 
c.TitleId AS [title],
c.statusId AS [status],
c.AccountStatusId AS [accountStatus],
c.NetsuiteEntityTypeId AS [NetsuiteEntityType],
c.SalesforceAccountTypeId AS [SalesforceAccountType],
c.SalesforceSynchStatusId AS [SalesforceSynchStatus]
FROM Customer c
INNER JOIN [Transaction] t ON t.CustomerId = c.Id
INNER JOIN #payments p ON p.Id = t.Id

SELECT pn.* FROM PaymentNote pn
INNER JOIN #payments p ON pn.PaymentId = p.Id

SELECT DISTINCT i.* FROM Invoice i
INNER JOIN PaymentNote pn ON pn.InvoiceId = i.Id
INNER JOIN #payments p ON pn.PaymentId = p.Id

SELECT nel.* FROM NetsuiteErrorLog nel
INNER JOIN #payments p ON p.Id = nel.EntityId
AND nel.EntityTypeId = @EntityTypeId

SELECT qbl.* from QuickBooksLog qbl
INNER JOIN #payments p ON p.Id = qbl.EntityTypeId
WHERE qbl.Success = 0
AND qbl.EntityTypeId = @EntityTypeId

SELECT Count(1) AS [count] FROM #unpaginatedPayments AS [count]

DROP TABLE #unpaginatedPayments
DROP TABLE #IntegrationWarnings
DROP TABLE #payments

GO

