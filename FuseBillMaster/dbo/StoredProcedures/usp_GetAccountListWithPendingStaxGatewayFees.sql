CREATE   PROCEDURE [dbo].[usp_GetAccountListWithPendingStaxGatewayFees]
	@startDate DATETIME,      
	@endDate DATETIME      
AS      
BEGIN      
-- SET NOCOUNT ON added to prevent extra result sets from      
-- interfering with SELECT statements.      
SET NOCOUNT ON;      
      
SELECT PaymentActivityJournalId      
INTO #pendingGatewayFees      
FROM Payment      
WHERE PendingGatewayFee= 1      
      
SELECT paj.Id, CustomerId, EffectiveTimestamp
INTO #paymentActivityJournal      
FROM PaymentActivityJournal paj INNER JOIN      
 #pendingGatewayFees p on paj.Id = p.PaymentActivityJournalId      
      
SELECT      
	DISTINCT(c.AccountId) AS AccountId      
FROM      
	#paymentActivityJournal paj      
	INNER JOIN Customer c ON c.Id = paj.CustomerId      
	INNER JOIN Account a ON a.Id = c.AccountId
WHERE      
	a.IncludeInAutomatedProcesses = 1 AND      
	NOT EXISTS (SELECT 1 FROM dbo.AccountFeatureConfiguration WHERE ID = c.AccountId AND StaxGatewayFeeRecording = 0) AND    
	--are there any failed stax fee processes encapsolate\being in between the dbs start and end date      
	NOT EXISTS (SELECT 1 FROM dbo.StaxGatewayFeeLogging WHERE AccountId = c.AccountId and Failed = 0 AND StartDate <= @startDate and EndDate >= @endDate)
ORDER BY      
	AccountId ASC      
      
DROP TABLE #pendingGatewayFees      
DROP TABLE #paymentActivityJournal      
END

GO

