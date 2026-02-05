CREATE PROC [dbo].[usp_UpdateInvoiceAddress]

	@Id bigint,
	@ModifiedTimestamp datetime,
	@CreatedTimestamp datetime,
	@InvoiceId bigint,
	@CompanyName nvarchar(255),
	@Line1 nvarchar(60),
	@Line2 nvarchar(60),
	@CountryId bigint,
	@StateId bigint,
	@City nvarchar(50),
	@PostalZip nvarchar(10),
	@AddressTypeId int,
	@CountryName nvarchar(250),
	@StateName nvarchar(250),
	@UsedForAvalara bit
AS
SET NOCOUNT ON
	UPDATE [InvoiceAddress] SET 
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[CreatedTimestamp] = @CreatedTimestamp,
		[InvoiceId] = @InvoiceId,
		[CompanyName] = @CompanyName,
		[Line1] = @Line1,
		[Line2] = @Line2,
		[CountryId] = @CountryId,
		[StateId] = @StateId,
		[City] = @City,
		[PostalZip] = @PostalZip,
		[AddressTypeId] = @AddressTypeId,
		[CountryName] = @CountryName,
		[StateName] = @StateName,
		[UsedForAvalara] = @UsedForAvalara
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

