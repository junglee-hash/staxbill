----------------------------------usp_insert account feature config


CREATE PROC [dbo].[usp_InsertAccountFeatureConfiguration]

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
	@LegacyTransparentRedirect bit
AS
SET NOCOUNT ON
	INSERT INTO [AccountFeatureConfiguration] (
		[Id],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[SalesforceEnabled],
		[SalesforceSandboxMode],
		[NetsuiteEnabled],
		[AvalaraOrganizationCode],
		[TaxOptionId],
		[PaypalEnabled],
		[WebhooksEnabled],
		[ProductImportEnabled],
		[ProjectedInvoiceEnabled],
		[MrrDisplayTypeId],
		[CustomerHierarchy],
		[QuickBooksEnabled],
		[LegacyTransparentRedirect]
	)
	VALUES (
		@Id,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@SalesforceEnabled,
		@SalesforceSandboxMode,
		@NetsuiteEnabled,
		@AvalaraOrganizationCode,
		@TaxOptionId,
		@PaypalEnabled,
		@WebhooksEnabled,
		@ProductImportEnabled,
		@ProjectedInvoiceEnabled,
		@MrrDisplayTypeId,
		@CustomerHierarchy,
		@QuickBooksEnabled,
		@LegacyTransparentRedirect
	)
	SELECT SCOPE_IDENTITY() As InsertedID

GO

