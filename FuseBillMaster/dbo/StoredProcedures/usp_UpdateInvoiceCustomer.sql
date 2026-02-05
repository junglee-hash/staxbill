CREATE PROC [dbo].[usp_UpdateInvoiceCustomer]

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
	UPDATE [InvoiceCustomer] SET 
		[FirstName] = @FirstName,
		[MiddleName] = @MiddleName,
		[LastName] = @LastName,
		[Suffix] = @Suffix,
		[PrimaryEmail] = @PrimaryEmail,
		[PrimaryPhone] = @PrimaryPhone,
		[SecondaryEmail] = @SecondaryEmail,
		[SecondaryPhone] = @SecondaryPhone,
		[TitleId] = @TitleId,
		[Reference] = @Reference,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[EffectiveTimestamp] = @EffectiveTimestamp,
		[ContactName] = @ContactName,
		[ShippingInstructions] = @ShippingInstructions,
		[Title] = @Title,
		[CurrencyId] = @CurrencyId,
		[CompanyName] = @CompanyName
	WHERE [InvoiceId] = @InvoiceId

SET NOCOUNT OFF

GO

