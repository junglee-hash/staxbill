CREATE PROC [dbo].[usp_UpdateAddress]

	@Id bigint,
	@ModifiedTimestamp datetime,
	@CreatedTimestamp datetime,
	@CustomerAddressPreferenceId bigint,
	@CompanyName nvarchar(255),
	@Line1 nvarchar(60),
	@Line2 nvarchar(60),
	@CountryId bigint,
	@StateId bigint,
	@City nvarchar(50),
	@PostalZip nvarchar(10),
	@AddressTypeId int,
	@County nvarchar(150),
	@Validated bit,
	@Country nvarchar(250),
	@State nvarchar(250),
	@Invalid bit
AS
SET NOCOUNT ON
	UPDATE [Address] SET 
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[CustomerAddressPreferenceId] = @CustomerAddressPreferenceId,
		[CompanyName] = @CompanyName,
		[Line1] = @Line1,
		[Line2] = @Line2,
		[CountryId] = @CountryId,
		[StateId] = @StateId,
		[City] = @City,
		[PostalZip] = @PostalZip,
		[AddressTypeId] = @AddressTypeId,
		[County] = @County,
		[Validated] = @Validated,
		[Country] = @Country,
		[State] = @State,
		[Invalid] = @Invalid
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

