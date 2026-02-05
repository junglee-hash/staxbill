CREATE PROC [dbo].[usp_UpdateAccountBrandingPreference]

	@Id bigint,
	@CompanyName nvarchar(255),
	@Address1 nvarchar(255),
	@Address2 nvarchar(255),
	@City nvarchar(255),
	@StateId bigint,
	@CountryId bigint,
	@PostalZip nvarchar(10),
	@SupportEmail nvarchar(255),
	@BillingEmail nvarchar(255),
	@WebsiteLabel nvarchar(255),
	@WebsiteUrl nvarchar(255),
	@BillingPhone varchar(50),
	@SupportPhone varchar(50),
	@Fax varchar(20),
	@FromEmail varchar(50),
	@ReplyToEmail varchar(50),
	@FromDisplay varchar(50),
	@ReplyToDisplay varchar(50),
	@BccEmail varchar(255),
	@IsRestrictEmailSending bit,
	@StartEmailHour int,
	@EndEmailHour int,
	@Logo varchar(500)
AS
SET NOCOUNT ON
	UPDATE [AccountBrandingPreference] SET 
		[CompanyName] = @CompanyName,
		[Address1] = @Address1,
		[Address2] = @Address2,
		[City] = @City,
		[StateId] = @StateId,
		[CountryId] = @CountryId,
		[PostalZip] = @PostalZip,
		[SupportEmail] = @SupportEmail,
		[BillingEmail] = @BillingEmail,
		[WebsiteLabel] = @WebsiteLabel,
		[WebsiteUrl] = @WebsiteUrl,
		[BillingPhone] = @BillingPhone,
		[SupportPhone] = @SupportPhone,
		[Fax] = @Fax,
		[FromEmail] = @FromEmail,
		[ReplyToEmail] = @ReplyToEmail,
		[FromDisplay] = @FromDisplay,
		[ReplyToDisplay] = @ReplyToDisplay,
		[BccEmail] = @BccEmail,
		[IsRestrictEmailSending] = @IsRestrictEmailSending,
		[StartEmailHour] = @StartEmailHour,
		[EndEmailHour] = @EndEmailHour,
		[Logo] = @Logo
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

