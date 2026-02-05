CREATE PROCEDURE [dbo].[usp_GetCustomersPaymentMethodSharing]
	-- Add the parameters for the stored procedure here
	@ExcludedCustomers as IDList readonly,
	@PaymentMethodId bigint,
	@ParentCustomerId bigint,
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
	@PrimaryEmail NVARCHAR(255),
	@PrimaryEmailSet bit

AS
BEGIN
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
		cte.Id
		from cte 
		join Customer c on c.Id = cte.Id
		where  cte.ParentId is not null
			and cte.Id <> @ParentCustomerId
			and not exists (
				select * 
				from @ExcludedCustomers
				where Id = cte.Id)
		and c.IsDeleted = 0
		and (@CustomerIdSet = 0 or cte.Id = @CustomerId)
		and (@FirstNameSet = 0 or c.FirstName LIKE '%'+@FirstName+'%')
		and (@LastNameSet = 0 or c.LastName LIKE '%'+@LastName+'%')
		and (@CompanyNameSet = 0 or c.CompanyName LIKE '%'+@CompanyName+'%')
		and (@CustomerReferenceSet = 0 or c.Reference LIKE '%'+@CustomerReference+'%')
		and (@PrimaryEmailSet = 0 or c.PrimaryEmail like '%'+@PrimaryEmail+'%')
END

GO

