 
 
CREATE PROC [dbo].[usp_InsertProduct]

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
	INSERT INTO [Product] (
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[Code],
		[Name],
		[Description],
		[ProductTypeId],
		[AccountId],
		[ProductStatusId],
		[TaxExempt],
		[AvailableForPurchase],
		[Quantity],
		[OrderToCashCycleId],
		[IsTrackingItems],
		[AvalaraItemCode],
		[AvalaraTaxCode],
		[GLCodeId]
	)
	VALUES (
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@Code,
		@Name,
		@Description,
		@ProductTypeId,
		@AccountId,
		@ProductStatusId,
		@TaxExempt,
		@AvailableForPurchase,
		@Quantity,
		@OrderToCashCycleId,
		@IsTrackingItems,
		@AvalaraItemCode,
		@AvalaraTaxCode,
		@GLCodeId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

