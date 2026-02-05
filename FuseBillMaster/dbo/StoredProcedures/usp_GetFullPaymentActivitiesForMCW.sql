CREATE PROCEDURE [dbo].[usp_GetFullPaymentActivitiesForMCW]
	@Ids AS dbo.IDList READONLY,
	@AccountId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @paymentActivities table
	(
		PaymentActivityId bigint
	)
    DECLARE @invoices table
	(
		InvoiceId bigint
	)
    DECLARE @subscriptionProducts table
	(
		SubscriptionProductId bigint
	)
    DECLARE @subscriptions table
	(
		SubscriptionId bigint
	)

	INSERT INTO @paymentActivities (PaymentActivityId)
	SELECT Id FROM @Ids

	INSERT INTO @invoices
	SELECT i.Id FROM Invoice i
	INNER JOIN PaymentNote pn ON i.Id = pn.InvoiceId
	INNER JOIN Payment p ON p.Id = pn.PaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId
	UNION
	SELECT i.Id
	FROM Invoice i
	INNER JOIN RefundNote rn ON i.Id = rn.InvoiceId
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = r.PaymentActivityJournalId
	UNION
	SELECT i.Id
	FROM Invoice i
	INNER JOIN RefundNote rn ON i.Id = rn.InvoiceId
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId
	UNION
	SELECT i.Id
	FROM Invoice i
	INNER JOIN PaymentNoteAttempt pna ON i.Id = pna.InvoiceId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = pna.PaymentActivityJournalId
	UNION
	SELECT i.Id
	FROM Invoice i
	INNER JOIN RefundNoteAttempt pna ON i.Id = pna.InvoiceId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = pna.PaymentActivityJournalId

	INSERT INTO @subscriptionProducts
	SELECT DISTINCT SubscriptionProductId
	FROM SubscriptionProductCharge spc
	INNER JOIN Charge ch ON ch.Id = spc.Id
	INNER JOIN @invoices ii ON ii.InvoiceId = ch.InvoiceId

	INSERT INTO @subscriptions
	SELECT DISTINCT SubscriptionId
	FROM SubscriptionProduct sp
	INNER JOIN @subscriptionProducts subProd ON sp.Id = subProd.SubscriptionProductId

	SELECT paj.*
		, paj.PaymentActivityStatusId as PaymentActivityStatus
		, paj.PaymentMethodTypeId as PaymentMethodType
		, paj.PaymentSourceId as PaymentSource
		, paj.PaymentTypeId as PaymentType
		, paj.SettlementStatusId as SettlementStatus
		, paj.DisputeStatusId as DisputeStatus
	FROM PaymentActivityJournal paj
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id

	SELECT p.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	SELECT pn.*
	FROM PaymentNote pn
	INNER JOIN Payment p ON p.Id = pn.PaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	-- Get all refunds for payment activities
	SELECT r.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = r.PaymentActivityJournalId
	UNION
	-- Get all refunds for payments
	SELECT r.*
		, t.*
		, t.TransactionTypeId as TransactionType
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
	INNER JOIN Payment p ON p.Id = r.OriginalPaymentId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = p.PaymentActivityJournalId

	-- Get all refund notes for payment activities
	SELECT rn.*
	FROM RefundNote rn
	INNER JOIN Refund r ON r.Id = rn.RefundId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = r.PaymentActivityJournalId

	SELECT pn.*
	FROM PaymentNoteAttempt pn
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = pn.PaymentActivityJournalId

	SELECT pn.*
	FROM RefundNoteAttempt pn
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = pn.PaymentActivityJournalId

	SELECT i.*
	FROM Invoice i
	INNER JOIN @invoices ii ON i.Id = ii.InvoiceId

	SELECT ij.*
	FROM InvoiceJournal ij 
	INNER JOIN @invoices ii ON ij.InvoiceId = ii.InvoiceId
	WHERE ij.IsActive = 1

	SELECT ij.*
	FROM ChargeGroup ij 
	INNER JOIN @invoices ii ON ij.InvoiceId = ii.InvoiceId

	SELECT c.*
		, t.*
		, c.EarningTimingTypeId as EarningTimingType
		, c.EarningTimingIntervalId as EarningTimingInterval
		, t.TransactionTypeId as TransactionType
	FROM [dbo].[Charge] c
	INNER JOIN @invoices ii ON c.InvoiceId = ii.InvoiceId
	INNER JOIN [Transaction] t ON t.Id = c.Id

	SELECT cc.*
		, pm.*
		, pm.PaymentMethodStatusId as PaymentMethodStatus
		, pm.PaymentMethodTypeId as PaymentMethodType
	FROM CreditCard cc
	INNER JOIN PaymentMethod pm ON pm.Id = cc.Id
	INNER JOIN PaymentActivityJournal paj ON cc.Id = paj.PaymentMethodId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id

	SELECT ach.*
		, pm.*
		, pm.PaymentMethodStatusId as PaymentMethodStatus
		, pm.PaymentMethodTypeId as PaymentMethodType
	FROM AchCard ach
	INNER JOIN PaymentMethod pm ON pm.Id = ach.Id
	INNER JOIN PaymentActivityJournal paj ON ach.Id = paj.PaymentMethodId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id
	END

	SELECT spc.* FROM [dbo].[SubscriptionProductCharge] spc
	INNER JOIN @subscriptionProducts sp ON sp.SubscriptionProductId = spc.SubscriptionProductId
	INNER JOIN Charge ch ON ch.Id = spc.Id
	INNER JOIN @invoices ii ON ii.InvoiceId = ch.InvoiceId

	SELECT sp.*
      ,sp.[StatusId] as [Status]
      ,sp.[EarningTimingTypeId] as EarningTimingType
      ,sp.[EarningTimingIntervalId] as EarningTimingInterval
      ,[ProductTypeId] as ProductTypeId
      ,sp.[ResetTypeId] as ResetType
      ,[RecurChargeTimingTypeId] as RecurChargeTimingType
      ,[RecurProrateGranularityId] as RecurProrateGranularity
      ,[QuantityChargeTimingTypeId] as QuantityChargeTimingType
      ,[QuantityProrateGranularityId] as QuantityProrateGranularity
      ,[PricingModelTypeId] as PricingModelType
      ,[EarningIntervalId] as EarningInterval
	  ,sp.CustomServiceDateIntervalId as CustomServiceDateInterval
	  ,sp.CustomServiceDateProjectionId as CustomServiceDateProjection
	FROM [dbo].[SubscriptionProduct] sp
	INNER JOIN @subscriptionProducts subProd ON sp.Id = subProd.SubscriptionProductId
	 INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = sp.PlanProductUniqueId
	WHERE sp.StatusId != 2
	ORDER BY pp.SortOrder

	SELECT s.*
		,s.[StatusId] as [Status]
		,s.[IntervalId] as Interval
	FROM Subscription s
	INNER JOIN @subscriptions sub ON sub.SubscriptionId = s.Id

	SELECT scf.*
	FROM SubscriptionCustomField scf
	INNER JOIN @subscriptions sub ON sub.SubscriptionId = scf.SubscriptionId

	SELECT cf.*
		, cf.DataTypeId as [DataType]
		, cf.StatusId as [Status]
	FROM CustomField cf
	INNER JOIN SubscriptionCustomField scf ON cf.Id = scf.CustomFieldId
	INNER JOIN @subscriptions sub ON sub.SubscriptionId = scf.SubscriptionId

	SELECT c.*
		, c.AccountStatusId as AccountStatus
		, c.NetsuiteEntityTypeId as NetsuiteEntityType
		, c.QuickBooksLatchTypeId as QuickBooksLatchType
		, c.SalesforceAccountTypeId as SalesforceAccountType
		, c.SalesforceSynchStatusId as SalesforceSynchStatus
		, c.StatusId as [Status]
		, c.TitleId as [Title]
	FROM [dbo].[Customer] c
	INNER JOIN PaymentActivityJournal paj ON c.Id = paj.CustomerId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id

	SELECT cr.* 
	FROM CustomerReference cr
	INNER JOIN PaymentActivityJournal paj ON cr.Id = paj.CustomerId
	INNER JOIN @paymentActivities pa ON pa.PaymentActivityId = paj.Id

	SELECT stc.*
		  ,stc.[TypeId] as [Type]
		  ,stc.[StatusId] as [Status]	  
	FROM [dbo].[SalesTrackingCode] stc
	WHERE stc.AccountId = @AccountId

	SELECT scc.*
      ,scc.[StatusId] as [Status]
  FROM [dbo].[SubscriptionCouponCode] scc
  INNER JOIN @subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT DISTINCT cc.* FROM CouponCode cc
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  INNER JOIN @subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

  SELECT DISTINCT c.* 
	, c.StatusId as [Status]
  FROM Coupon c
  INNER JOIN CouponCode cc ON c.Id = cc.CouponId
  INNER JOIN SubscriptionCouponCode scc ON cc.Id = scc.CouponCodeId
  INNER JOIN @subscriptions ss ON scc.SubscriptionId = ss.SubscriptionId

GO

