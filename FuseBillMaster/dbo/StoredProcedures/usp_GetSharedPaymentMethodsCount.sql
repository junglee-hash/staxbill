CREATE PROCEDURE [dbo].[usp_GetSharedPaymentMethodsCount]
	-- Add the parameters for the stored procedure here
		@CustomerId bigint,
		@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
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
	cte.Id as [CustomerId]
	,pms.Sharing as [SharingOverride]
	,pm.Sharing
	,pm.Id as PaymentMethodId
	into #temp2
	from #temp1 cte 
	left join PaymentMethod pm on pm.CustomerId = @CustomerId
	left join PaymentMethodSharing pms on cte.Id = pms.CustomerId and pms.PaymentMethodId = pm.Id
	where  cte.ParentId is not null

	if @AccountSharing = 0
		begin
			select t2.PaymentMethodId, count(*) as [Count]
			from #temp2 t2
			inner join Customer c on c.id = t2.CustomerId
			where t2.SharingOverride = 1 or (t2.Sharing = 1 and t2.SharingOverride is null) 
			group by t2.PaymentMethodId
		end

	if @AccountSharing = 1
		begin
			select t2.PaymentMethodId, count(*) as [Count]
 			from #temp2 t2
			inner join Customer c on c.id = t2.CustomerId
			where ((t2.Sharing is null or t2.Sharing = 1) and (t2.SharingOverride is null or t2.SharingOverride = 1))
				or 
				(Sharing = 0 and SharingOverride = 1)
			group by t2.PaymentMethodId
		end

	drop table #temp1
	drop table #temp2

	SET NOCOUNT OFF;
END

GO

