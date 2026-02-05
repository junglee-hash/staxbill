CREATE   Procedure [dbo].[usp_GetDefaultPaymentMethod]
	@accountId bigint
	,@customerId bigint
AS

SELECT *,
	cbs.TermId as [Term],
	cbs.AutoCollectSettingTypeId as [AutoCollectSettingType],
	cbs.CustomerServiceStartOptionId as [CustomerServiceStartOption],
	cbs.RechargeTypeId as [RechargeType],
	cbs.HierarchySuspendOptionId as [HierarchySuspendOption],
	cbs.IntervalId as [Interval]
FROM CustomerBillingSetting cbs
WHERE cbs.Id = @customerId

DECLARE @paymentMethodId BIGINT
SELECT 
	@paymentMethodId = cbs.DefaultPaymentMethodId
FROM CustomerBillingSetting cbs
INNER JOIN Customer c ON c.Id = cbs.Id
WHERE c.Id = @customerId	
	AND c.AccountId = @accountId

SELECT
	epm.*
FROM ExternalPaymentMethod epm
WHERE epm.AccountId = @accountId
	AND epm.PaymentMethodId = @paymentMethodId

SELECT 
	pm.*
	,pm.PaymentMethodStatusId as PaymentMethodStatus
	,pm.PaymentMethodTypeid as PaymentMethodType
	,cc.*
FROM PaymentMethod pm
INNER JOIN CreditCard cc ON cc.Id = pm.Id
WHERE pm.Id = @paymentMethodId

SELECT 
	pm.*
	,pm.PaymentMethodStatusId as PaymentMethodStatus
	,pm.PaymentMethodTypeid as PaymentMethodType
	,ach.*
FROM PaymentMethod pm
INNER JOIN AchCard ach ON ach.Id = pm.Id
WHERE pm.Id = @paymentMethodId

SELECT
	pm.*
	,pm.PaymentMethodStatusId as PaymentMethodStatus
	,pm.PaymentMethodTypeid as PaymentMethodType
FROM PaymentMethod pm
WHERE pm.Id = @paymentMethodId

GO

