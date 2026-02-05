
CREATE PROCEDURE [dbo].[usp_GetAccountHubspotCustomerInfomationConfiguration]
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select 
		case 
			when cic.Id is null then 0
			else cic.Id
		end as [Id]
		,ff.Id as FieldId
		,ff.Name
		,case 
			when ff.Name = 'Sales Tracking Code 1' then stc.SalesTrackingCode1Label
			when ff.Name = 'Sales Tracking Code 2' then stc.SalesTrackingCode2Label
			when ff.Name = 'Sales Tracking Code 3' then stc.SalesTrackingCode3Label
			when ff.Name = 'Sales Tracking Code 4' then stc.SalesTrackingCode4Label
			when ff.Name = 'Sales Tracking Code 5' then stc.SalesTrackingCode5Label
			else ads.Value
		 end as [DisplayLabel]
		,case 
			when cic.IsVisible is null then 0
			else cic.IsVisible
		 end as [IsVisible]
	from lookup.FusebillField ff
	left join AccountDisplaySetting ads on ads.AccountId = @AccountId and ads.[Key] = ff.PropertyName
	left join AccountHubspotCustomerInformationConfiguration cic on cic.AccountId = @AccountId and cic.FusebillFieldId = ff.Id
	join AccountSalesTrackingCodeConfiguration stc on stc.Id = @AccountId
	where ff.AvailableForHubspot = 1
END

GO

