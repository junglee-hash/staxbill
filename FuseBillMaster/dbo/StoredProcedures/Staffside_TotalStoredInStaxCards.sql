
CREATE PROCEDURE [dbo].[Staffside_TotalStoredInStaxCards]
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @totalInStax int

set @totalInStax =(
select Count(pm.id)
from PaymentMethod pm
inner join Customer c on pm.CustomerId = c.Id
inner join Account a on a.Id = c.AccountId
where
	pm.PaymentMethodStatusId = 1
	and pm.StoredInStax = 1
	and a.Live = 1 )


DECLARE @totalInFusebill int

set @totalInFusebill =(
select Count(pm.id)
from PaymentMethod pm
inner join Customer c on pm.CustomerId = c.Id
inner join Account a on a.Id = c.AccountId
where
	pm.PaymentMethodStatusId = 1
	and a.Live = 1 )


DECLARE @totalStoredInFusebill int

set @totalStoredInFusebill =(
select Count(pm.id)
from PaymentMethod pm
inner join Customer c on pm.CustomerId = c.Id
inner join Account a on a.Id = c.AccountId
where
	pm.PaymentMethodStatusId = 1
	and pm.StoredInFusebillVault = 1
	and a.Live = 1 )

create table #StoredInStaxSummary
(
    Title Varchar(50), 
    Number int
)

Insert into #StoredInStaxSummary Select 'Total number of cards in Stax', @totalInStax
Insert into #StoredInStaxSummary Select 'Total number of cards in Fusebill', @totalInFusebill
Insert into #StoredInStaxSummary Select 'Total number of cards stored in Fusebill vault', @totalStoredInFusebill
Insert into #StoredInStaxSummary Select 'Percentage of valid cards transferred',CAST( ( @totalInStax*100 / @totalStoredInFusebill) AS DECIMAL(18, 2))

Select * from  #StoredInStaxSummary
Drop Table #StoredInStaxSummary

GO

