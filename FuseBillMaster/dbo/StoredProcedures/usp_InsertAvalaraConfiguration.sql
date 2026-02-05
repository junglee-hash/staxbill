CREATE PROC [dbo].[usp_InsertAvalaraConfiguration]

	@Id bigint,
	@Enabled bit,
	@AccountNumber nvarchar(255),
	@LicenseKey nvarchar(255),
	@OrganizationCode nvarchar(255),
	@DevMode bit,
	@Line1 nvarchar(60),
	@Line2 nvarchar(60),
	@CountryId bigint,
	@StateId bigint,
	@City nvarchar(50),
	@PostalZip nvarchar(10),
	@Salt nvarchar(32),
	@CommitTaxes bit,
	@NexusOption int,
	@ExemptionCertificateManagement bit,
	@CompanyId bigint
AS
SET NOCOUNT ON
	INSERT INTO [AvalaraConfiguration] (
		[Id],
		[Enabled],
		[AccountNumber],
		[LicenseKey],
		[OrganizationCode],
		[DevMode],
		[Line1],
		[Line2],
		[CountryId],
		[StateId],
		[City],
		[PostalZip],
		[Salt],
		[CommitTaxes],
		[NexusOption],
		[ExemptionCertificateManagement],
		[CompanyId]
	)
	VALUES (
		@Id,
		@Enabled,
		@AccountNumber,
		@LicenseKey,
		@OrganizationCode,
		@DevMode,
		@Line1,
		@Line2,
		@CountryId,
		@StateId,
		@City,
		@PostalZip,
		@Salt,
		@CommitTaxes,
		@NexusOption,
		@ExemptionCertificateManagement,
		@CompanyId
	)
	SELECT SCOPE_IDENTITY() As InsertedID

GO

