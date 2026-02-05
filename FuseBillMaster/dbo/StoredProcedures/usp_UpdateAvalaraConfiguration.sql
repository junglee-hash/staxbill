CREATE   PROC [dbo].[usp_UpdateAvalaraConfiguration]

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
	UPDATE [AvalaraConfiguration] SET 
		[Enabled] = @Enabled,
		[AccountNumber] = @AccountNumber,
		[LicenseKey] = @LicenseKey,
		[OrganizationCode] = @OrganizationCode,
		[DevMode] = @DevMode,
		[Line1] = @Line1,
		[Line2] = @Line2,
		[CountryId] = @CountryId,
		[StateId] = @StateId,
		[City] = @City,
		[PostalZip] = @PostalZip,
		[Salt] = @Salt,
		[CommitTaxes] = @CommitTaxes,
		[NexusOption] = @NexusOption,
		[ExemptionCertificateManagement] = @ExemptionCertificateManagement,
		[CompanyId] = @CompanyId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

