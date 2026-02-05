CREATE   PROCEDURE [dbo].[usp_IntegrationSyncableSubscriptionProducts]
	@isNetsuiteSync BIT, 
	@accountdId BIGINT,
	@customerId BIGINT,
	@operation nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @salesforceSubscriptionProductsSyncOptionId int = (select SalesforceSubscriptionProductsSyncOptionId from AccountSalesforceConfiguration where id = @accountdId)

    
	select sp.Id,
		sp.Included into #EntitiesToUpdateSalesforce
	from 
		SubscriptionProduct sp
		inner join Subscription s on s.id = sp.SubscriptionId
		inner join Customer c on c.id = s.CustomerId
	where 
		s.AccountId = @accountdId
		and s.CustomerId = ISNULL(@customerId, s.CustomerId) 
		and c.SalesforceSynchStatusId = 1
	order by s.CustomerId asc


	if (@salesforceSubscriptionProductsSyncOptionId = 2 and @operation = 'delete')
		select eu.*
			,NULL AS NetsuiteId
			,sp.SalesforceId
		from #EntitiesToUpdateSalesforce eu
		INNER JOIN SubscriptionProduct sp ON sp.Id = eu.Id
		where eu.Included = 0 and sp.SalesforceId is not null
	else if (@salesforceSubscriptionProductsSyncOptionId = 2 and @operation = 'upsert')
		select eu.*
			,NULL AS NetsuiteId
			,sp.SalesforceId
		from #EntitiesToUpdateSalesforce eu
		INNER JOIN SubscriptionProduct sp ON sp.Id = eu.Id
		where eu.Included = 1
	else if (@salesforceSubscriptionProductsSyncOptionId = 3)
		select eu.*
			,NULL AS NetsuiteId
			,sp.SalesforceId
		from #EntitiesToUpdateSalesforce eu
		INNER JOIN SubscriptionProduct sp ON sp.Id = eu.Id
		where sp.SalesforceId is not null
	else 
		select eu.*
			,NULL AS NetsuiteId
			,sp.SalesforceId
		from #EntitiesToUpdateSalesforce eu
		INNER JOIN SubscriptionProduct sp ON sp.Id = eu.Id

	drop table #EntitiesToUpdateSalesforce
	
END

GO

