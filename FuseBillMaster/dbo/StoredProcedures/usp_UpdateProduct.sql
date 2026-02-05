CREATE PROC [dbo].[usp_UpdateProduct]

	@Id bigint,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@Code nvarchar(1000),
	@Name nvarchar(100),
	@Description nvarchar(1000),
	@ProductTypeId int,
	@AccountId bigint,
	@ProductStatusId int,
	@TaxExempt bit,
	@AvailableForPurchase bit,
	@Quantity decimal,
	@OrderToCashCycleId bigint,
	@IsTrackingItems bit,
	@AvalaraItemCode nvarchar(50),
	@AvalaraTaxCode nvarchar(25),
	@GLCodeId bigint
AS
SET NOCOUNT ON
	UPDATE [Product] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[Code] = @Code,
		[Name] = @Name,
		[Description] = @Description,
		[ProductTypeId] = @ProductTypeId,
		[AccountId] = @AccountId,
		[ProductStatusId] = @ProductStatusId,
		[TaxExempt] = @TaxExempt,
		[AvailableForPurchase] = @AvailableForPurchase,
		[Quantity] = @Quantity,
		[OrderToCashCycleId] = @OrderToCashCycleId,
		[IsTrackingItems] = @IsTrackingItems,
		[AvalaraItemCode] = @AvalaraItemCode,
		[AvalaraTaxCode] = @AvalaraTaxCode,
		[GLCodeId] = @GLCodeId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

