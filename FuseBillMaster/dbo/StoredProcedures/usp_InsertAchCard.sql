
CREATE PROC [dbo].[usp_InsertAchCard]
	@MaskedAccountNumber varchar(20),
	@MaskedTransitNumber varchar(20),
	@CustomerId bigint,
	@FirstName nvarchar(50),
	@LastName nvarchar(50),
	@Address1 nvarchar(50),
	@Address2 nvarchar(50),
	@City nvarchar(50),
	@StateId bigint,
	@CountryId bigint,
	@PostalZip nvarchar(10),
	@Token nvarchar(1000),
	@PaymentMethodStatusId int,
	@AccountType varchar(50),
	@PaymentMethodTypeId int,
	@ExternalCustomerId nvarchar(1000),
	@ExternalCardId nvarchar(1000),
	@StoredInFusebillVault bit,
	@ModifiedTimestamp datetime,
	@Email varchar(255) = null,
	@BusinessTaxId varchar(30) = null,
	@StoredInStax bit,
	@Sharing bit,
	@HasMadePayment bit,
	@PaymentMethodNickname varchar(50),
	@PermittedForSingleUse bit
AS
SET NOCOUNT ON

	DECLARE @Id bigint

	EXEC @Id = usp_InsertPaymentMethod
		@CustomerId,
		@FirstName,
		@LastName,
		@Address1,
		@Address2,
		@City,
		@StateId,
		@CountryId,
		@PostalZip,
		@Token,
		@PaymentMethodStatusId,
		@AccountType,
		@PaymentMethodTypeId,
		@ExternalCustomerId,
		@ExternalCardId,
		@StoredInFusebillVault,
		@ModifiedTimestamp,
		@Email,
		null,
		@BusinessTaxId,
		@StoredInStax,
		@Sharing,
		0, -- Repeat failure count
		@HasMadePayment,
		@PaymentMethodNickname,
		@PermittedForSingleUse

	INSERT INTO [AchCard] (
		[Id],
		[MaskedAccountNumber],
		[MaskedTransitNumber]
	)
	VALUES (
		@Id,
		@MaskedAccountNumber,
		@MaskedTransitNumber
	)
	SELECT @Id As InsertedID
SET NOCOUNT OFF

GO

