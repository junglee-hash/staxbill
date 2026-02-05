CREATE PROC [dbo].[usp_UpdateCustomerAddressPreference]

	@Id bigint,
	@ContactName nvarchar(100),
	@ShippingInstructions nvarchar(1000),
	@UseBillingAddressAsShippingAddress bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerAddressPreference] SET 
		[ContactName] = @ContactName,
		[ShippingInstructions] = @ShippingInstructions,
		[UseBillingAddressAsShippingAddress] = @UseBillingAddressAsShippingAddress,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

