-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_UnlatchNetsuiteFinancialIds]
	@CustomerId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- **** This stored procedure only wipes Netsuite IDs from transactional tables
	-- **** Bulk delete jobs wipe non-transactional Netsuite IDs

	UPDATE Invoice
		SET ErpNetsuiteId = NULL
	WHERE CustomerId = @CustomerId

	UPDATE p
		SET NetsuiteId = NULL
	FROM Payment p
	INNER JOIN [Transaction] t ON t.Id = p.Id
	WHERE t.CustomerId = @CustomerId

	UPDATE r
		SET NetsuiteId = NULL
	FROM Refund r
	INNER JOIN [Transaction] t ON t.Id = r.Id
	WHERE t.CustomerId = @CustomerId

	UPDATE c
		SET NetsuiteId = NULL
	FROM Credit c
	INNER JOIN [Transaction] t ON t.Id = c.Id
	WHERE t.CustomerId = @CustomerId

	UPDATE d
		SET NetsuiteId = NULL
	FROM Debit d
	INNER JOIN [Transaction] t ON t.Id = d.Id
	WHERE t.CustomerId = @CustomerId

	UPDATE cng
		SET cng.NetsuiteId = NULL
	FROM CreditNoteGroup cng
	INNER JOIN Invoice i ON i.Id = cng.InvoiceId
	WHERE i.CustomerId = @CustomerId

	UPDATE w
		SET NetsuiteId = NULL
	FROM WriteOff w
	INNER JOIN [Transaction] t ON t.Id = w.Id
	WHERE t.CustomerId = @CustomerId
END

GO

