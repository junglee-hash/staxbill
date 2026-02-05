
CREATE PROCEDURE [dbo].[Staffside_GetAchTokensForExport]
	@AccountId BIGINT
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT 
SET NOCOUNT ON

SELECT
	CONVERT(varchar,c.AccountId) as [Account ID]
	,CONVERT(varchar,c.Id) as [Fusebill ID]
	,pm.Token
	,CASE WHEN pm.Id = cbs.DefaultPaymentMethodId THEN 'TRUE' ELSE 'FALSE' END as [Default]
FROM PaymentMethod pm
INNER JOIN AchCard cc ON cc.Id = pm.Id
INNER JOIN Customer c ON c.Id = pm.CustomerId
INNER JOIN CustomerBillingSetting cbs ON c.Id = cbs.Id
WHERE AccountId = @AccountId
	AND pm.PaymentMethodStatusId = 1 --Active
	AND pm.StoredInFusebillVault = 1

GO

