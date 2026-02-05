CREATE PROCEDURE [dbo].[usp_GetDraftInvoiceSummary]
	--required
	@AccountId BIGINT,

	--Paging variables
	@SortOrder NVARCHAR(255),
	@SortExpression NVARCHAR(255),
	@PageNumber BIGINT = NULL,
	@PageSize BIGINT = NULL,

	--Filtering options
	@CustomerId BIGINT,
	@CustomerIdSet bit,
	@DraftInvoiceId BIGINT,
	@DraftInvoiceIdSet bit,
	@PoNumber NVARCHAR(255),
	@PoNumberSet bit,
	@FirstName NVARCHAR(255),
	@FirstNameSet bit,
	@LastName NVARCHAR(255),
	@LastNameSet bit,
	@CompanyName NVARCHAR(255),
	@CompanyNameSet bit,
	@Status tinyint,
	@StatusSet bit,
	@Reference NVARCHAR(255),
	@ReferenceSet bit,
	@CurrencyId BIGINT,
	@CurrencyIdSet bit,

	--date filters
	@BillingPeriodStartDateSet bit,
	@BillingPeriodStartDateStartDate DateTime,
	@BillingPeriodStartDateEndDate DateTime,

	@CreatedDateSet bit,
	@CreatedDateStartDate DateTime,
	@CreatedDateEndDate DateTime,

	@EffectiveDateSet bit,
	@EffectiveDateStartDate DateTime,
	@EffectiveDateEndDate DateTime,

	@ModifiedTimestampSet bit,
	@ModifiedTimestampStartDate DateTime,
	@ModifiedTimestampEndDate DateTime

WITH RECOMPILE
AS
SET NOCOUNT ON

Select 
	*
into 
	#draftinvoiceviewtemp 
from 
	vw_DraftInvoiceSummary 
where
	AccountId = @AccountId
	and (@CustomerIdSet = 0 
		or [CustomerId] = @CustomerId)
	and (@StatusSet = 0 
		or DraftInvoiceStatusId = @Status)
	and (@FirstNameSet = 0 
		or FirstName LIKE @FirstName)
	and (@LastNameSet = 0 
		or LastName LIKE @LastName)
	and (@CompanyNameSet = 0 
		or CompanyName LIKE @CompanyName)
	and (@ReferenceSet = 0 
		or Reference LIKE @Reference)
	and (@DraftInvoiceIdSet = 0 
		or [Id] = @DraftInvoiceId)
	and (@PoNumberSet = 0 
		or PoNumber LIKE @PoNumber)
	and (@CreatedDateSet = 0 
		or (@CreatedDateStartDate <= CreatedDate and @CreatedDateEndDate >= CreatedDate))
	and (@ModifiedTimestampSet = 0 
		or (@ModifiedTimestampStartDate <= ModifiedTimestamp and @ModifiedTimestampEndDate >= ModifiedTimestamp))
	and (@EffectiveDateSet = 0 
		or (@EffectiveDateStartDate <= EffectiveDate and @EffectiveDateEndDate >= EffectiveDate))
	and (@BillingPeriodStartDateSet = 0	
		or (@BillingPeriodStartDateStartDate <= BillingPeriodStartDate and @BillingPeriodStartDateEndDate >= BillingPeriodStartDate))
	and (@CurrencyIdSet = 0 
		or [CurrencyId] = @CurrencyId)

declare @sqltext nvarchar(2000)
set @sqltext = N'SELECT * FROM #draftinvoiceviewtemp order by CASE When @SortOrder = ''Ascending'' THEN '+@SortExpression+' END ASC, CASE When @SortOrder = ''Descending'' THEN '+@SortExpression+' END DESC'

if(@PageSize IS NOT NULL)
BEGIN
	set @sqltext = @sqltext + N' OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY'
END

execute sp_executesql @sqltext, N'@PageNumber BIGINT,@PageSize BIGINT, @SortOrder NVARCHAR(255)',@SortOrder = @SortOrder, @PageNumber = @PageNumber, @PageSize = @PageSize

SELECT Count(*) as [count] from #draftinvoiceviewtemp

SET NOCOUNT OFF

GO

