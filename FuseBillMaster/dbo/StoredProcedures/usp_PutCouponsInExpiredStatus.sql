
CREATE procedure [dbo].[usp_PutCouponsInExpiredStatus]
@UTCDateTime datetime
as

Begin TRAN

set nocount on

BEGIN TRY

DECLARE @couponsUpdated bigint = 0

---Expire Coupons

; with LastEligibilityDate as
(
Select Max(EndDate) as EndDate
,CouponId
from CouponEligibility ce
inner join CouponDiscount cd
on ce.Id = cd.CouponEligibilityId
inner join Coupon c
on cd.CouponId = c.Id
Where 
       StatusId = 2
group by CouponId 
)
 
Update c
       set StatusId = 3, ModifiedTimestamp = getutcdate()
From Coupon c
inner join LastEligibilityDate led on c.Id = led.CouponId 
       and led.EndDate < @UTCDateTime 

select @couponsUpdated = @couponsUpdated + @@RowCount


---Mark coupons as ineligible, since expired coupons are already handled, we assume any coupons not in an eligible range are ineligible
; with EligibilityDates as
(
Select StartDate, EndDate, CouponId
from CouponEligibility ce
inner join CouponDiscount cd
on ce.Id = cd.CouponEligibilityId
inner join Coupon c
on cd.CouponId = c.Id
WHERE StatusId in (2, 6) --Active, ineligible
group by CouponId, StartDate, EndDate 
)
UPDATE c
SET 
c.StatusId = case when edNow.CouponId is NULL THEN 6 --Ineligible
		ELSE 2 END --Active
FROM Coupon c
INNER JOIN EligibilityDates ed ON c.Id = ed.CouponId --filter down to only coupons with eligibilities
LEFT JOIN EligibilityDates edNow ON c.Id = edNow.CouponId AND edNow.StartDate < @UTCDateTime AND edNow.EndDate > @UTCDateTime
WHERE c.StatusId in (2,6)

select @couponsUpdated = @couponsUpdated + @@RowCount

set nocount off
commit TRAN
Select @couponsUpdated as CouponsUpdated
END TRY
BEGIN CATCH
ROLLBACK TRAN
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );

set nocount off
END CATCH

GO

