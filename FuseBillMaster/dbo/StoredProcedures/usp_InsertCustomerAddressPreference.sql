 
 
CREATE PROC [dbo].[usp_InsertCustomerAddressPreference]

	@Id bigint,
	@ContactName nvarchar(100),
	@ShippingInstructions nvarchar(1000),
	@UseBillingAddressAsShippingAddress bit,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerAddressPreference] (
		[Id],
		[ContactName],
		[ShippingInstructions],
		[UseBillingAddressAsShippingAddress],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@Id,
		@ContactName,
		@ShippingInstructions,
		@UseBillingAddressAsShippingAddress,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

