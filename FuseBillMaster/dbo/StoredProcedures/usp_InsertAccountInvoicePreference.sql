CREATE PROC [dbo].[usp_InsertAccountInvoicePreference]

	@Id bigint,
	@NextInvoiceNumber int,
	@InvoiceSignature nvarchar(Max),
	@ShowShippingAddress bit,
	@InvoiceNote nvarchar(4000),
	@RollUpTaxes bit,
	@PurchaseLabel nvarchar(255),
	@ShowTrackedItemName bit,
	@ShowTrackedItemReference bit,
	@ShowTrackedItemDescription bit,
	@ShowTrackedItemCreatedDate bit,
	@TrackedItemDisplayFormatId int,
	@TrackedItemNameFieldOverride nvarchar(100),
	@TrackedItemReferenceFieldOverride nvarchar(100),
	@TrackedItemDescriptionFieldOverride nvarchar(100),	
	@TrackedItemCreatedDateFieldOverride nvarchar(100),
	@TrackedItemMainInvoiceMessage nvarchar(500),
	@TrackedItemPageLabelOverride nvarchar(100),
	@InvoiceCustomerReferenceOption int,
	@LayoutId int,
	@RollUpDiscounts bit,
	@ProjectedNotes nvarchar(4000),
	@ProjectedIncludeWatermark bit,
	@DraftInvoiceIncludeWatermark bit,
	@ShowServiceDates bit,
	@InvoiceSummarization bit,
	@PdfRollUpDisplayName bit,
	@PdfRollUpDisplayDescription bit,
	@PdfRollUpDisplayAllUnitPrices bit, 
	@PdfInvoiceEmailAttachmentOption tinyint,
	@InvoiceSummarizationOption tinyint,
	@ChargeGroupOrderId tinyint,
	@ShowPaymentDetails bit,
	@InvoiceIncludeWatermark bit
AS
SET NOCOUNT ON
	INSERT INTO [AccountInvoicePreference] (
		[Id],
		[NextInvoiceNumber],
		[InvoiceSignature],
		[ShowShippingAddress],
		[InvoiceNote],
		[RollUpTaxes],
		[PurchaseLabel],
		[TrackedItemDisplayFormatId],
		[ShowTrackedItemName],
		[ShowTrackedItemReference],
		[ShowTrackedItemDescription],
		[ShowTrackedItemCreatedDate],
		[TrackedItemNameFieldOverride],
		[TrackedItemReferenceFieldOverride],
		[TrackedItemDescriptionFieldOverride],
		[TrackedItemCreatedDateFieldOverride],
		[TrackedItemPageLabelOverride],
		[TrackedItemMainInvoiceMessage],
		[InvoiceCustomerReferenceOption],
		[LayoutId],
		[RollUpDiscounts],
		[ProjectedNotes],
		[ProjectedIncludeWatermark],
		[DraftInvoiceIncludeWatermark],
		[ShowServiceDates],
		[InvoiceSummarization],
		[PdfRollUpDisplayName],
		[PdfRollUpDisplayDescription],
		[PdfRollUpDisplayAllUnitPrices], 
		[PdfInvoiceEmailAttachmentOption], 
		[InvoiceSummarizationOption],
		[ChargeGroupOrderId],
		[ShowPaymentDetails],
		[InvoiceIncludeWatermark]
	)
	VALUES (
		@Id,
		@NextInvoiceNumber,
		@InvoiceSignature,
		@ShowShippingAddress,
		@InvoiceNote,
		@RollUpTaxes,
		@PurchaseLabel,
		@TrackedItemDisplayFormatId,
		@ShowTrackedItemName,
		@ShowTrackedItemReference,
		@ShowTrackedItemDescription,
		@ShowTrackedItemCreatedDate,
		@TrackedItemNameFieldOverride,
		@TrackedItemReferenceFieldOverride,
		@TrackedItemDescriptionFieldOverride,
		@TrackedItemCreatedDateFieldOverride,
		@TrackedItemPageLabelOverride,
		@TrackedItemMainInvoiceMessage,
		@InvoiceCustomerReferenceOption,
		@LayoutId,
		@RollUpDiscounts,
		@ProjectedNotes,
		@ProjectedIncludeWatermark,
		@DraftInvoiceIncludeWatermark,
		@ShowServiceDates,
		@InvoiceSummarization,
		@PdfRollUpDisplayName,
		@PdfRollUpDisplayDescription,
		@PdfRollUpDisplayAllUnitPrices, 
		@PdfInvoiceEmailAttachmentOption,
		@InvoiceSummarizationOption,
		@ChargeGroupOrderId,
		@ShowPaymentDetails,
		@InvoiceIncludeWatermark
	)


	--Not the most glamorous way of conditional inserts into AccountInvoicePreferenceLabel
	--Should be fine for performance, the lookup table is small

	-- Populate account invoice preference label from look up table
	INSERT INTO [AccountInvoicePreferenceLabel] (
	[AccountInvoicePreferenceId]
	, [InvoicePreferenceLabelId]
	, [Label]
	, [ModifiedTimestamp])
	SELECT 
		@Id
		, Id
		, DefaultLabel
		, GETUTCDATE()
	FROM [Lookup].[InvoicePreferenceLabel]
	WHERE Id <= 36 --All pre-Rollup Labels


	IF EXISTS (SELECT 1 FROM AccountFeatureConfiguration WHERE Id = @Id AND CustomerHierarchyRollup = 1)
	BEGIN
		EXEC usp_InsertAccountInvoicePreferenceLabel_HierarchyRollup @AccountId = @Id
	END

	INSERT INTO [AccountInvoicePreferenceLabel] (
	[AccountInvoicePreferenceId]
	, [InvoicePreferenceLabelId]
	, [Label]
	, [ModifiedTimestamp])
	SELECT 
		@Id
		, Id
		, DefaultLabel
		, GETUTCDATE()
	FROM [Lookup].[InvoicePreferenceLabel]
	WHERE Id > 47 --All future labels

	-- Don't show payment details surcharge and status 
	UPDATE [AccountInvoicePreferenceLabel]
	SET ShowField = 0
	WHERE [InvoicePreferenceLabelId] IN (55,56)
		AND AccountInvoicePreferenceId = @Id

	SELECT @Id As InsertedID
SET NOCOUNT OFF

GO

