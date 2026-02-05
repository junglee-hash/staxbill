 
 
CREATE PROC [dbo].[usp_InsertInvoiceCustomer]

	@InvoiceId bigint,
	@FirstName nvarchar(50),
	@MiddleName nvarchar(50),
	@LastName nvarchar(50),
	@Suffix nvarchar(50),
	@PrimaryEmail varchar(255),
	@PrimaryPhone varchar(50),
	@SecondaryEmail varchar(255),
	@SecondaryPhone varchar(50),
	@TitleId int,
	@Reference nvarchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@EffectiveTimestamp datetime,
	@ContactName nvarchar(250),
	@ShippingInstructions nvarchar(1000),
	@Title nvarchar(20),
	@CurrencyId bigint,
	@CompanyName nvarchar(255)
AS
SET NOCOUNT ON
	INSERT INTO [InvoiceCustomer] (
		[InvoiceId],
		[FirstName],
		[MiddleName],
		[LastName],
		[Suffix],
		[PrimaryEmail],
		[PrimaryPhone],
		[SecondaryEmail],
		[SecondaryPhone],
		[TitleId],
		[Reference],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[EffectiveTimestamp],
		[ContactName],
		[ShippingInstructions],
		[Title],
		[CurrencyId],
		[CompanyName]
	)
	VALUES (
		@InvoiceId,
		@FirstName,
		@MiddleName,
		@LastName,
		@Suffix,
		@PrimaryEmail,
		@PrimaryPhone,
		@SecondaryEmail,
		@SecondaryPhone,
		@TitleId,
		@Reference,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@EffectiveTimestamp,
		@ContactName,
		@ShippingInstructions,
		@Title,
		@CurrencyId,
		@CompanyName
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

