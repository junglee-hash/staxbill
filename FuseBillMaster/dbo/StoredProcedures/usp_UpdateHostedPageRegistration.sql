CREATE PROC [dbo].[usp_UpdateHostedPageRegistration]

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
	UPDATE [HostedPageRegistration] SET 
		[SuccessUrl] = @SuccessUrl,
		[FailureUrl] = @FailureUrl,
		[CustomerInformation] = @CustomerInformation,
		[PlanList] = @PlanList,
		[PaymentMethod] = @PaymentMethod,
		[InvoicePreview] = @InvoicePreview,
		[AllowCoupons] = @AllowCoupons,
		[SalesTrackingCode1Id] = @SalesTrackingCode1Id,
		[SalesTrackingCode2Id] = @SalesTrackingCode2Id,
		[SalesTrackingCode3Id] = @SalesTrackingCode3Id,
		[SalesTrackingCode4Id] = @SalesTrackingCode4Id,
		[SalesTrackingCode5Id] = @SalesTrackingCode5Id,
		[UseLegacyView] = @UseLegacyView,
		[ShowTermsAndConditions] = @ShowTermsAndConditions,
		[TermsCheckboxLabel] = @TermsCheckboxLabel,
		[TermsLink] = @TermsLink,
		[TermsLinkText] = @TermsLinkText
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

