
CREATE     PROCEDURE [dbo].[usp_DeletePricebook]
@PricebookId BIGINT
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @OrderToCashCycleIds TABLE (Id bigint)
		INSERT INTO @OrderToCashCycleIds SELECT pe.OrderToCashCycleId 
		FROM Pricebook pb
		INNER JOIN PricebookEntry pe ON pb.Id = pe.PricebookId
		WHERE pb.Id = @PricebookId

		DELETE Price
		FROM Price
		INNER JOIN QuantityRange qr ON qr.Id = Price.QuantityRangeId
		INNER JOIN PricebookEntry pe ON pe.OrderToCashCycleId = qr.OrderToCashCycleId
		WHERE pe.PricebookId = @PricebookId

		DELETE qr
		FROM QuantityRange qr
		INNER JOIN PricebookEntry pe ON pe.OrderToCashCycleId = qr.OrderToCashCycleId
		WHERE pe.PricebookId = @PricebookId

		DELETE FROM PricebookEntry
		WHERE PricebookId = @PricebookId

		DELETE FROM PricebookMaxPrice
		WHERE PricebookId = @PricebookId

		DELETE otc
		FROM OrderToCashCycle otc
		INNER JOIN @OrderToCashCycleIds otc2 ON otc.Id = otc2.Id

		DELETE FROM Pricebook
		WHERE Id = @PricebookId

	END TRY
	BEGIN CATCH
		EXEC dbo.usp_ErrorHandler;
	END CATCH

	SET NOCOUNT OFF

END

GO

