

CREATE       PROCEDURE [dbo].[usp_GetPaymentsSummary]
	
	--required
	@AccountId BIGINT 

	--Paging variables
	, @SortOrder NVARCHAR(50) 
	, @SortExpression nvarchar(100) = 'id'
	, @PageNumber BIGINT
	, @PageSize BIGINT

	--Filtering options
	,@CustomerId BIGINT 
	,@CustomerIdSet BIT 
	,@CustomerReference NVARCHAR(255) = NULL
	,@CustomerReferenceSet BIT
	,@PaymentReference NVARCHAR(500) = NULL
	,@PaymentReferenceSet BIT
	-- Date filters
	,@CreatedDateSet BIT 
	,@CreatedStartDate DATETIME = NULL
	,@CreatedEndDate DATETIME = NULL
	,@PaymentReferenceDateSet BIT 
	,@PaymentReferenceStartDate DATETIME = NULL
	,@PaymentReferenceEndDate DATETIME = NULL

	-- Payment filters
	,@ReconciliationIdSet BIT 
	,@ReconciliationId UNIQUEIDENTIFIER = NULL
	,@PaymentStatusSet BIT 
	,@PaymentStatus INT = NULL
	,@PaymentTypeSet BIT 
	,@PaymentType INT = NULL
	,@PaymentMethodTypeSet BIT 
	,@PaymentMethodType INT = NULL
	,@PaymentMethodAccountTypeSet BIT 
	,@PaymentMethodAccountType VARCHAR(255) = NULL
	,@SalesTrackingCode1 as dbo.IDList readonly
	,@SalesTrackingCode2 as dbo.IDList readonly
	,@SalesTrackingCode3 as dbo.IDList readonly
	,@SalesTrackingCode4 as dbo.IDList readonly
	,@SalesTrackingCode5 as dbo.IDList readonly
	,@SalesTrackingCode1Set bit
	,@SalesTrackingCode2Set bit 
	,@SalesTrackingCode3Set bit 
	,@SalesTrackingCode4Set bit 
	,@SalesTrackingCode5Set bit
	,@SalesTrackingCode1OrSet bit 
	,@SalesTrackingCode2OrSet bit 
	,@SalesTrackingCode3OrSet bit 
	,@SalesTrackingCode4OrSet bit 
	,@SalesTrackingCode5OrSet bit 

AS
begin
SET NOCOUNT ON

	declare @sql nvarchar (max)
	set @sql = N'
	SELECT paj.Id
		, paj.AccountId
		, paj.CustomerId
		, paj.Amount
		, paj.EffectiveTimestamp
		, paj.ReconciliationId
		, paj.AuthorizationResponse
		, paj.SettlementStatusMessage
		, paj.PaymentTypeId
		, paj.PaymentMethodTypeId
		, paj.PaymentActivityStatusId
		, paj.SettlementStatusId
		, paj.PaymentMethodId
	INTO #PajFiltered
	FROM PaymentActivityJournal paj
	INNER JOIN Customer c ON c.Id = paj.CustomerId
	LEFT JOIN PaymentMethod pm ON pm.Id = paj.PaymentMethodId
	'
	if (@SalesTrackingCode1Set = 1 or @SalesTrackingCode2Set = 1 or @SalesTrackingCode3Set = 1 or @SalesTrackingCode4Set = 1 or @SalesTrackingCode5Set = 1 or @PaymentReferenceDateSet = 1 or @PaymentReferenceSet = 1)
		set @sql = @sql + 'LEFT JOIN Payment p on p.PaymentActivityJournalId = paj.Id
	LEFT JOIN Refund r on r.PaymentActivityJournalId = paj.Id
	LEFT JOIN Payment rp on rp.Id = r.OriginalPaymentId 
	'

	-- perform inner join when only STC ids are provided (no 'null' value). use case - show me payments with only specified STCs
	if (@SalesTrackingCode1Set = 1 and @SalesTrackingCode1OrSet = 0)
		set @sql = @sql + N'inner join @SalesTrackingCode1 s1 on s1.Id = isnull(rp.SalesTrackingCode1Id, p.SalesTrackingCode1Id)
		'
	if (@SalesTrackingCode2Set = 1 and @SalesTrackingCode2OrSet = 0)
		set @sql = @sql + N'inner join @SalesTrackingCode2 s2 on s2.Id = isnull(rp.SalesTrackingCode2Id, p.SalesTrackingCode2Id)
		'
	if (@SalesTrackingCode3Set = 1 and @SalesTrackingCode3OrSet = 0)
		set @sql = @sql + N'inner join @SalesTrackingCode3 s3 on s3.Id = isnull(rp.SalesTrackingCode3Id, p.SalesTrackingCode3Id)
		'
	if (@SalesTrackingCode4Set = 1 and @SalesTrackingCode4OrSet = 0)
		set @sql = @sql + N'inner join @SalesTrackingCode4 s4 on s4.Id = isnull(rp.SalesTrackingCode4Id, p.SalesTrackingCode4Id)
		'
	if (@SalesTrackingCode5Set = 1 and @SalesTrackingCode5OrSet = 0)
		set @sql = @sql + N'inner join @SalesTrackingCode5 s5 on s5.Id = isnull(rp.SalesTrackingCode5Id, p.SalesTrackingCode5Id)
		'

	set @sql = @sql + ' WHERE paj.AccountId = @AccountId
		AND c.IsDeleted = 0
		AND (@CreatedDateSet = 0 
			OR (paj.EffectiveTimestamp >= @CreatedStartDate
					AND paj.EffectiveTimestamp <= @CreatedEndDate)
			)
		AND (@CustomerIdSet = 0
			OR paj.CustomerId = @CustomerId
			)
		AND (@CustomerReferenceSet = 0
			OR c.Reference LIKE ''%'' + @CustomerReference + ''%''
			)
			'
	if(@PaymentReferenceSet = 1)
		Set @sql = @sql + '
		AND (
			   COALESCE(p.reference, r.reference) LIKE ''%'' + @PaymentReference + ''%''
			)
		
		'
	if(@PaymentReferenceDateSet = 1)
	Set @sql = @sql + '
		AND (
			   (COALESCE(p.referenceDate, r.referenceDate) >= @PaymentReferenceStartDate
					AND COALESCE(p.referenceDate, r.referenceDate) < @PaymentReferenceEndDate)
			)
		
		'
	set @sql = @sql + '
		
		AND (@ReconciliationIdSet = 0
			OR paj.ReconciliationId = @ReconciliationId
			)
		AND (@PaymentStatusSet = 0
			OR paj.PaymentActivityStatusId = @PaymentStatus
			)
		AND (@PaymentTypeSet = 0
			OR paj.PaymentTypeId = @PaymentType
			)
		AND (@PaymentMethodTypeSet = 0
			OR paj.PaymentMethodTypeId = @PaymentMethodType
			)
		AND (@PaymentMethodAccountTypeSet = 0
			OR pm.AccountType LIKE @PaymentMethodAccountType
			)
	'

	-- if 'null' value and list of ids are provided. use case - show me payments without STC and payment with specified STCs
	if (@SalesTrackingCode1Set = 1 and @SalesTrackingCode1OrSet = 1 and EXISTS(SELECT 1 FROM @SalesTrackingCode1))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode1Id, p.SalesTrackingCode1Id) is null or isnull(rp.SalesTrackingCode1Id, p.SalesTrackingCode1Id) in (select Id from @SalesTrackingCode1))
		'
	-- if only 'null' value provided (no list of ids). use case - show me payments without STCs
	if (@SalesTrackingCode1Set = 1 and @SalesTrackingCode1OrSet = 1 and not EXISTS(SELECT 1 FROM @SalesTrackingCode1))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode1Id, p.SalesTrackingCode1Id) is null)
		'

	if (@SalesTrackingCode2Set = 1 and @SalesTrackingCode2OrSet = 1 and EXISTS(SELECT 1 FROM @SalesTrackingCode2))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode2Id, p.SalesTrackingCode2Id) is null or isnull(rp.SalesTrackingCode2Id, p.SalesTrackingCode2Id) in (select Id from @SalesTrackingCode2))
		'
	if (@SalesTrackingCode2Set = 1 and @SalesTrackingCode2OrSet = 1 and not EXISTS(SELECT 1 FROM @SalesTrackingCode2))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode2Id, p.SalesTrackingCode2Id) is null)
		'

	if (@SalesTrackingCode3Set = 1 and @SalesTrackingCode3OrSet = 1 and EXISTS(SELECT 1 FROM @SalesTrackingCode3))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode3Id, p.SalesTrackingCode3Id) is null or isnull(rp.SalesTrackingCode3Id, p.SalesTrackingCode3Id) in (select Id from @SalesTrackingCode3))
		'
	if (@SalesTrackingCode3Set = 1 and @SalesTrackingCode3OrSet = 1 and not EXISTS(SELECT 1 FROM @SalesTrackingCode3))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode3Id, p.SalesTrackingCode3Id) is null)
		'

	if (@SalesTrackingCode4Set = 1 and @SalesTrackingCode4OrSet = 1 and EXISTS(SELECT 1 FROM @SalesTrackingCode4))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode4Id, p.SalesTrackingCode4Id) is null or isnull(rp.SalesTrackingCode4Id, p.SalesTrackingCode4Id) in (select Id from @SalesTrackingCode4))
		'
	if (@SalesTrackingCode4Set = 1 and @SalesTrackingCode4OrSet = 1 and not EXISTS(SELECT 1 FROM @SalesTrackingCode4))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode4Id, p.SalesTrackingCode4Id) is null)
		'

	if (@SalesTrackingCode5Set = 1 and @SalesTrackingCode5OrSet = 1 and EXISTS(SELECT 1 FROM @SalesTrackingCode5))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode5Id, p.SalesTrackingCode5Id) is null or isnull(rp.SalesTrackingCode5Id, p.SalesTrackingCode5Id) in (select Id from @SalesTrackingCode5))
		'
	if (@SalesTrackingCode5Set = 1 and @SalesTrackingCode5OrSet = 1 and not EXISTS(SELECT 1 FROM @SalesTrackingCode5))
		set @sql = @sql + N'and (isnull(rp.SalesTrackingCode5Id, p.SalesTrackingCode5Id) is null)
		'

	set @sql = @sql + 'SELECT 
		paj.Id
		, paj.AccountId
		, paj.CustomerId
		, paj.Amount
		, paj.PaymentTypeId
		, paj.PaymentMethodTypeId
		, pm.AccountType as PaymentMethodAccountType
		, cc.FirstSix as CreditCardFirstSix
		, cc.MaskedCardNumber
		, ach.MaskedAccountNumber
		, paj.EffectiveTimestamp
		, paj.ReconciliationId
		, paj.PaymentActivityStatusId
		, paj.AuthorizationResponse
		, paj.SettlementStatusId
		, paj.SettlementStatusMessage
		, coalesce(p.Reference, r.Reference, '''') as Reference 
		-- Customer data
		, cur.IsoName as Currency
		, c.FirstName as CustomerFirstName
		, c.LastName as CustomerLastName
		, c.CompanyName as CustomerCompanyName
		, c.PrimaryEmail as CustomerPrimaryEmail
		, c.Reference as CustomerReference
		, c.ParentId AS CustomerParentId
		, c.IsParent as CustomerIsParent
		, c.AccountStatusId as CustomerAccountStatusId
		, c.StatusId as CustomerStatusId
		, cc.IsDebit as IsDebit
	FROM #PajFiltered paj
	INNER JOIN Customer c ON c.Id = paj.CustomerId
	LEFT JOIN PaymentMethod pm ON pm.Id = paj.PaymentMethodId
	LEFT JOIN CreditCard cc ON cc.Id = paj.PaymentMethodId
	LEFT JOIN AchCard ach ON ach.Id = paj.PaymentMethodId
	LEFT JOIN Payment p on p.PaymentActivityJournalId = paj.Id
	LEFT JOIN Refund r on r.PaymentActivityJournalId = paj.Id
	INNER JOIN Lookup.Currency cur ON cur.Id = c.CurrencyId
	ORDER BY
		CASE WHEN @SortOrder = ''Ascending'' AND @SortExpression = ''id'' THEN paj.Id END ASC,
		CASE WHEN @SortOrder = ''Descending'' AND @SortExpression = ''id'' THEN paj.Id END DESC,
		CASE WHEN @SortOrder = ''Ascending'' AND @SortExpression = ''amount'' THEN paj.Amount END ASC,
		CASE WHEN @SortOrder = ''Descending'' AND @SortExpression = ''amount'' THEN paj.Amount END DESC
	OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY

	SELECT COUNT(*) as [count] FROM #PajFiltered

	DROP TABLE #PajFiltered
	'

	exec sp_executesql @sql ,N'@AccountId BIGINT
	,@SortOrder NVARCHAR(50)
	,@SortExpression NVARCHAR (100)
	,@PageNumber BIGINT
	,@PageSize BIGINT
	,@CustomerId BIGINT 
	,@CustomerIdSet BIT
	,@CustomerReference NVARCHAR(255)
	,@CustomerReferenceSet BIT
	,@PaymentReference NVARCHAR(500) = NULL
	,@PaymentReferenceSet BIT
	,@CreatedDateSet BIT
	,@CreatedStartDate DATETIME
	,@CreatedEndDate DATETIME
	,@PaymentReferenceDateSet BIT 
	,@PaymentReferenceStartDate DATETIME = NULL
	,@PaymentReferenceEndDate DATETIME = NULL
	,@ReconciliationIdSet BIT
	,@ReconciliationId UNIQUEIDENTIFIER 
	,@PaymentStatusSet BIT 
	,@PaymentStatus INT 
	,@PaymentTypeSet BIT 
	,@PaymentType INT 
	,@PaymentMethodTypeSet BIT 
	,@PaymentMethodType INT 
	,@PaymentMethodAccountTypeSet BIT 
	,@PaymentMethodAccountType VARCHAR(255) 
	,@SalesTrackingCode1 as dbo.IDList readonly
	,@SalesTrackingCode2 as dbo.IDList readonly
	,@SalesTrackingCode3 as dbo.IDList readonly
	,@SalesTrackingCode4 as dbo.IDList readonly
	,@SalesTrackingCode5 as dbo.IDList readonly
	,@SalesTrackingCode1Set bit 
	,@SalesTrackingCode2Set bit 
	,@SalesTrackingCode3Set bit 
	,@SalesTrackingCode4Set bit 
	,@SalesTrackingCode5Set bit 
	,@SalesTrackingCode1OrSet bit
	,@SalesTrackingCode2OrSet bit 
	,@SalesTrackingCode3OrSet bit 
	,@SalesTrackingCode4OrSet bit 
	,@SalesTrackingCode5OrSet bit
	'
	,@AccountId 
	,@SortOrder
	,@SortExpression
	,@PageNumber 
	,@PageSize 
	,@CustomerId 
	,@CustomerIdSet 
	,@CustomerReference
	,@CustomerReferenceSet
	,@PaymentReference
	,@PaymentReferenceSet
	,@CreatedDateSet 
	,@CreatedStartDate
	,@CreatedEndDate
	,@PaymentReferenceDateSet  
	,@PaymentReferenceStartDate
	,@PaymentReferenceEndDate
	,@ReconciliationIdSet 
	,@ReconciliationId 
	,@PaymentStatusSet
	,@PaymentStatus 
	,@PaymentTypeSet 
	,@PaymentType 
	,@PaymentMethodTypeSet  
	,@PaymentMethodType  
	,@PaymentMethodAccountTypeSet  
	,@PaymentMethodAccountType 
	,@SalesTrackingCode1 
	,@SalesTrackingCode2 
	,@SalesTrackingCode3 
	,@SalesTrackingCode4 
	,@SalesTrackingCode5
	,@SalesTrackingCode1Set  
	,@SalesTrackingCode2Set  
	,@SalesTrackingCode3Set  
	,@SalesTrackingCode4Set  
	,@SalesTrackingCode5Set  
	,@SalesTrackingCode1OrSet 
	,@SalesTrackingCode2OrSet  
	,@SalesTrackingCode3OrSet  
	,@SalesTrackingCode4OrSet  
	,@SalesTrackingCode5OrSet 



SET NOCOUNT OFF
end

GO

