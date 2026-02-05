CREATE   PROCEDURE [dbo].[usp_GetFullHostedPage]
	@hostedPageId bigint,
	@accountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		*
		, [HostedPageTypeId] as [HostedPageType]
		, [HostedPageDomainId] as [HostedPageDomain]
		, [HostedPageStatusId] as [HostedPageStatus]
		, [NoPaymentTermId] as [NoPaymentTerm]
		, hp.EnableSingleSignOn as [EnableSingleSignOn]
	FROM [dbo].[HostedPageRegistration] hpr
	INNER JOIN [dbo].[HostedPage] hp ON hp.Id = hpr.Id
	WHERE hp.[Id] = @hostedPageId
		AND hp.AccountId = @accountId

	SELECT
		*
		, [HostedPageTypeId] as [HostedPageType]
		, [HostedPageDomainId] as [HostedPageDomain]
		, [HostedPageStatusId] as [HostedPageStatus]
		, [SubscriptionCancellationReversalOptionId] as [SubscriptionCancellationReversalOption]
		, [QuantityManagementId] as [QuantityManagement]
		, [InclusionManagementId] as [InclusionManagement]
		, [TerminationButtonOptionId] as [TerminationButtonOption]
		, hp.EnableSingleSignOn as [EnableSingleSignOn]
	FROM [dbo].[HostedPageSelfServicePortal] hps
	INNER JOIN [dbo].[HostedPage] hp ON hp.Id = hps.Id
	WHERE hp.[Id] = @hostedPageId
		AND hp.AccountId = @accountId

	SELECT
		*
		, [HostedPageTypeId] as [HostedPageType]
		, [HostedPageDomainId] as [HostedPageDomain]
		, [HostedPageStatusId] as [HostedPageStatus]
		, hp.EnableSingleSignOn as [EnableSingleSignOn]
	FROM [dbo].[HostedPage] hp
	WHERE [Id] = @hostedPageId
		AND hp.AccountId = @accountId

	SELECT
		*
		, [StatusTypeId] as [StatusType]
	FROM [dbo].[HostedPageManagedSelfServicePortal] mp
	INNER Join [dbo].[HostedPage] hp on hp.Id = mp.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	And hp.AccountId = @accountId

	SELECT
		*
	FROM [dbo].[HostedPageManagedSectionHome] home
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = home.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	And AccountId = @accountId

	SELECT
		*
		, [MigrationTimingId] as [MigrationTiming]
	FROM [dbo].[HostedPagePlanFamilyRelationship] pf
	INNER JOIN HostedPage hp on hp.Id = pf.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		*
		, [SubscriptionCancellationReversalOptionId] as [SubscriptionCancellationReversalOption]
		, [QuantityManagementId] as [QuantityManagement]
		, [InclusionManagementId] as [InclusionManagement]
		, [TerminationButtonOptionId] as [TerminationButtonOption]
	FROM [dbo].[HostedPageManagedSectionSubscription] sub
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = sub.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		hpmcor.*
	FROM [dbo].HostedPageManagedCurrencyOfferingRelationship hpmcor
	INNER JOIN [dbo].[HostedPageManagedSectionSubscription] sub ON sub.Id = hpmcor.HostedPageManagedSectionSubscriptionId
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = sub.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		*,
		AllowDeleteLastPaymentMethod
	FROM [dbo].[HostedPageManagedSectionPaymentMethod] payment
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = payment.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		nav.*
	FROM [dbo].[HostedPageManagedSectionNavigation] nav
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = nav.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	select 
		pur.*
	from dbo.HostedPageManagedSectionPurchase pur
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = pur.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	select 
		st.*
	from dbo.HostedPageManagedSectionStatement st
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = st.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		mig.*
		, mig.[MigrationTimingId] as [MigrationTiming]
	FROM [dbo].[HostedPageManagedSectionMigration] mig
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = mig.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE portal.HostedPageId = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		offer.*
	FROM [dbo].[HostedPageManagedOffering] offer
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = offer.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE portal.HostedPageId = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		poff.*
	FROM [dbo].[HostedPageManagedOfferingPlan] poff
	INNER JOIN [dbo].[HostedPageManagedOffering] offer ON offer.Id = poff.HostedPageManagedOfferingId
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = offer.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE portal.HostedPageId = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		hpi.*
	FROM [dbo].[HostedPageManagedSectionInvoice] hpi 
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = hpi.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		quote.*
	FROM [dbo].[HostedPageManagedQuote] quote
	INNER Join [dbo].[HostedPage] hp on hp.Id = quote.HostedPageId
	WHERE quote.HostedPageId = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		hpi.*
	FROM [dbo].[HostedPageManagedSectionLabel] hpi
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = hpi.Id
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT
		hpi.*
	FROM [dbo].[HostedPageManagedSectionProfile] hpi
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = hpi.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT * FROM Lookup.CustomerInformationField

	SELECT
		pofci.*
	FROM [dbo].[HostedPageManagedAvailableCountry] pofci
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] hpo ON hpo.Id = pofci.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = hpo.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
		AND hp.AccountId = @accountId

	SELECT
		hpspml.*
	FROM [dbo].[HostedPageManagedSectionPaymentMethodLabel] hpspml
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] portal ON portal.Id = hpspml.HostedPageManagedSelfServicePortalId
	INNER Join [dbo].[HostedPage] hp on hp.Id = portal.HostedPageId
	WHERE [HostedPageId] = @hostedPageId
	AND hp.AccountId = @accountId

	SELECT *
	FROM Lookup.PaymentMethodField

END

GO

