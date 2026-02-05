CREATE PROC [dbo].[usp_InsertCreditCard]
	@MaskedCardNumber varchar(20),
	@ExpirationMonth int,
	@ExpirationYear int,
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
	@Email varchar(255),
	@OriginalPaymentMethodid bigint = null,
	@StoredInStax bit,
	@Sharing bit,
	@IsDebit bit,
	@IsGooglePay bit,
	@FirstSix varchar(6),
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
		@OriginalPaymentMethodid,
		null,
		@StoredInStax,
		@Sharing,
		0, -- Repeat failure count
		@HasMadePayment,
		@PaymentMethodNickname,
		@PermittedForSingleUse

	INSERT INTO [CreditCard] (
		[Id],
		[MaskedCardNumber],
		[ExpirationMonth],
		[ExpirationYear],
		[IsDebit],
		[IsGooglePay],
		[FirstSix]
	)
	VALUES (
		@Id,
		@MaskedCardNumber,
		@ExpirationMonth,
		@ExpirationYear,
		@IsDebit,
		@IsGooglePay,
		@FirstSix
	)
	SELECT @Id As InsertedID
SET NOCOUNT OFF

GO

