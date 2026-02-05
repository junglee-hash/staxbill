CREATE PROC [dbo].[usp_InsertAccountBrandingPreference]

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
	@Logo varchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [AccountBrandingPreference] (
		[Id],
		[CompanyName],
		[Address1],
		[Address2],
		[City],
		[StateId],
		[CountryId],
		[PostalZip],
		[SupportEmail],
		[BillingEmail],
		[WebsiteLabel],
		[WebsiteUrl],
		[BillingPhone],
		[SupportPhone],
		[Fax],
		[FromEmail],
		[ReplyToEmail],
		[FromDisplay],
		[ReplyToDisplay],
		[BccEmail],
		[Logo]
	)
	VALUES (
		@Id,
		@CompanyName,
		@Address1,
		@Address2,
		@City,
		@StateId,
		@CountryId,
		@PostalZip,
		@SupportEmail,
		@BillingEmail,
		@WebsiteLabel,
		@WebsiteUrl,
		@BillingPhone,
		@SupportPhone,
		@Fax,
		@FromEmail,
		@ReplyToEmail,
		@FromDisplay,
		@ReplyToDisplay,
		@BccEmail,
		@Logo
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

