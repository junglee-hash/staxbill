
CREATE   PROCEDURE [dbo].[usp_GetCustomerDashboard]
 @CustomerId bigint
 , @AccountId bigint
 , @IncludeStc bit
AS
BEGIN
 -- SET NOCOUNT ON added to prevent extra result sets from
 -- interfering with SELECT statements.
 SET NOCOUNT ON;

 SELECT c.*
  , c.AccountStatusId as AccountStatus
  , c.NetsuiteEntityTypeId as NetsuiteEntityType
  , c.SageIntacctLatchTypeId as SageIntacctLatchType
  , c.QuickBooksLatchTypeId as QuickBooksLatchType
  , c.SalesforceAccountTypeId as SalesforceAccountType
  , c.SalesforceSynchStatusId as SalesforceSynchStatus
  , c.StatusId as [Status]
  , c.TitleId as [Title]
   FROM [dbo].[Customer] c  WHERE Id = @CustomerId
  AND AccountId = @AccountId
  And c.IsDeleted = 0

  EXEC usp_GetCustomerOverviewWithFinancials @AccountId, @CustomerId

 SELECT
  cbs.*
  , cbs.TermId as Term
  , cbs.CustomerServiceStartOptionId as CustomerServiceStartOption
  , cbs.IntervalId as Interval
  , cbs.RechargeTypeId as RechargeType
  , cbs.HierarchySuspendOptionId as HierarchySuspendOption
 FROM CustomerBillingSetting cbs
 INNER JOIN Customer c ON c.Id = cbs.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  cis.*
  , [TrackedItemDisplayFormatId] as TrackedItemDisplayFormat
 FROM CustomerInvoiceSetting cis
 INNER JOIN Customer c ON c.Id = cis.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  cbss.*,
  OptionId as [Option],
  TypeId as [Type],
  IntervalId as [Interval],
  TrackedItemDisplayFormatId as TrackedItemDisplayFormat,
  StatementActivityTypeId as [StatementActivityType]
 FROM CustomerBillingStatementSetting cbss
 INNER JOIN Customer c ON c.Id = cbss.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  cbpc.*
  , cbpc.IntervalId as [Interval]
  , cbpc.RuleId as [Rule]
  , cbpc.TypeId as [Type]
 FROM CustomerBillingPeriodConfiguration cbpc
 INNER JOIN Customer c ON c.Id = cbpc.CustomerBillingSettingId
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  cap.*
 FROM CustomerAddressPreference cap
 INNER JOIN Customer c ON c.Id = cap.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  a.*
  , a.AddressTypeId as AddressType
  , a.Country as Country1
  , a.State as State1
 FROM [Address] a
 INNER JOIN Customer c ON c.Id = a.CustomerAddressPreferenceId
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT TOP 3
  cn.*
 FROM CustomerNote cn
 INNER JOIN Customer c ON c.Id = cn.CustomerId
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0
 ORDER BY cn.ModifiedTimestamp DESC

 select 
  u.*
 FROM CustomerNote cn
 INNER JOIN Customer c ON c.Id = cn.CustomerId
 join [User] u on u.Id = cn.UserId
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  pm.*
  , pm.PaymentMethodStatusId as PaymentMethodStatus
  , pm.PaymentMethodTypeId as PaymentMethodType
  , cc.*
 FROM CustomerBillingSetting cbs
 INNER JOIN PaymentMethod pm ON cbs.DefaultPaymentMethodId = pm.Id
 INNER JOIN Customer c ON c.Id = cbs.Id
 INNER JOIN CreditCard cc ON cc.Id = pm.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  pm.*
  , pm.PaymentMethodStatusId as PaymentMethodStatus
  , pm.PaymentMethodTypeId as PaymentMethodType
  , ach.*
 FROM CustomerBillingSetting cbs
 INNER JOIN PaymentMethod pm ON cbs.DefaultPaymentMethodId = pm.Id
 INNER JOIN Customer c ON c.Id = cbs.Id
 INNER JOIN AchCard ach ON ach.Id = pm.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND c.IsDeleted = 0

 SELECT
  pm.*
  , pm.PaymentMethodStatusId as PaymentMethodStatus
  , pm.PaymentMethodTypeId as PaymentMethodType
 FROM CustomerBillingSetting cbs
 INNER JOIN PaymentMethod pm ON cbs.DefaultPaymentMethodId = pm.Id
 INNER JOIN Customer c ON c.Id = cbs.Id
 WHERE c.Id = @CustomerId
  AND c.AccountId = @AccountId
  AND pm.PaymentMethodTypeId = 6
  AND c.IsDeleted = 0

 CREATE TABLE #CustomerCounts
 (
  CountOfActiveSubscriptions int
  , CountOfAllSubscriptions int
  , CountOfPendingPurchases int
  , CountOfProjectedInvoices int
  , CountOfDraftInvoices int
  , CountOfCurrentInvoices int
  , CountOfChildCustomers int
  , CountOfHistoricalInvoices int
  , CountOfParentOwnedSubscriptions int
 )

 INSERT INTO #CustomerCounts
 VALUES (0, 0, 0, 0, 0, 0, 0, 0, 0)

 UPDATE cc SET
  cc.CountOfActiveSubscriptions = Data.CountOfActiveSubscriptions
  , cc.CountOfAllSubscriptions = Data.CountOfAllSubscriptions
  , cc.CountOfParentOwnedSubscriptions = Data.CountOfParentOwnedSubscriptions
 FROM #CustomerCounts cc
 INNER JOIN (
  SELECT
   c.Id
   , SUM(CASE WHEN s.StatusId = 2 THEN 1 ELSE 0 END) as CountOfActiveSubscriptions
   , COUNT(s.Id) as CountOfAllSubscriptions
   , SUM(CASE WHEN s.CustomerId != bpd.CustomerId THEN 1 ELSE 0 END) as CountOfParentOwnedSubscriptions
  FROM Subscription s
  INNER JOIN Customer c ON c.Id = @CustomerId
   AND c.AccountId = @AccountId
   AND c.Id = s.CustomerId
   INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
  WHERE s.IsDeleted = 0
  GROUP BY c.Id
 ) Data ON Data.Id = @CustomerId

 UPDATE cc SET
  cc.CountOfPendingPurchases = Data.CountOfPendingPurchases
 FROM #CustomerCounts cc
 INNER JOIN (
  SELECT
   c.Id
   , SUM(CASE WHEN p.StatusId = 1 THEN 1 ELSE 0 END) as CountOfPendingPurchases
  FROM Purchase p
  INNER JOIN Customer c ON c.Id = @CustomerId
   AND c.AccountId = @AccountId
   AND c.Id = p.CustomerId
  WHERE p.IsDeleted = 0
  GROUP BY c.Id
 ) Data ON Data.Id = @CustomerId

 UPDATE cc SET
  cc.CountOfProjectedInvoices = Data.CountOfProjectedInvoices
  , cc.CountOfDraftInvoices = Data.CountOfDraftInvoices
 FROM #CustomerCounts cc
 INNER JOIN (
  SELECT
   c.Id
   , SUM(CASE WHEN i.DraftInvoiceStatusId = 5 THEN 1 ELSE 0 END) as CountOfProjectedInvoices
   , SUM(CASE WHEN i.DraftInvoiceStatusId IN (1,2) THEN 1 ELSE 0 END) as CountOfDraftInvoices
  FROM DraftInvoice i
  INNER JOIN Customer c ON c.Id = @CustomerId
   AND c.AccountId = @AccountId
   AND c.Id = i.CustomerId
  GROUP BY c.Id
 ) Data ON Data.Id = @CustomerId

 UPDATE cc SET
  cc.CountOfCurrentInvoices = Data.CountOfCurrentInvoices
  , cc.CountOfHistoricalInvoices = Data.CountOfHistoricalInvoices
 FROM #CustomerCounts cc
 INNER JOIN (
  SELECT
   i.CustomerId
   , SUM(CASE WHEN ps.StatusId IN (1,2,3,6) THEN 1 ELSE 0 END) AS CountOfCurrentInvoices
   , SUM(CASE WHEN ps.StatusId NOT IN (2, 3, 6) THEN 1 ELSE 0 END) AS CountOfHistoricalInvoices
  FROM Invoice i
  INNER JOIN PaymentSchedule ps ON i.Id = ps.InvoiceId
  WHERE i.CustomerId = @CustomerId
   AND i.AccountId = @AccountId
  GROUP BY i.CustomerId
 ) Data ON Data.CustomerId = @CustomerId

 UPDATE cc SET
  CountOfChildCustomers = Data.CountOfChildCustomers
 FROM #CustomerCounts cc
 INNER JOIN (
  SELECT
   c.ParentId
   , COUNT(c.Id) as CountOfChildCustomers
  FROM Customer c
  WHERE c.ParentId = @CustomerId
   AND c.AccountId = @AccountId
  GROUP BY c.ParentId
 ) Data ON Data.ParentId = @CustomerId

 SELECT * FROM #CustomerCounts

 SELECT COUNT(*) as customerTransactionCount FROM [dbo].[Transaction] WHERE customerId = @CustomerId

 -- Future note: I can see this not filtered to a category and return a list of failures for a customer...
 SELECT *
 FROM AccountAutomatedHistoryFailure
 WHERE AccountId = @AccountId
	AND CustomerId = @CustomerId
	AND AccountAutomatedHistoryTypeId = 12 --Billing

SELECT * FROM CustomerAcquisition 
WHERE Id = @CustomerId

SELECT * FROM CustomerReference 
WHERE Id = @CustomerId

IF @IncludeStc = 1
BEGIN

	SELECT sc1.*
		  ,sc1.[TypeId] as [Type]
		  ,sc1.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc1
	INNER JOIN CustomerReference cr ON sc1.Id = cr.SalesTrackingCode1Id
	WHERE cr.Id = @CustomerId
	UNION ALL
	SELECT sc2.*
		  ,sc2.[TypeId] as [Type]
		  ,sc2.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc2
	INNER JOIN CustomerReference cr ON sc2.Id = cr.SalesTrackingCode2Id
	WHERE cr.Id = @CustomerId
	UNION ALL
	SELECT sc3.*
		  ,sc3.[TypeId] as [Type]
		  ,sc3.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc3
	INNER JOIN CustomerReference cr ON sc3.Id = cr.SalesTrackingCode3Id
	WHERE cr.Id = @CustomerId
	UNION ALL
	SELECT sc4.*
		  ,sc4.[TypeId] as [Type]
		  ,sc4.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc4
	INNER JOIN CustomerReference cr ON sc4.Id = cr.SalesTrackingCode4Id
	WHERE cr.Id = @CustomerId
	UNION ALL
	SELECT sc5.*
		  ,sc5.[TypeId] as [Type]
		  ,sc5.[StatusId] as [Status]
	  FROM [dbo].[SalesTrackingCode] sc5
	INNER JOIN CustomerReference cr ON sc5.Id = cr.SalesTrackingCode5Id
	WHERE cr.Id = @CustomerId

END

 DROP TABLE #CustomerCounts
END

GO

