CREATE PROC [dbo].[usp_UpdateCreditCard]

	@Id bigint,
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
	@OriginalPaymentMethodId bigint = null,
	@StoredInStax bit,
	@Sharing bit,
	@RepeatFailureCount int = 0,
	@IsDebit bit, 
	@IsGooglePay bit,
	@FirstSix varchar(6),
	@HasMadePayment bit,
	@PaymentMethodStatusDisabledTypeId int,
	@PaymentMethodNickname varchar(50),
	@PermittedForSingleUse bit
AS
SET NOCOUNT ON
	EXEC usp_UpdatePaymentMethod
		@Id,
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
		@OriginalPaymentMethodId,
		null,
		@StoredInStax,
		@Sharing,
		@RepeatFailureCount,
		@HasMadePayment,
		@PaymentMethodStatusDisabledTypeId,
		@PaymentMethodNickname,
		@PermittedForSingleUse

	UPDATE [CreditCard] SET 
		[MaskedCardNumber] = @MaskedCardNumber,
		[ExpirationMonth] = @ExpirationMonth,
		[ExpirationYear] = @ExpirationYear,
		[IsDebit] = @IsDebit,
		[IsGooglePay] = @IsGooglePay,
		[FirstSix] = @FirstSix
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

