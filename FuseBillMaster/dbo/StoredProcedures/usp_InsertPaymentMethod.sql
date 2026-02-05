CREATE PROC [dbo].[usp_InsertPaymentMethod]

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
	@OriginalPaymentMethodid bigint = null,
	@BusinessTaxId varchar(30) = null,
	@StoredInStax bit,
	@Sharing bit = null,
	@RepeatFailureCount int = 0,
	@HasMadePayment bit,
	@PaymentMethodNickname varchar(50) = null,
	@PermittedForSingleUse bit = 0
AS
SET NOCOUNT ON
	INSERT INTO [PaymentMethod] (
		[CustomerId],
		[FirstName],
		[LastName],
		[Address1],
		[Address2],
		[City],
		[StateId],
		[CountryId],
		[PostalZip],
		[Token],
		[PaymentMethodStatusId],
		[AccountType],
		[PaymentMethodTypeId],
		[ExternalCustomerId],
		[ExternalCardId],
		[StoredInFusebillVault],
		[ModifiedTimestamp],
		[Email],
		[OriginalPaymentMethodId],
		[CreatedTimestamp],
		[BusinessTaxId],
		[StoredInStax],
		[Sharing],
		[RepeatFailureCount],
		[HasMadePayment],
		[PaymentMethodNickname],
		[PermittedForSingleUse]
	)
	VALUES (
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
		GETUTCDATE(),
		@BusinessTaxId,
		@StoredInStax,
		@Sharing,
		@RepeatFailureCount,
		@HasMadePayment,
		@PaymentMethodNickname,
		@PermittedForSingleUse
	)

	IF (@PaymentMethodTypeId = 6 or @PaymentMethodTypeId = 9) --Paypal
	BEGIN
		SELECT SCOPE_IDENTITY() as InsertedId
	END
	ELSE
	BEGIN
		RETURN SCOPE_IDENTITY()
	END
SET NOCOUNT OFF

GO

