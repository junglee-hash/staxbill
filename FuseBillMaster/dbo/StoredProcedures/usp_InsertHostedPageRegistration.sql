 
 
CREATE PROC [dbo].[usp_InsertHostedPageRegistration]

	@Id bigint,
	@SuccessUrl varchar(100),
	@FailureUrl varchar(100),
	@CustomerInformation nvarchar(Max),
	@PlanList nvarchar(Max),
	@PaymentMethod nvarchar(Max),
	@InvoicePreview nvarchar(Max),
	@AllowCoupons bit,
	@SalesTrackingCode1Id bigint,
	@SalesTrackingCode2Id bigint,
	@SalesTrackingCode3Id bigint,
	@SalesTrackingCode4Id bigint,
	@SalesTrackingCode5Id bigint,
	@UseLegacyView bit,
	@ShowTermsAndConditions bit,
	@TermsCheckboxLabel varchar(255),
	@TermsLink varchar(255),
	@TermsLinkText varchar(255)
AS
SET NOCOUNT ON
	INSERT INTO [HostedPageRegistration] (
		[Id],
		[SuccessUrl],
		[FailureUrl],
		[CustomerInformation],
		[PlanList],
		[PaymentMethod],
		[InvoicePreview],
		[AllowCoupons],
		[SalesTrackingCode1Id],
		[SalesTrackingCode2Id],
		[SalesTrackingCode3Id],
		[SalesTrackingCode4Id],
		[SalesTrackingCode5Id],
		[UseLegacyView],
		[ShowTermsAndConditions],
		[TermsCheckboxLabel],
		[TermsLink],
		[TermsLinkText]
	)
	VALUES (
		@Id,
		@SuccessUrl,
		@FailureUrl,
		@CustomerInformation,
		@PlanList,
		@PaymentMethod,
		@InvoicePreview,
		@AllowCoupons,
		@SalesTrackingCode1Id,
		@SalesTrackingCode2Id,
		@SalesTrackingCode3Id,
		@SalesTrackingCode4Id,
		@SalesTrackingCode5Id,
		@UseLegacyView,
		@ShowTermsAndConditions,
		@TermsCheckboxLabel,
		@TermsLink,
		@TermsLinkText
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

