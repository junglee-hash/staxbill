CREATE PROCEDURE [dbo].[Staffside_ActiveHostedPages]
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SNAPSHOT

	--Description:
	--All active hosted pages
	SELECT 
		   hp.[AccountId]
		  ,acc.CompanyName
		  ,hp.[Id] as [Hosted Page Id]
		  ,hpt.Name
		  ,[FriendlyName]
		  ,[Key]
		  ,(Case acc.Live
				when  0 
				then 'False'
				else 'True'
			end) as [Fusebill Live]
		  ,(Case acc.Signed
				when  0 
				then 'False'
				else 'True'
			end) as [Fusebill Signed]
	  FROM [dbo].[HostedPage] hp
	  inner join Lookup.HostedPageType hpt on hpt.Id = hp.HostedPageTypeId
	  inner join dbo.Account acc on acc.Id = hp.AccountId
	  where hp.HostedPageStatusId = 2
	  order by AccountId


END

GO

