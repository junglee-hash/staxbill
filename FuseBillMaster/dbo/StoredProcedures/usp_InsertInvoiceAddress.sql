 
 
CREATE PROC [dbo].[usp_InsertInvoiceAddress]

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
	INSERT INTO [InvoiceAddress] (
		[ModifiedTimestamp],
		[CreatedTimestamp],
		[InvoiceId],
		[CompanyName],
		[Line1],
		[Line2],
		[CountryId],
		[StateId],
		[City],
		[PostalZip],
		[AddressTypeId],
		[CountryName],
		[StateName],
		[UsedForAvalara]
	)
	VALUES (
		@ModifiedTimestamp,
		@CreatedTimestamp,
		@InvoiceId,
		@CompanyName,
		@Line1,
		@Line2,
		@CountryId,
		@StateId,
		@City,
		@PostalZip,
		@AddressTypeId,
		@CountryName,
		@StateName,
		@UsedForAvalara
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

