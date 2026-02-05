CREATE PROCEDURE [dbo].[usp_GetEntitiesMissingSalesforceId]
 @EntityTypeId int,
 @AccountId bigint,
 @JobId bigint
AS 

	SELECT isbr.EntityId AS EntityId 
	INTO #entities
	FROM [dbo].[IntegrationSynchJob] isj
	INNER JOIN [dbo].[IntegrationSynchBatch] isb on isb.IntegrationSynchJobId = isj.Id
	INNER JOIN dbo.IntegrationSynchBatchRecord isbr on isbr.IntegrationSynchBatchId = isb.Id
	Where 
		isj.AccountId = @AccountId 
		and isbr.EntityTypeId = @EntityTypeId
		and isj.Id = @JobId

   IF(@EntityTypeId = '3') 
      SELECT Id FROM dbo.Customer c
	  INNER JOIN #entities e ON c.Id = e.EntityId
	  WHERE AccountId = @AccountId AND (SalesforceId IS NULL OR SalesforceId = '')


   IF(@EntityTypeId = '7')
	  SELECT sub.Id FROM dbo.Subscription sub 
	  INNER JOIN dbo.Customer cus ON cus.Id = sub.CustomerId
	  INNER JOIN #entities e ON sub.Id = e.EntityId
	  WHERE cus.AccountId = @AccountId AND (sub.SalesforceId IS NULL OR sub.SalesforceId = '')


	IF(@EntityTypeId = '11')
		SELECT inv.Id FROM dbo.Invoice inv
		INNER JOIN #entities e ON inv.Id = e.EntityId
		WHERE inv.AccountId = @AccountId AND (inv.SalesforceId IS NULL OR inv.SalesforceId = '')

	IF(@EntityTypeId = '14')
		SELECT subpro.Id FROM dbo.SubscriptionProduct subpro 
		INNER JOIN dbo.Subscription sub ON subpro.SubscriptionId = sub.Id 
		INNER JOIN dbo.Customer cus  ON cus.Id = sub.CustomerId	  
		INNER JOIN #entities e ON subpro.Id = e.EntityId
		WHERE cus.AccountId = @AccountId AND (subpro.SalesforceId IS NULL OR subpro.SalesforceId = '') 

	IF(@EntityTypeId = '21')
		SELECT p.Id FROM dbo.Purchase p 
		INNER JOIN dbo.Customer cus  ON cus.Id = p.CustomerId	
		INNER JOIN #entities e ON p.Id = e.EntityId  
		WHERE cus.AccountId = @AccountId AND (p.SalesforceId IS NULL OR p.SalesforceId = '')


Drop table #entities

GO

