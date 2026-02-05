CREATE PROCEDURE [dbo].[usp_ConsumeInstantPaymentNotification]
	@Id bigint,
	@Exception nvarchar(4000)
	
AS
BEGIN
	update InstantPaymentNotification
	set Consumed = 1
	,ExceptionReason = @Exception
	Where Id = @Id
END

GO

