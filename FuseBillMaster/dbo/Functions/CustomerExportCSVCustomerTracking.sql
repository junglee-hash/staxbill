CREATE FUNCTION [dbo].[CustomerExportCSVCustomerTracking]
(	
	@FusebillId as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	ISNULL(cr.Reference1, '') as [Ref1]
	,ISNULL(cr.Reference2, '') as [Ref2]
	,ISNULL(cr.Reference3, '') as [Ref3]
	,ISNULL(ca.AdContent, '') as [Ad Content]
	,ISNULL(ca.Campaign, '') as [Campaign]
	,ISNULL(ca.Keyword, '') as [Keyword]
	,ISNULL(ca.LandingPage, '') as [Landing Page]
	,ISNULL(ca.Medium, '') as [Medium]
	,ISNULL(ca.[Source], '') as [Source]
	,ISNULL(stc1.Code, '') as [SalesTrackingCode1Code]
	,ISNULL(stc1.Name, '') as [SalesTrackingCode1Name]
	,ISNULL(stc2.Code, '') as [SalesTrackingCode2Code]
	,ISNULL(stc2.Name, '') as [SalesTrackingCode2Name]
	,ISNULL(stc3.Code, '') as [SalesTrackingCode3Code]
	,ISNULL(stc3.Name, '') as [SalesTrackingCode3Name]
	,ISNULL(stc4.Code, '') as [SalesTrackingCode4Code]
	,ISNULL(stc4.Name, '') as [SalesTrackingCode4Name]
	,ISNULL(stc5.Code, '') as [SalesTrackingCode5Code]
	,ISNULL(stc5.Name, '') as [SalesTrackingCode5Name]

	FROM
	--CUSTOMER REFERENCE JOINS
	CustomerReference cr
	LEFT JOIN SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
	LEFT JOIN SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
	LEFT JOIN SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
	LEFT JOIN SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
	LEFT JOIN SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id
	INNER JOIN CustomerAcquisition ca on ca.Id = cr.Id	

	WHERE cr.Id = @FusebillId
)

GO

