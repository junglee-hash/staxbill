CREATE PROC [dbo].[usp_UpdateQuantityRange]

	@Id bigint,
	@Min decimal,
	@Max decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@OrderToCashCycleId bigint
AS
SET NOCOUNT ON
	UPDATE [QuantityRange] SET 
		[Min] = @Min,
		[Max] = @Max,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[OrderToCashCycleId] = @OrderToCashCycleId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

