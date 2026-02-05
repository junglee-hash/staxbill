----------------------------------usp_update account feature config


CREATE PROC [dbo].[usp_UpdateAccountFeatureConfiguration]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@SalesforceEnabled bit,
	@SalesforceSandboxMode bit,
	@NetsuiteEnabled bit,
	@AvalaraOrganizationCode varchar(255),
	@TaxOptionId int,
	@PaypalEnabled bit,
	@WebhooksEnabled bit,
	@ProductImportEnabled bit,
	@ProjectedInvoiceEnabled bit,
	@MrrDisplayTypeId int,
	@CustomerHierarchy bit,
	@QuickBooksEnabled bit,
	@InvoiceInAdvance bit,
	@PreventCreditCardValidation bit,
	@LegacyTransparentRedirect bit
AS
SET NOCOUNT ON
	UPDATE [AccountFeatureConfiguration] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[SalesforceEnabled] = @SalesforceEnabled,
		[SalesforceSandboxMode] = @SalesforceSandboxMode,
		[NetsuiteEnabled] = @NetsuiteEnabled,
		[AvalaraOrganizationCode] = @AvalaraOrganizationCode,
		[TaxOptionId] = @TaxOptionId,
		[PaypalEnabled] = @PaypalEnabled,
		[WebhooksEnabled] = @WebhooksEnabled,
		[ProductImportEnabled] = @ProductImportEnabled,
		[ProjectedInvoiceEnabled] = @ProjectedInvoiceEnabled,
		[MrrDisplayTypeId] = @MrrDisplayTypeId,
		[CustomerHierarchy] = @CustomerHierarchy,
		[QuickBooksEnabled] = @QuickBooksEnabled,
		[InvoiceInAdvance] = @InvoiceInAdvance,
		[PreventCreditCardValidation] = @PreventCreditCardValidation,
		[LegacyTransparentRedirect] = @LegacyTransparentRedirect
	WHERE [Id] = @Id

GO

