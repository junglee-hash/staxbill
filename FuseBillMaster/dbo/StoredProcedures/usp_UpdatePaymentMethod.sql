CREATE PROC [dbo].[usp_UpdatePaymentMethod]

	@Id bigint,
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
	@OriginalPaymentMethodId bigint = null,
	@BusinessTaxId varchar(30) = null,
	@StoredInStax bit,
	@Sharing bit,
	@RepeatFailureCount int = 0,
	@HasMadePayment bit,
	@PaymentMethodStatusDisabledTypeId int,
	@PaymentMethodNickname varchar(50),
	@PermittedForSingleUse bit
AS
SET NOCOUNT ON
	UPDATE [PaymentMethod] SET 
		[CustomerId] = @CustomerId,
		[FirstName] = @FirstName,
		[LastName] = @LastName,
		[Address1] = @Address1,
		[Address2] = @Address2,
		[City] = @City,
		[StateId] = @StateId,
		[CountryId] = @CountryId,
		[PostalZip] = @PostalZip,
		[Token] = @Token,
		[PaymentMethodStatusId] = @PaymentMethodStatusId,
		[AccountType] = @AccountType,
		[PaymentMethodTypeId] = @PaymentMethodTypeId,
		[ExternalCustomerId] = @ExternalCustomerId,
		[ExternalCardId] = @ExternalCardId,
		[StoredInFusebillVault] = @StoredInFusebillVault,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Email] = @Email,
		[OriginalPaymentMethodId] = @OriginalPaymentMethodId,
		[BusinessTaxId] = @BusinessTaxId,
		[StoredInStax] = @StoredInStax,
		[Sharing] = @Sharing,
		[RepeatFailureCount] = @RepeatFailureCount,
		[HasMadePayment] = @HasMadePayment,
		[PaymentMethodStatusDisabledTypeId] = @PaymentMethodStatusDisabledTypeId,
		[PaymentMethodNickname] = @PaymentMethodNickname,
		[PermittedForSingleUse] = @PermittedForSingleUse
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

