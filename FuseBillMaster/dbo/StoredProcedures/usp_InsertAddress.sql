CREATE PROC [dbo].[usp_InsertAddress]

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
	@State nvarchar(250)
AS
SET NOCOUNT ON
	INSERT INTO [Address] (
		[ModifiedTimestamp],
		[CreatedTimestamp],
		[CustomerAddressPreferenceId],
		[CompanyName],
		[Line1],
		[Line2],
		[CountryId],
		[StateId],
		[City],
		[PostalZip],
		[AddressTypeId],
		[County],
		[Validated],
		[Country],
		[State]
	)
	VALUES (
		@ModifiedTimestamp,
		@CreatedTimestamp,
		@CustomerAddressPreferenceId,
		@CompanyName,
		@Line1,
		@Line2,
		@CountryId,
		@StateId,
		@City,
		@PostalZip,
		@AddressTypeId,
		@County,
		@Validated,
		@Country,
		@State
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

