CREATE PROCEDURE [dbo].[usp_GetPurchaseSummary]
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
	@PurchaseId BIGINT,
	@purchaseIdSet bit,
	@InvoiceNumber BIGINT,
	@invoiceNumberSet bit,
	@Description NVARCHAR(255),
	@DescriptionSet bit,
	@Name NVARCHAR(255),
	@NameSet bit,
	@ProductCode NVARCHAR(255),
	@ProductCodeSet bit,
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
    @InvoiceStatus tinyint,
	@InvoiceStatusSet bit,
	--date filters
	@CancellationDateSet bit,
	@CancellationDateStartDate DateTime,
	@CancellationDateEndDate DateTime,

	@CreatedDateSet bit,
	@CreatedDateStartDate DateTime,
	@CreatedDateEndDate DateTime,

	@FinalizationDateSet bit,
	@FinalizationDateStartDate DateTime,
	@FinalizationDateEndDate DateTime,

	@DatePaidSet bit,
	@DatePaidStartDate DateTime,
	@DatePaidEndDate DateTime,
	
	@SalesTrackingCode1CodeSet bit,
	@SalesTrackingCode1Code NVARCHAR(255),

	@SalesTrackingCode2CodeSet bit,
	@SalesTrackingCode2Code NVARCHAR(255),

	@SalesTrackingCode3CodeSet bit,
	@SalesTrackingCode3Code NVARCHAR(255),

	@SalesTrackingCode4CodeSet bit,
	@SalesTrackingCode4Code NVARCHAR(255),

	@SalesTrackingCode5CodeSet bit,
	@SalesTrackingCode5Code NVARCHAR(255)
AS
SET NOCOUNT ON

DECLARE 
--required
	@AccountIdInner BIGINT = @AccountId,

	--Paging variables
	@SortOrderInner NVARCHAR(255) = @SortOrder,
	@SortExpressionInner NVARCHAR(255) = @SortExpression,
	@PageNumberInner BIGINT = @PageNumber,
	@PageSizeInner BIGINT = @PageSize,

	--Filtering options
	@CustomerIdInner BIGINT = @CustomerId,
	@CustomerIdSetInner bit = @CustomerIdSet,
	@PurchaseIdInner BIGINT = @PurchaseId,
	@purchaseIdSetInner bit = @purchaseIdSet,
	@InvoiceNumberInner BIGINT = @InvoiceNumber,
	@invoiceNumberSetInner bit = @invoiceNumberSet,
	@DescriptionInner NVARCHAR(255) = @Description,
	@DescriptionSetInner bit = @DescriptionSet,
	@NameInner NVARCHAR(255) = @Name,
	@NameSetInner bit = @NameSet,
	@ProductCodeInner NVARCHAR(255) = @ProductCode,
	@ProductCodeSetInner bit = @ProductCodeSet,
	@FirstNameInner NVARCHAR(255) = @FirstName,
	@FirstNameSetInner bit = @FirstNameSet,
	@LastNameInner NVARCHAR(255) = @LastName,
	@LastNameSetInner bit = @LastNameSet,
	@CompanyNameInner NVARCHAR(255) = @CompanyName,
	@CompanyNameSetInner bit = @CompanyNameSet,
	@StatusInner tinyint = @Status,
	@StatusSetInner bit = @StatusSet,
	@ReferenceInner NVARCHAR(255) = @Reference,
	@ReferenceSetInner bit = @ReferenceSet,
	@CurrencyIdInner BIGINT = @CurrencyId,
	@CurrencyIdSetInner bit = @CurrencyIdSet,
    @InvoiceStatusInner tinyint = @InvoiceStatus,
	@InvoiceStatusSetInner bit = @InvoiceStatusSet,

	--date filters
	@CancellationDateSetInner bit = @CancellationDateSet,
	@CancellationDateStartDateInner DateTime = @CancellationDateStartDate,
	@CancellationDateEndDateInner DateTime = @CancellationDateEndDate,

	@CreatedDateSetInner bit = @CreatedDateSet,
	@CreatedDateStartDateInner DateTime = @CreatedDateStartDate,
	@CreatedDateEndDateInner DateTime = @CreatedDateEndDate,

	@FinalizationDateSetInner bit = @FinalizationDateSet,
	@FinalizationDateStartDateInner DateTime = @FinalizationDateStartDate,
	@FinalizationDateEndDateInner DateTime = @FinalizationDateEndDate,

	@DatePaidSetInner bit = @DatePaidSet,
	@DatePaidStartDateInner DateTime = @DatePaidStartDate,
	@DatePaidEndDateInner DateTime = @DatePaidEndDate,
	
	@SalesTrackingCode1CodeSetInner bit= @SalesTrackingCode1CodeSet,
	@SalesTrackingCode1Codeinner NVARCHAR(255) = @SalesTrackingCode1Code,

	@SalesTrackingCode2CodeSetInner bit = @SalesTrackingCode2CodeSet,
	@SalesTrackingCode2CodeInner NVARCHAR(255) = @SalesTrackingCode2Code,

	@SalesTrackingCode3CodeSetInner bit = @SalesTrackingCode3CodeSet,
	@SalesTrackingCode3CodeInner NVARCHAR(255) = @SalesTrackingCode3Code,

	@SalesTrackingCode4CodeSetInner bit = @SalesTrackingCode4CodeSet,
	@SalesTrackingCode4CodeInner NVARCHAR(255) = @SalesTrackingCode4Code,

	@SalesTrackingCode5CodeSetInner bit = @SalesTrackingCode5CodeSet ,
	@SalesTrackingCode5CodeInner NVARCHAR(255) = @SalesTrackingCode5Code

Select 
	*
into 
	#purchaseviewtemp 
from 
	vw_PurchaseSummary 
where
	AccountId = @AccountIdInner
	and (@CustomerIdSetInner = 0 
		or [CustomerId] = @CustomerIdInner)
	and (@StatusSetInner = 0 
		or StatusId = @StatusInner)
	and (@NameSetInner = 0 
		or [Name] LIKE @NameInner)
	and (@DescriptionSetInner = 0 
		or Description LIKE @DescriptionInner)
	and (@ProductCodeSetInner = 0 
		or ProductCode LIKE @ProductCodeInner)
	and (@FirstNameSetInner = 0 
		or FirstName LIKE @FirstNameInner)
	and (@LastNameSetInner = 0 
		or LastName LIKE @LastNameInner)
	and (@CompanyNameSetInner = 0 
		or CompanyName LIKE @CompanyNameInner)
	and (@ReferenceSetInner = 0 
		or Reference LIKE @ReferenceInner)
	and (@PurchaseIdSetInner = 0 
		or [Id] = @PurchaseIdInner)
	and (@InvoiceNumberSetInner = 0 
		or InvoiceNumber = @InvoiceNumberInner)
	and (@CreatedDateSetInner = 0 
		or (@CreatedDateStartDateInner <= CreatedDate and @CreatedDateEndDateInner >= CreatedDate))
	and (@FinalizationDateSetInner = 0 
		or (@FinalizationDateStartDateInner <= FinalizationDate and @FinalizationDateEndDateInner >= FinalizationDate))
	and (@CancellationDateSetInner = 0	
		or (@CancellationDateStartDateInner <= CancellationDate and @CancellationDateEndDateInner >= CancellationDate))
	and (@DatePaidSetInner = 0	
		or (@DatePaidStartDateInner <= DatePaid and @DatePaidEndDateInner >= DatePaid))
	and (@CurrencyIdSet = 0 
		or [CurrencyId] = @CurrencyId)
	AND (@SalesTrackingCode1CodeSetInner = 0
	or SalesTrackingCode1Code in (select Data from dbo.Split(@SalesTrackingCode1Code,',')))

	AND (@SalesTrackingCode2CodeSetInner = 0
	or SalesTrackingCode2Code in (select Data from dbo.Split(@SalesTrackingCode2Code,',')))

	AND (@SalesTrackingCode3CodeSetInner = 0
	or SalesTrackingCode3Code in (select Data from dbo.Split(@SalesTrackingCode3Code,',')))

	AND (@SalesTrackingCode4CodeSetInner = 0
	or SalesTrackingCode4Code in (select Data from dbo.Split(@SalesTrackingCode4Code,',')))

	AND (@SalesTrackingCode5CodeSetInner = 0
	or SalesTrackingCode5Code in (select Data from dbo.Split(@SalesTrackingCode5Code,',')))
    -- paid and unpaid invoice

	 and ((@InvoiceStatusSetInner = 0 or @InvoiceStatusInner <> 4 and [InvoiceStatusId] <> 4)
	 or (@InvoiceStatusSetInner = 0 or @InvoiceStatusInner = 4 and [InvoiceStatusId] = 4))

declare @sqltext nvarchar(2000)
set @sqltext = N'SELECT * FROM #purchaseviewtemp order by CASE When @SortOrder = ''Ascending'' THEN '+@SortExpressionInner+' END ASC, CASE When @SortOrder = ''Descending'' THEN '+@SortExpressionInner+' END DESC'

if(@PageSize IS NOT NULL)
BEGIN
	set @sqltext = @sqltext + N' OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY'
END

execute sp_executesql @sqltext, N'@PageNumber BIGINT,@PageSize BIGINT, @SortOrder NVARCHAR(255)',@SortOrder = @SortOrderInner, @PageNumber = @PageNumberInner, @PageSize = @PageSizeInner

SELECT Count(*) as [count] from #purchaseviewtemp

SET NOCOUNT OFF

GO

