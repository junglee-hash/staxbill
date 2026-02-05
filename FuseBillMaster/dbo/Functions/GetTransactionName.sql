
CREATE FUNCTION [dbo].[GetTransactionName]
(
	@TransactionId int,
	@TransactionName varchar(50)
)
RETURNS varchar(50)
AS
BEGIN
	if @TransactionId = 21
		return 'Discount'

	if @TransactionId = 22
		return 'Reverse Discount'

	if @TransactionId = 4 OR @TransactionId = 5
		return 'Refund'

	if @TransactionId = 24
		return 'Reverse charge'

	return @TransactionName
END

GO

