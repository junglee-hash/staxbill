
CREATE VIEW [dbo].[vw_AccountUserSummary]
AS
SELECT        aui.AccountId, ui.Id, ui.FirstName, ui.LastName, ui.Email, c.Username, aui.IsEnabled, 
	cast(case when ui.MfaSecretyKey is null then 0 else 1 end as bit) as [IsMfaConfigured],
stuff
                             ((SELECT        ',' + Name
                                 FROM            (SELECT        CASE WHEN r.Name = 'Custom' THEN [Role].Name ELSE r.Name END as Name
                                                           FROM            [user] u INNER JOIN
                                                                                     AccountUser au ON u.Id = au.UserId INNER JOIN
                                                                                     AccountUserRole aur ON au.id = aur.AccountUserId INNER JOIN
                                                                                     lookup.RoleType r ON aur.RoleTypeId = r.id LEFT JOIN
																					 [Role] ON [Role].Id = aur.RoleId
                                                           WHERE        u.Id = ui.Id and au.AccountId = aui.AccountId ) Result
                                 ORDER BY Name FOR xml path('')), 1, 1, '') AS Roles
FROM            [User] Ui INNER JOIN
                         AccountUser aui ON ui.Id = aui.UserId INNER JOIN
						 Credential c ON ui.Id = c.UserId

GO

