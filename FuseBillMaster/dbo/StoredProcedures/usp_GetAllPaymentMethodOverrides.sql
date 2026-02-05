CREATE PROCEDURE [dbo].[usp_GetAllPaymentMethodOverrides]
	-- Add the parameters for the stored procedure here
	@ParentCustomerId bigint,
	@PaymentMethodId bigint,

	--Paging variables
	@SortOrder NVARCHAR(255),
	@SortExpression NVARCHAR(255),
	@PageNumber BIGINT,
	@PageSize BIGINT,

	--Filtering options
	@CustomerId bigint,
	@CustomerIdSet bit,
	@FirstName NVARCHAR(255),
	@FirstNameSet bit,
	@LastName NVARCHAR(255),
	@LastNameSet bit,
	@CompanyName NVARCHAR(255),
	@CompanyNameSet bit,
	@CustomerReference NVARCHAR(255),
	@CustomerReferenceSet bit,
	@PrimaryEmailSet bit,
	@PrimaryEmail NVARCHAR(255)
	with recompile
AS
BEGIN
   --SET FMTONLY OFF;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	with cte as (
		select id, ParentId from Customer
		where Id = @ParentCustomerId
		union all
		select child.Id, child.ParentId from Customer child
		join cte parent
		on parent.Id = child.ParentId
	)
	select 
	cte.Id,
	cte.ParentId into #temp1
	from cte 
	where  (cte.ParentId is not null and cte.Id <> @ParentCustomerId)

	select
	cte.Id as [CustomerId],
	pms.Id as [PaymentMethodSharingId],
	pms.PaymentMethodId as [PaymentMethodId], 
	pms.Sharing into #temp2
	from #temp1 cte 
	left join PaymentMethodSharing pms on cte.Id = pms.CustomerId
	where  cte.ParentId is not null and (PaymentMethodId = @PaymentMethodId or PaymentMethodId is null)

	select t1.Id as [CustomerId],
	c.Reference,
	cs.Name as [CustomerStatus],
	cas.Name as [CustomerAccountStatus],
	CASE WHEN pm.CustomerId <> t1.Id THEN CAST(1 as bit) ELSE CAST(0 as bit) END AS IsParentPaymentMethod,
	c.CompanyName, 
	c.FirstName,
	c.MiddleName,
	c.LastName,
	c.NextBillingDate,
	c.PrimaryEmail,
	c.PrimaryPhone,
	t2.PaymentMethodSharingId, 
	t2.PaymentMethodId, 
	t2.Sharing,
	CASE WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NULL THEN 'Missing' 
		WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3 THEN 'Credit Card' 
		WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 5 THEN 'ACH' 
		WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 6 THEN 'Paypal' 
		WHEN (cbs.AutoCollect = 0 OR (cbs.AutoCollect IS NULL AND abp.DefaultAutoCollect = 0)) AND pm.Id IS NOT NULL THEN 'AR - Pay method on file' 
		WHEN pm.Id IS NULL THEN 'AR' 
	END AS PaymentMethod,
	count(*) over() as [Count]
	
	from #temp1 t1
	left join #temp2 t2 on t1.id = t2.CustomerId
	left join Customer c on c.id = t1.Id
	left join Lookup.CustomerStatus cs on cs.Id = c.StatusId
	left join Lookup.CustomerAccountStatus cas on cas.Id = c.AccountStatusId
	left join CustomerBillingSetting cbs on cbs.id = t1.Id
	left join PaymentMethod pm on pm.Id = cbs.DefaultPaymentMethodId
	left join AccountBillingPreference abp on abp.Id = c.AccountId
	where c.IsDeleted = 0
	and (@CustomerIdSet = 0 or t1.Id = @CustomerId)
	and (@FirstNameSet = 0 or c.FirstName LIKE '%'+@FirstName+'%')
	and (@LastNameSet = 0 or c.LastName LIKE '%'+@LastName+'%')
	and (@CompanyNameSet = 0 or CompanyName LIKE '%'+@CompanyName+'%')
	and (@CustomerReferenceSet = 0 or Reference LIKE '%'+@CustomerReference+'%')
	and (@PrimaryEmailSet = 0 or PrimaryEmail like '%'+@PrimaryEmail+'%')
	order by 
		case when @SortOrder = 'Ascending' and @SortExpression = 'companyName' then CompanyName end asc,
		case when @SortOrder = 'Descending' and @SortExpression = 'companyName' then CompanyName end desc,
		case when @SortOrder = 'Ascending' and @SortExpression = 'nextBillingDate' then NextBillingDate end asc,
		case when @SortOrder = 'Descending' and @SortExpression = 'nextBillingDate' then NextBillingDate end desc,
		case when @SortOrder = 'Ascending' and @SortExpression = 'customerId' then t1.Id end asc,
		case when @SortOrder = 'Descending' and @SortExpression = 'customerId' then t1.Id end desc
	OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY

	drop table #temp1
	drop table #temp2

	SET NOCOUNT OFF;
END

GO

