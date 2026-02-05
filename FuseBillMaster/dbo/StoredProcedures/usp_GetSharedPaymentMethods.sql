CREATE PROCEDURE [dbo].[usp_GetSharedPaymentMethods]
	-- Add the parameters for the stored procedure here
		@CustomerId bigint,
		@AccountId bigint,
		@PaymentMethodId bigint,

	--Paging variables
		@SortOrder NVARCHAR(255),
		@SortExpression NVARCHAR(255),
		@PageNumber BIGINT,
		@PageSize BIGINT,

		--Filtering options
		@CustomerIdFilter bigint,
		@CustomerIdSet bit,
		@FirstName NVARCHAR(255),
		@FirstNameSet bit,
		@LastName NVARCHAR(255),
		@LastNameSet bit,
		@CompanyName NVARCHAR(255),
		@CompanyNameSet bit
		with recompile
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @AccountSharing int = (select PaymentMethodSharing from AccountFeatureConfiguration where Id = @AccountId);

	with cte as (
		select id, ParentId from Customer
		where Id = @CustomerId
		union all
		select child.Id, child.ParentId from Customer child
		join cte parent
		on parent.Id = child.ParentId
	)
	select 
	cte.Id,
	cte.ParentId into #temp1
	from cte 
	where  cte.ParentId is not null and cte.Id <> @CustomerId 

	select
	cte.Id as [CustomerId],
	pms.Sharing as [SharingOverride],
	pm.Sharing
	,pms.Id as PaymentMethodSharingId
	into #temp2
	from #temp1 cte 
	left join PaymentMethod pm on pm.CustomerId = @CustomerId
	left join PaymentMethodSharing pms on cte.Id = pms.CustomerId and pms.PaymentMethodId = pm.Id
	where  cte.ParentId is not null and (pm.Id = @PaymentMethodId or pm.Id is null)

	if @AccountSharing = 0
		begin
			select c.FirstName, c.LastName, c.CompanyName, t2.*,
			count(*) over () as [count]
 			from #temp2 t2
			inner join Customer c on c.id = t2.CustomerId
			where t2.SharingOverride = 1 or (t2.Sharing = 1 and t2.SharingOverride is null) 
			and (@CustomerIdSet = 0 or CustomerId = @CustomerIdFilter)
			and (@FirstNameSet = 0 or c.FirstName LIKE @FirstName)
			and (@LastNameSet = 0 or c.LastName LIKE @LastName)
			and (@CompanyNameSet = 0 or CompanyName LIKE @CompanyName)
			order by 
				case when @SortOrder = 'Acsending' and @SortExpression = 'companyName' then CompanyName end asc,
				case when @SortOrder = 'Descending' and @SortExpression = 'companyName' then CompanyName end desc,
				case when @SortOrder = 'Acsending' and @SortExpression = 'customerId' then CustomerId end asc,
				case when @SortOrder = 'Descending' and @SortExpression = 'customerId' then CustomerId end desc
			OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
		end

	if @AccountSharing = 1
		begin
			select  c.FirstName, c.LastName, c.CompanyName, t2.*,
			count(*) over () as [count]
 			from #temp2 t2
			inner join Customer c on c.id = t2.CustomerId
			where ((t2.Sharing is null or t2.Sharing = 1) and (t2.SharingOverride is null or t2.SharingOverride = 1))
				or 
				(Sharing = 0 and SharingOverride = 1)
				and (@CustomerIdSet = 0 or CustomerId = @CustomerIdFilter)
				and (@FirstNameSet = 0 or c.FirstName LIKE @FirstName)
				and (@LastNameSet = 0 or c.LastName LIKE @LastName)
				and (@CompanyNameSet = 0 or CompanyName LIKE @CompanyName)
				order by 
					case when @SortOrder = 'Acsending' and @SortExpression = 'companyName' then CompanyName end asc,
					case when @SortOrder = 'Descending' and @SortExpression = 'companyName' then CompanyName end desc,
					case when @SortOrder = 'Acsending' and @SortExpression = 'customerId' then CustomerId end asc,
					case when @SortOrder = 'Descending' and @SortExpression = 'customerId' then CustomerId end desc
				OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
		end

	drop table #temp1
	drop table #temp2

	SET NOCOUNT OFF;
END

GO

