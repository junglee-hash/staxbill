CREATE   procedure [dbo].[usp_GetCustomerAdvancedSearch]
       @AccountId bigint
	   , @CreatedDateRangeStartDate DATETIME = NULL
	   , @CreatedDateRangeEndDate DATETIME = NULL
	   , @NextBillingDateRangeStartDate DATETIME = NULL
	   , @NextBillingDateRangeEndDate DATETIME = NULL
	   , @Statuses IDList READONLY
	   , @AccountingStatuses IDList READONLY
	   , @Subscriptions IDList READONLY
	   , @Currencies IDList READONLY
	   , @Code1 IDList READONLY
	   , @Code2 IDList READONLY
	   , @Code3 IDList READONLY
	   , @Code4 IDList READONLY
	   , @Code5 IDList READONLY
	   , @BalanceOwing MONEY = NULL
	   , @PaymentMethodWarning VARCHAR(100) = NULL
	   , @BillingAddress BIT = NULL
	   , @ShippingAddress BIT = NULL
	   , @AddressCountry BIGINT = NULL
	   , @AddressState BIGINT = NULL
	   , @AddressCity NVARCHAR(50) = NULL
	   , @AddressLine1 NVARCHAR(255) = NULL
	   , @AddressLine2 NVARCHAR(255) = NULL
	   , @AddressZip NVARCHAR(10) = NULL
	   --Paging variables
		, @SortExpression NVARCHAR(255) = NULL
		, @SortOrder NVARCHAR(255) = NULL
		, @PageNumber INT = NULL
		, @PageSize INT = NULL
as

DECLARE @SQL nvarchar(max)

SET @SQL = '
	;WITH TodayInAccountTimezone AS (
		SELECT 
			DATEFROMPARTS(YEAR(dbo.fn_GetTimezoneTime(GETUTCDATE(),tz.Id)), MONTH(dbo.fn_GetTimezoneTime(GETUTCDATE(),tz.Id)), 1) as StartOfMonth
		, ap.Id as AccountId
		FROM AccountPreference ap
		INNER JOIN Lookup.Timezone tz ON tz.Id = ap.TimezoneId
	),
	CTE_CustomerSummary AS (
		SELECT 
			dbo.Customer.Id, dbo.Customer.ParentId, dbo.Customer.IsParent, dbo.Customer.Reference, dbo.Customer.TitleId as [Title], dbo.Customer.FirstName, 
			dbo.Customer.MiddleName, dbo.Customer.LastName, dbo.Customer.Suffix, dbo.Customer.ArBalance, dbo.Customer.EffectiveTimestamp AS CreatedTimestamp, 
			dbo.Customer.AccountId, dbo.Customer.PrimaryEmail, dbo.Customer.PrimaryPhone, dbo.Customer.SecondaryEmail, dbo.Customer.SecondaryPhone, 
			dbo.Customer.NextBillingDate, dbo.Customer.CompanyName, dbo.Customer.StatusId AS CustomerStatus, dbo.Customer.AccountStatusId AS CustomerAccountStatus, 
			Lookup.CustomerAccountStatus.Name AS AccountingStatus, Lookup.CustomerStatus.Name AS Status, dbo.Customer.CurrencyId, 
			CASE WHEN cbs.AutoPostDraftInvoice IS NULL THEN bp.AutoPostDraftInvoice ELSE cbs.AutoPostDraftInvoice END as AutoPostDraftInvoice,
			CASE WHEN cbs.AutoCollect IS NULL THEN bp.DefaultAutoCollect ELSE cbs.AutoCollect END as AutoCollect,
			cr.Reference1, cr.Reference2, cr.Reference3, ca.AdContent, ca.Campaign, ca.Keyword, ca.LandingPage, ca.Medium, ca.Source,
			CASE WHEN bp.AutoSuspendEnabled = 1 AND dbo.Customer.AccountStatusId = 2 AND dbo.Customer.StatusId = 2 
			THEN 	
				(isnull(cbs.CustomerGracePeriod, isnull(bp.AccountGracePeriod, 0)) + isnull(cbs.GracePeriodExtension, 0) - (DATEDIFF(hh,cj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
			ELSE 
				NULL 
			END AS DaysUntilSuspension, 
			CASE WHEN bp.AutoSuspendEnabled = 1 AND dbo.Customer.AccountStatusId = 2 AND dbo.Customer.StatusId = 5 
			THEN 	
				(coalesce(cbs.CustomerAutoCancel, bp.AccountAutoCancel) - (DATEDIFF(hh,csj.EffectiveTimestamp, GETUTCDATE()) / 24)) 
			ELSE 
				NULL
			END AS DaysUntilCancellation, 
			Lookup.Term.Name AS Terms, 
			CASE WHEN (cbs.AutoCollect = 1 OR
			(cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NULL THEN ''Missing'' WHEN (cbs.AutoCollect = 1 OR
			(cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 3 THEN ''Credit Card'' 
			WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 5 THEN ''ACH'' 
			WHEN (cbs.AutoCollect = 1 OR (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 1)) AND pm.Id IS NOT NULL AND pm.PaymentMethodTypeId = 6 THEN ''Paypal'' 
			WHEN (cbs.AutoCollect = 0 OR (cbs.AutoCollect IS NULL AND bp.DefaultAutoCollect = 0)) AND pm.Id IS NOT NULL THEN ''AR - Pay method on file'' 
			WHEN pm.Id IS NULL THEN ''AR'' END AS PaymentMethod, 

			CASE WHEN cbs.DefaultPaymentMethodId IS NULL AND COALESCE(cbs.AutoCollect, bp.DefaultAutoCollect) = 1 THEN ''Missing''
			WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND (
			cc.ExpirationYear IS NULL OR 
			(cc.ExpirationYear = 0 AND cc.ExpirationMonth = 0) OR --0/0 expiry means we do not know when it will expire. treat this case as ''on file''
				DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) >
					DATEADD(month, 2, today.StartOfMonth) -- Expiry is greater than 3 months
			) THEN ''PaymentMethodOnFile'' 
			WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
				DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
					DATEADD(month, 2, today.StartOfMonth) -- Expiry is in 2 months
			THEN ''ExpireInTwoMonths''  
			WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
				DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
					DATEADD(month, 1, today.StartOfMonth) -- Expiry is in 1 month
			THEN ''ExpireInOneMonth''  
			WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
				DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
					DATEADD(month, 0, today.StartOfMonth) -- Expiries this month
			THEN ''ExpiresThisMonth''  
			WHEN cbs.DefaultPaymentMethodId IS NOT NULL AND cc.Id IS NOT NULL AND 
				DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) <
					DATEADD(month, 0, today.StartOfMonth) -- Expiry is in 2 months
			THEN ''Expired''  
				END as PaymentMethodOnFile,
			CASE WHEN pm.PaymentMethodStatusId = 3 THEN CAST(1 as bit) ELSE CAST(0 as bit) END AS IsPaymentMethodDisabled,
			pm.PaymentMethodStatusDisabledTypeId,
			CASE WHEN pm.CustomerId <> Customer.Id THEN CAST(1 as bit) ELSE CAST(0 as bit) END AS IsParentPaymentMethod,
			CASE WHEN afc.MrrDisplayTypeId = 1 THEN dbo.Customer.MonthlyRecurringRevenue ELSE dbo.Customer.CurrentMrr END as MonthlyRecurringRevenue, 
			dbo.Customer.SalesforceId, CASE WHEN afc.MrrDisplayTypeId = 1 THEN dbo.Customer.NetMRR ELSE dbo.Customer.CurrentNetMrr END as NetMRR, 
			cc.MaskedCardNumber, dbo.Customer.NetsuiteId, cr.ClassicId
		,stc1.Id as [SalesTrackingCode1Id]
			,stc1.Code as [SalesTrackingCode1Code]
		,stc1.Name as [SalesTrackingCode1Name]
		,stc2.Id as [SalesTrackingCode2Id]
		,stc2.Code as [SalesTrackingCode2Code]
		,stc2.Name as [SalesTrackingCode2Name]
		,stc3.Id as [SalesTrackingCode3Id]
		,stc3.Code as [SalesTrackingCode3Code]
		,stc3.Name as [SalesTrackingCode3Name]
		,stc4.Id as [SalesTrackingCode4Id]
		,stc4.Code as [SalesTrackingCode4Code]
		,stc4.Name as [SalesTrackingCode4Name]
		,stc5.Id as [SalesTrackingCode5Id]
		,stc5.Code as [SalesTrackingCode5Code]
		,stc5.Name as [SalesTrackingCode5Name]
		,cap.ContactName, cap.ShippingInstructions, cap.UseBillingAddressAsShippingAddress
		,billing.CompanyName as BillingCompanyName, billing.Line1 as BillingLine1, billing.Line2 as BillingLine2
		,billing.City as BillingCity, billing.PostalZip as BillingPostalZip, billingCountry.Name as BillingCountry
		,billingState.Name as BillingState,billing.County as BillingCounty
		,shipping.CompanyName as ShippingCompanyName, shipping.Line1 as ShippingLine1, shipping.Line2 as ShippingLine2
		,shipping.City as ShippingCity, shipping.PostalZip as ShippingPostalZip, shippingCountry.Name as ShippingCountry, shippingState.Name as ShippingState
		FROM dbo.Customer 
		INNER JOIN TodayInAccountTimezone today ON today.AccountId = dbo.Customer.AccountId 
		INNER JOIN dbo.AccountFeatureConfiguration afc ON afc.Id = dbo.Customer.AccountId 
		INNER JOIN dbo.CustomerStatusJournal AS csj ON dbo.Customer.Id = csj.CustomerId AND csj.IsActive = 1 
		INNER JOIN dbo.CustomerAccountStatusJournal AS cj ON dbo.Customer.Id = cj.CustomerId AND cj.IsActive = 1 
		INNER JOIN dbo.CustomerBillingSetting AS cbs ON dbo.Customer.Id = cbs.Id 
		INNER JOIN dbo.AccountBillingPreference AS bp ON dbo.Customer.AccountId = bp.Id 
		INNER JOIN dbo.CustomerAddressPreference AS cap  on dbo.Customer.Id = cap.Id 
		LEFT JOIN [Address] billing ON cap.Id = billing.CustomerAddressPreferenceId AND billing.AddressTypeId = 1
		LEFT JOIN Lookup.Country billingCountry ON billingCountry.Id = billing.CountryId
		LEFT JOIN Lookup.State billingState ON billingState.Id = billing.StateId
		LEFT JOIN [Address] shipping ON cap.Id = shipping.CustomerAddressPreferenceId 
			AND shipping.AddressTypeId = CASE WHEN cap.UseBillingAddressAsShippingAddress = 1 
			THEN 1 ELSE 2 END -- When use billing as shipping join on billing address for the shipping to use in query below
		LEFT JOIN Lookup.Country shippingCountry ON shippingCountry.Id = shipping.CountryId
		LEFT JOIN Lookup.State shippingState ON shippingState.Id = shipping.StateId
		INNER JOIN Lookup.CustomerStatus ON dbo.Customer.StatusId = Lookup.CustomerStatus.Id 
		INNER JOIN Lookup.CustomerAccountStatus ON dbo.Customer.AccountStatusId = Lookup.CustomerAccountStatus.Id 
		INNER JOIN Lookup.Term ON cbs.TermId = Lookup.Term.Id 
		LEFT OUTER JOIN dbo.CustomerAcquisition AS ca ON ca.Id = dbo.Customer.Id 
		LEFT OUTER JOIN dbo.CustomerReference AS cr ON cr.Id = dbo.Customer.Id 
		LEFT JOIN SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
		LEFT JOIN SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
		LEFT JOIN SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
		LEFT JOIN SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
		LEFT JOIN SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
		LEFT OUTER JOIN dbo.PaymentMethod AS PM ON PM.Id = cbs.DefaultPaymentMethodId 
		LEFT OUTER JOIN dbo.CreditCard AS cc ON cc.Id = PM.Id
			'

	IF ((SELECT COUNT(*) FROM @Statuses) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Statuses st ON st.Id = dbo.Customer.StatusId
		'
	END

	IF ((SELECT COUNT(*) FROM @AccountingStatuses) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @AccountingStatuses ass ON ass.Id = dbo.Customer.AccountStatusId
		'
	END

	IF ((SELECT COUNT(*) FROM @Subscriptions) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN Subscription s ON dbo.Customer.Id = s.CustomerId
		INNER JOIN @Subscriptions ss ON ss.Id = s.PlanId
		'
	END

	IF ((SELECT COUNT(*) FROM @Currencies) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Currencies cur ON cur.Id = dbo.Customer.CurrencyId
		'
	END

	IF ((SELECT COUNT(*) FROM @Code1) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Code1 code1 ON code1.Id = cr.SalesTrackingCode1Id
		'
	END

	IF ((SELECT COUNT(*) FROM @Code2) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Code2 code2 ON code2.Id = cr.SalesTrackingCode2Id
		'
	END

	IF ((SELECT COUNT(*) FROM @Code3) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Code3 code3 ON code3.Id = cr.SalesTrackingCode3Id
		'
	END

	IF ((SELECT COUNT(*) FROM @Code4) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Code4 code4 ON code4.Id = cr.SalesTrackingCode4Id
		'
	END

	IF ((SELECT COUNT(*) FROM @Code5) > 0)
	BEGIN
		SET @SQL = @SQL  +  '
		INNER JOIN @Code5 code5 ON code5.Id = cr.SalesTrackingCode5Id
		'
	END

	SET @SQL = @SQL  +  '
	WHERE dbo.Customer.IsDeleted = 0
	AND dbo.Customer.AccountId = @AccountId
	'

	IF (@CreatedDateRangeStartDate IS NOT NULL AND @CreatedDateRangeEndDate IS NOT NULL)
	BEGIN
		SET @SQL = @SQL + '
		AND (dbo.Customer.EffectiveTimestamp >= @CreatedDateRangeStartDate AND dbo.Customer.EffectiveTimestamp <= @CreatedDateRangeEndDate)
		'
	END

	IF (@NextBillingDateRangeStartDate IS NOT NULL AND @NextBillingDateRangeEndDate IS NOT NULL)
	BEGIN
		SET @SQL = @SQL + '
		AND (dbo.Customer.NextBillingDate >= @NextBillingDateRangeStartDate AND dbo.Customer.NextBillingDate <= @NextBillingDateRangeEndDate)
		'
	END

	IF (@BalanceOwing IS NOT NULL)
	BEGIN
		SET @SQL = @SQL + '
		AND dbo.Customer.ArBalance >= @BalanceOwing
		'
	END

	IF (@BillingAddress = 1 AND @ShippingAddress = 1)
	BEGIN
		SET @SQL = @SQL + '
		AND (
		(
		1 = 1
		'
	END

	IF (@BillingAddress = 1)
	BEGIN
		IF (@AddressCountry IS NOT NULL)
		BEGIN
			SET @SQL = @SQL + '
			AND billing.CountryId = @AddressCountry
			'
		END

		IF (@AddressState IS NOT NULL)
		BEGIN
			SET @SQL = @SQL + '
			AND billing.StateId = @AddressState
			'
		END

		IF (@AddressCity IS NOT NULL AND LEN(@AddressCity) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND billing.City LIKE ''%'' + @AddressCity + ''%''
			'
		END

		IF (@AddressLine1 IS NOT NULL AND LEN(@AddressLine1) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND billing.Line1 LIKE ''%'' + @AddressLine1 + ''%''
			'
		END

		IF (@AddressLine2 IS NOT NULL AND LEN(@AddressLine2) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND billing.Line2 LIKE ''%'' + @AddressLine2 + ''%''
			'
		END

		IF (@AddressZip IS NOT NULL AND LEN(@AddressZip) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND billing.PostalZip LIKE ''%'' + @AddressZip + ''%''
			'
		END
	END

	IF (@BillingAddress = 1 AND @ShippingAddress = 1)
	BEGIN
		SET @SQL = @SQL + '
		)
		OR
		(
		1 = 1
		'
	END

	IF (@ShippingAddress = 1)
	BEGIN
		IF (@AddressCountry IS NOT NULL)
		BEGIN
			SET @SQL = @SQL + '
			AND shipping.CountryId = @AddressCountry
			'
		END

		IF (@AddressState IS NOT NULL)
		BEGIN
			SET @SQL = @SQL + '
			AND shipping.StateId = @AddressState
			'
		END

		IF (@AddressCity IS NOT NULL AND LEN(@AddressCity) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND shipping.City LIKE ''%'' + @AddressCity + ''%''
			'
		END

		IF (@AddressLine1 IS NOT NULL AND LEN(@AddressLine1) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND shipping.Line1 LIKE ''%'' + @AddressLine1 + ''%''
			'
		END

		IF (@AddressLine2 IS NOT NULL AND LEN(@AddressLine2) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND shipping.Line2 LIKE ''%'' + @AddressLine2 + ''%''
			'
		END

		IF (@AddressZip IS NOT NULL AND LEN(@AddressZip) > 0)
		BEGIN
			SET @SQL = @SQL + '
			AND shipping.PostalZip LIKE ''%'' + @AddressZip + ''%''
			'
		END
	END

	IF (@BillingAddress = 1 AND @ShippingAddress = 1)
	BEGIN
		SET @SQL = @SQL + '
		)
		)
		'
	END

	SET @SQL = @SQL + '
	)
	SELECT * 
	INTO #CustomerSummary
	FROM CTE_CustomerSummary
	'

	IF (@PaymentMethodWarning IS NOT NULL AND LEN(@PaymentMethodWarning) > 0)
	BEGIN
		IF (@PaymentMethodWarning = 'Disabled')
		BEGIN
			SET @SQL = @SQL + '
			WHERE IsPaymentMethodDisabled = 1
			'
		END
		ELSE
		BEGIN
			SET @SQL = @SQL + '
			WHERE PaymentMethodOnFile = @PaymentMethodWarning
			'
		END
	END

	SET @SQL = @SQL + '
	SELECT * FROM #CustomerSummary
	'

	IF (@SortOrder IS NOT NULL AND @SortExpression IS NOT NULL)
	BEGIN
		SET @SQL = @SQL + '
		ORDER BY 
			CASE WHEN @SortOrder = ''Ascending'' THEN '+@SortExpression+' END ASC, 
			CASE WHEN @SortOrder = ''Descending'' THEN '+@SortExpression+' END DESC
		'
	END

	IF (@PageSize IS NOT NULL AND @PageNumber IS NOT NULL)
	BEGIN
		SET @SQL = @SQL + '
		OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
		'
	END

	SET @SQL = @SQL + '
	SELECT COUNT(*) as TotalCustomers
	FROM #CustomerSummary
	'

	--print cast( substring(@SQL, 1, 16000) as ntext )
 --   print cast( substring(@SQL, 16001, 32000) as ntext )
 --   print cast( substring(@SQL, 32001, 48000) as ntext )
 --   print cast( substring(@SQL, 48001, 64000) as ntext )

exec sp_executesql @SQL, N'@AccountId bigint, @CreatedDateRangeStartDate DATETIME, @CreatedDateRangeEndDate DATETIME, 
		@NextBillingDateRangeStartDate DATETIME, @NextBillingDateRangeEndDate DATETIME, @BalanceOwing MONEY, @PaymentMethodWarning VARCHAR(100), @Statuses IDList READONLY, 
		@AccountingStatuses IDList READONLY, @Subscriptions IDList READONLY, @Currencies IDList READONLY, @Code1 IDList READONLY,
		@Code2 IDList READONLY, @Code3 IDList READONLY, @Code4 IDList READONLY, @Code5 IDList READONLY, @BillingAddress BIT, @ShippingAddress BIT,
		@AddressCountry BIGINT, @AddressState BIGINT, @AddressCity NVARCHAR(50), @AddressLine1 NVARCHAR(255), @AddressLine2 NVARCHAR(255), @AddressZip NVARCHAR(10),
		@SortOrder NVARCHAR(255), @SortExpression NVARCHAR(255), @PageNumber BIGINT, @PageSize BIGINT'
	,@AccountId,@CreatedDateRangeStartDate,@CreatedDateRangeEndDate,@NextBillingDateRangeStartDate,@NextBillingDateRangeEndDate,@BalanceOwing,@PaymentMethodWarning,
	@Statuses,@AccountingStatuses,@Subscriptions,@Currencies,@Code1,@Code2,@Code3,@Code4,@Code5,@BillingAddress,@ShippingAddress,@AddressCountry,@AddressState,
	@AddressCity,@AddressLine1,@AddressLine2,@AddressZip,@SortOrder,@SortExpression,@PageNumber,@PageSize

GO

